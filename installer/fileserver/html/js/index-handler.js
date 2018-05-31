function getThumbprint(target,callback) {
    var xhr = new XMLHttpRequest();
    var  thumbprint;
    xhr.open('POST', '/thumbprint?target=' + target);
    xhr.onreadystatechange = function() {
        callback(xhr.response,xhr.status);
    };
    xhr.send();             
}
    
function submitRegistration() {
//login elements

$loginForm = document.getElementById('login-form');
$loginSpinner = document.getElementById('login-spinner');
$loginBody = document.getElementById('login-body');
$loginSubmit = document.getElementById('login-submit');
$loginModal = document.getElementById('login-modal');
//plugin installations elements

$pluginForm = document.getElementById('plugin-form');
$pluginSpinner = document.getElementById('plugin-spinner');
$pluginBody = document.getElementById('plugin-body');
$pluginSubmit = document.getElementById('plugin-submit');
$pluginModal = document.getElementById('plugin-modal');

    if ($loginForm) {
        event.preventDefault();
        $loginSubmit.setAttribute('disabled', 'disabled');
        $loginBody.style.display = 'none';
        $loginSpinner.style.display = '';
        $vc = document.getElementById('target').value;
        getThumbprint($vc,function (thumbprint,status) {       
                if (status === 200){
                    $loginModal.style.display = 'none';
                    $pluginModal.style.display = '';
                    document.getElementById('thumbprint').value = thumbprint;
                    document.getElementById('thumbprint-show').value = thumbprint;    
                }
                else{
                    $loginBody.style.display = '';
                    $loginSpinner.style.display = 'none';
                    $loginSubmit.removeAttribute("disabled");
                    document.getElementById('thumbprint-alert-span').textContent = 'code: '+status+' '+thumbprint+', '+'check VC IP/FQDN';
                    document.getElementById('thumbprint-alert-div').style.display='';
                }
            })
        
    }

    if ($pluginForm) {
        $pluginForm.addEventListener('submit', function(event) {
            event.preventDefault();
            $pluginSubmit.setAttribute('disabled', 'disabled');
            $pluginBody.style.display = 'none';
            $pluginSpinner.style.display = '';
            setTimeout(function() {              
                $loginForm.submit();
            },2000);
        })
    }
}