@ECHO OFF
REM Copyright 2016-2017 VMware, Inc. All Rights Reserved.
REM
REM Licensed under the Apache License, Version 2.0 (the "License");
REM you may not use this file except in compliance with the License.
REM You may obtain a copy of the License at
REM
REM    http://www.apache.org/licenses/LICENSE-2.0
REM
REM Unless required by applicable law or agreed to in writing, software
REM distributed under the License is distributed on an "AS IS" BASIS,
REM WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
REM See the License for the specific language governing permissions and
REM limitations under the License.

SETLOCAL ENABLEEXTENSIONS
SETLOCAL DISABLEDELAYEDEXPANSION
SETLOCAL

SET me=%~n0
SET parent=%~dp0

FOR /F "tokens=*" %%A IN (configs) DO (
    IF NOT %%A=="" (
        %%A
    )
)

IF NOT EXIST configs (
    ECHO -------------------------------------------------------------
    ECHO Error! Configs file is missing. Please try downloading the VIC UI installer again
    ENDLOCAL
    EXIT /b 1
)

IF NOT EXIST ..\plugin-manifest (
    ECHO -------------------------------------------------------------
    ECHO Error! Plugin manifest was not found!
    ENDLOCAL
    EXIT /b 1
)

SET arg_name=%1
SET arg_value=%2

:read_vc_args
IF NOT "%1"=="" (
    IF "%1"=="-i" (
        SET target_vcenter_ip=%2
        SHIFT
    )
    IF "%1"=="-u" (
        SET vcenter_username=%2
        SHIFT
    )
    IF "%1"=="-p" (
        SET vcenter_password=%2
        SHIFT
    )
    IF "%1"=="-f" (
        SET force_set=1
        SHIFT
        GOTO :read_vc_args
    )
    SHIFT
    GOTO :read_vc_args
)

ECHO -------------------------------------------------------------
ECHO This script will install vSphere Integrated Containers plugin
ECHO for vSphere Client (HTML) and vSphere Web Client (Flex).
ECHO.
ECHO Please provide connection information to the vCenter Server.
ECHO -------------------------------------------------------------
IF [%target_vcenter_ip%] == [] (
    SET /p target_vcenter_ip="Enter FQDN or IP to target vCenter Server: "
)
IF [%vcenter_username%] == [] (
    SET /p vcenter_username="Enter your vCenter Administrator Username: "
)
IF [%vcenter_password%] == [] (
    GOTO :read_vc_password
) ELSE (
    GOTO :after_vc_info_read
)

