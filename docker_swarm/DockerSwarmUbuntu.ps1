function install-dockerswarm {
    <#
    .SYNOPSIS
    Install Docker Swarm on Ubuntu
    .DESCRIPTION
    This function will install Docker Swarm on Ubuntu
    .EXAMPLE
    install-dockerwarm -username tipsforitpros -swarmmanager 10.0.0.10 -swarmworkers 10.0.0.11,10.0.0.12
    #>
    [CmdletBinding()]
        Param(
            [Parameter(ValueFromPipelineByPropertyName, Mandatory)]$Username,  # your ssh username
            [Parameter(ValueFromPipelineByPropertyName, Mandatory)][ValidatePattern('^(?:[0-9]{1,3}\.){3}[0-9]{1,3}$')]$SwarmManager, # your manager IP
            [Parameter(ValueFromPipelineByPropertyName, Mandatory)][ValidatePattern('^(?:[0-9]{1,3}\.){3}[0-9]{1,3}$')][string[]]$SwarmWorkers # your workers IP
    )
    # configure local Manager
    sudo apt install -y curl git
    curl -fsSL https://get.docker.com/ | sh
    $capture = sudo docker swarm init --advertise-addr $SwarmManager
    $token = $capture | select-string token | Select-Object -First 1 ; $token = $token -split(" ")
    $swarmkey = $token[$token.count -2]
    $swarmIP = $token[$token.count -1]
    # configure workers
    $SwarmWorkers | foreach-Object {
    $command = $($UserName) + '@' + $_
    ssh $command "sudo apt install -y curl git && curl -fsSL https://get.docker.com/ | sh && sudo docker swarm join --token $swarmkey $swarmIP"
    }
}
