$hashtable =@{
    UserName = "tipsforitpros" # your ssh user
    SwarmManager = "192.168.1.100" # your manager IP
    SwarmWorkers = @("192.168.1.212","192.168.1.59") # your workers
}
# configure local Manager
sudo apt install -y curl git
curl -fsSL https://get.docker.com/ | sh
$capture = sudo docker swarm init --advertise-addr $hashtable.SwarmManager
$token = $capture | select-string token | Select-Object -First 1 ; $token = $token -split(" ")
$swarmkey = $token[$token.count -2]
$swarmIP = $token[$token.count -1]
# configure workers
$hashtable.SwarmWorkers | foreach-Object {
$command = $($hashtable.UserName) + '@' + $_
ssh $command "sudo apt install -y curl git && curl -fsSL https://get.docker.com/ | sh && sudo docker swarm join --token $swarmkey $swarmIP"
}