:read_vc_password
SET "psCommand=powershell -Command "$pword = read-host 'Enter your vCenter Administrator Password' -AsSecureString ; ^ $BSTR=[System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($pword); ^ [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)""
FOR /f "usebackq delims=" %%p in (`%psCommand%`) do set vcenter_password=%%p

:after_vc_info_read
SET plugin_manager_bin=%parent%..\..\vic-ui-windows.exe
SET vcenter_reg_common_flags=--target https://%target_vcenter_ip%/sdk/ --user %vcenter_username% --password ^"%vcenter_password%^"

REM read plugin-manifest
FOR /F "tokens=1,2 delims==" %%A IN (..\plugin-manifest) DO (
    IF NOT %%A=="" (
        CALL SET %%A=%%B
    )
)

REM add a forward slash to vic_ui_host_url if its last character is not '/'
IF [%vic_ui_host_url:~-1%] NEQ [/] (
    SET vic_ui_host_url=%vic_ui_host_url%/
)

REM replace space delimiters with colon delimiters
SETLOCAL ENABLEDELAYEDEXPANSION
FOR /F "tokens=*" %%D IN ('ECHO %vic_ui_host_thumbprint%^| powershell -Command "$input.replace(' ', ':')"') DO (
    SET vic_ui_host_thumbprint=%%D
)
SETLOCAL DISABLEDELAYEDEXPANSION

REM entry routine
GOTO retrieve_vc_thumbprint

:retrieve_vc_thumbprint
"%parent%..\..\vic-ui-windows.exe" info %vcenter_reg_common_flags% --key com.vmware.vic.noop > scratch.tmp 2>&1
TYPE scratch.tmp | findstr -c:"Failed to verify certificate" > NUL
IF %ERRORLEVEL% EQU 0 (
    SETLOCAL ENABLEDELAYEDEXPANSION
    FOR /F "usebackq tokens=2 delims=(" %%B IN (scratch.tmp) DO SET vc_thumbprint=%%B
    SET vc_thumbprint=!vc_thumbprint:~11,-1!
    SET thumbprint_string=--thumbprint !vc_thumbprint!
    ECHO.
    ECHO SHA-1 key fingerprint of host '%target_vcenter_ip%' is '!vc_thumbprint!'
    GOTO validate_vc_thumbprint
)

REM in case VIC_MACHINE_THUMBPRINT environment variable is set, use it
IF NOT "%VIC_MACHINE_THUMBPRINT%" == "" (
    SETLOCAL ENABLEDELAYEDEXPANSION
    SET vc_thumbprint=%VIC_MACHINE_THUMBPRINT%
    SET thumbprint_string=--thumbprint !vc_thumbprint!
    ECHO.
    ECHO SHA-1 key fingerprint of host '%target_vcenter_ip%' is '!vc_thumbprint!'
    GOTO validate_vc_thumbprint
)

TYPE scratch.tmp | findstr -i -c:"no such host" > NUL
IF %ERRORLEVEL% EQU 0 (
    TYPE scratch.tmp
    ECHO -------------------------------------------------------------
    ECHO Error! Could not register the plugin with vCenter Server. Please see the message above
    DEL scratch*.tmp 2>NUL
    ENDLOCAL
    EXIT /b 1
)

REM either certificate is trusted or %VIC_MACHINE_THUMBPRINT% is set already
IF [%vc_thumbprint%] == [] (
    SET thumbprint_string=
)

IF [%force_set%] == [1] (
        GOTO parse_and_register_plugins
) ELSE (
    GOTO check_existing_plugins
)

:validate_vc_thumbprint
SET /p accept_vc_thumbprint="Are you sure you trust the authenticity of this host [yes/no]? "
IF /I [%accept_vc_thumbprint%] == [yes] (
    SETLOCAL DISABLEDELAYEDEXPANSION
    IF [%force_set%] == [1] (
        GOTO parse_and_register_plugins
    ) ELSE (
        GOTO check_existing_plugins
    )
)
IF /I [%accept_vc_thumbprint%] == [no] (
    SET /p vc_thumbprint="Enter SHA-1 thumbprint of target VC: "
    SETLOCAL DISABLEDELAYEDEXPANSION
    IF [%force_set%] == [1] (
        GOTO parse_and_register_plugins
    ) ELSE (
        GOTO check_existing_plugins
    )
)
ECHO Please answer either "yes" or "no"
GOTO validate_vc_thumbprint

:check_existing_plugins
ECHO.
ECHO -------------------------------------------------------------
ECHO Checking existing plugins...
ECHO -------------------------------------------------------------
SET can_install_continue=1
REM check for h5c plugin
"%parent%..\..\vic-ui-windows.exe" info %vcenter_reg_common_flags% --key com.vmware.vic %thumbprint_string% > scratch.tmp 2>&1

REM check for any failure
TYPE scratch.tmp | findstr -i -c:"fail" > NUL
IF %ERRORLEVEL% EQU 0 (
    TYPE scratch.tmp
    ECHO -------------------------------------------------------------
    ECHO Error! Could not register plugin with vCenter Server. Please see the message above
    DEL scratch*.tmp 2>NUL
    ENDLOCAL
    EXIT /b 1
)
REM check if plugin (h5c) is not registered
TYPE scratch.tmp | findstr -c:"is not registered" > NUL
IF %ERRORLEVEL% GTR 0 (
    SETLOCAL ENABLEDELAYEDEXPANSION
    TYPE scratch.tmp | findstr -r -c:"Version.*" > scratch2.tmp
    FOR /F "usebackq tokens=2 delims=INFO" %%C IN (scratch2.tmp) DO SET ver_string=%%C
    ECHO com.vmware.vic is already registered. Version: !ver_string:~11!
    REM force flag condition
    SET can_install_continue=0
    SETLOCAL DISABLEDELAYEDEXPANSION
)
REM check for flex plugin
"%parent%..\..\vic-ui-windows.exe" info %vcenter_reg_common_flags% --key com.vmware.vic.ui %thumbprint_string% > scratch.tmp 2>&1

REM check for any failure
TYPE scratch.tmp | findstr -i -c:"fail" > NUL
IF %ERRORLEVEL% EQU 0 (
    TYPE scratch.tmp
    ECHO -------------------------------------------------------------
    ECHO Error! Could not register plugin with vCenter Server. Please see the message above
    DEL scratch*.tmp 2>NUL
    ENDLOCAL
    EXIT /b 1
)
REM check if plugin (flex) is not registered
TYPE scratch.tmp | findstr -c:"is not registered" > NUL
IF %ERRORLEVEL% GTR 0 (
    SETLOCAL ENABLEDELAYEDEXPANSION
    TYPE scratch.tmp | findstr -r -c:"Version.*" > scratch2.tmp
    FOR /F "usebackq tokens=2 delims=INFO" %%C IN (scratch2.tmp) DO SET ver_string=%%C
    ECHO com.vmware.vic.ui is already registered. Version: !ver_string:~11!
    REM force flag condition
    SET can_install_continue=0
    SETLOCAL DISABLEDELAYEDEXPANSION
)
REM if either plugin is installed kill the script
IF %can_install_continue% EQU 0 (
    ECHO -------------------------------------------------------------
    ECHO Error! At least one plugin is already registered with the target VC.
    ECHO Please run upgrade.bat instead.
    DEL scratch*.tmp 2>NUL
    ENDLOCAL
    EXIT /b 1
)
ECHO No VIC Engine UI plugin was detected. Continuing to install the plugins.
GOTO parse_and_register_plugins

:parse_and_register_plugins
REM remove obsolete plugin key if it ever exists
"%plugin_manager_bin%" remove %vcenter_reg_common_flags% --key com.vmware.vicui.Vicui %thumbprint_string% > NUL 2> NUL
ECHO.
ECHO -------------------------------------------------------------
ECHO Preparing to register vCenter Extension %name:"=%-H5Client...
ECHO -------------------------------------------------------------
SET plugin_reg_flags=%vcenter_reg_common_flags% --name "%name:"=%-H5Client" %thumbprint_string% --version %version:"=% --summary "Plugin for %name:"=%-H5Client" --company %company% --key %key_h5c:"=% --url %vic_ui_host_url%files/%key_h5c:"=%-v%version:"=%.zip --server-thumbprint %vic_ui_host_thumbprint% --configure-ova --type VicApplianceVM
IF [%force_set%] == [1] (
    SET plugin_reg_flags=%plugin_reg_flags% --force
)
"%plugin_manager_bin%" install %plugin_reg_flags%
IF %ERRORLEVEL% NEQ 0 (
    ECHO -------------------------------------------------------------
    ECHO Error! Could not register plugin with vCenter Server. Please see the message above
    DEL scratch*.tmp 2>NUL
    ENDLOCAL
    EXIT /b 1
)
ECHO.
ECHO -------------------------------------------------------------
ECHO Preparing to register vCenter Extension %name:"=%-FlexClient...
ECHO -------------------------------------------------------------
SET plugin_reg_flags=%vcenter_reg_common_flags% --name "%name:"=%-FlexClient" %thumbprint_string% --version %version:"=% --summary "Plugin for %name:"=%-FlexClient" --company %company% --key %key_flex:"=% --url %vic_ui_host_url%files/%key_flex:"=%-v%version:"=%.zip --server-thumbprint %vic_ui_host_thumbprint%
IF [%force_set%] == [1] (
    SET plugin_reg_flags=%plugin_reg_flags% --force
)
"%plugin_manager_bin%" install %plugin_reg_flags%
IF %ERRORLEVEL% NEQ 0 (
    ECHO -------------------------------------------------------------
    ECHO Error! Could not register plugin with vCenter Server. Please see the message above
    DEL scratch*.tmp 2>NUL
    ENDLOCAL
    EXIT /b 1
)
GOTO end

:end
DEL scratch*.tmp 2>NUL
ECHO --------------------------------------------------------------
ECHO Installation successful. Restart the vSphere Client services. All vSphere Client users must log out and log back in again to see the vSphere Integrated Containers plug-in.
ECHO Exited successfully
ENDLOCAL
