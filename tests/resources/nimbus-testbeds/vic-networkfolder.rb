oneGB = 1 * 1000 * 1000 # in KB
 
$testbed = Proc.new do
  {
    "name" => "vic-iscsi-cluster",
    "version" => 3,
    "esx" => (0..1).map do | idx |
      {
        "name" => "esx.#{idx}",
        "vc" => "vc.0",
        'cpus' => 8,
        'cpuReservation' => 2400,
        "style" => "fullInstall",
        "desiredPassword" => "e2eFunctionalTest",
        "memory" => 16384, # 2x default
        'memoryReservation' => 4096,
        "disk" => [ 30 * oneGB],
        "nics" => 2,
        "iScsi" => ["iscsi.0"],
        "clusterName" => "cls1",
      }
    end,

    "iscsi" => [
      {
        "name" => "iscsi.0",
        "luns" => [200],
        "iqnRandom" => "nimbus1"
      }
    ],

    "vcs" => [
      {
        "name" => "vc.0",
        "type" => "vcva",
        'cpuReservation' => 2400,
        'memoryReservation' => 4096,
        "dcName" => "dc1",
        "clusters" => [{"name" => "cls1", "vsan" => false, "enableDrs" => true, "enableHA" => true}],
        "addHosts" => "allInSameCluster",
      }
    ],

    "postBoot" => Proc.new do |runId, testbedSpec, vmList, catApi, logDir|
      esxList = vmList['esx']
        esxList.each do |host|
          host.ssh do |ssh|
            ssh.exec!("esxcli network firewall set -e false")
          end
        end
      end
  }
end

