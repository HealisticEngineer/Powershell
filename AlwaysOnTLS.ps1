Function Set-SQL_Cert {

    $Subject = "CN=" + [net.dns]::GetHostEntry($env:computername).Hostname + ", O=Lab, C=GB"

    # Check if cluster
    $cluster = (Get-WindowsFeature -Name  Failover-Clustering).Installed
    $ClusterStatus = Get-Service -Name ClusSvc -ErrorAction SilentlyContinue

    if($cluster -eq $true -and $($ClusterStatus.status) -eq "Running"){ $cluster = $true } Else {$cluster = $false}
            
    if($cluster -eq $true){
        # Build Array
        $Array1 =@()
        $AG = (Get-ClusterResource | Where-Object {$_.ResourceType -eq "Network Name" -AND $_.name -ne "Cluster Name"} | Get-ClusterParameter -Name DnsName).value
        foreach($listener in $AG) {
            $DNS = $listener + "." + $env:USERDNSDOMAIN
            $array1 += $DNS
                }
        $string = [net.dns]::GetHostEntry($env:computername).Hostname
        foreach($i in $array1)
        {               
            $string += "," + $i
        }
    #Create Certificate
    New-SelfSignedCertificate -CertStoreLocation Cert:\LocalMachine\My -subject $Subject  -DnsName $string -FriendlyName SQLServer -NotAfter (Get-Date).AddMonths(24) -KeySpec KeyExchange

    } else {
    $dnsname = ([System.Net.Dns]::GetHostByName((hostname)).HostName)
    #Create SSL Certificate (replace with PKI function)
    New-SelfSignedCertificate -CertStoreLocation Cert:\LocalMachine\My -subject $Subject  -DnsName $dnsname -FriendlyName SQLServer -NotAfter (Get-Date).AddMonths(24) -KeySpec KeyExchange
        
    }
}


$Instance = "MSSQLServer"
# check if cluster
$cluster = (Get-WindowsFeature -Name  Failover-Clustering).Installed
$ClusterStatus = Get-Service -Name ClusSvc -ErrorAction SilentlyContinue

# Set default status
$CertValide = $true

# Cert selection
$Subject = "CN=" + [net.dns]::GetHostEntry($env:computername).Hostname + ", O=Lab, C=GB"
$certs = Get-Childitem -Path Cert:\LocalMachine\My | Where-Object {$_.subject -eq $Subject} |
Sort-Object -Property NotBefore -Descending | Select-Object NotAfter, FriendlyName, DnsNameList, thumbprint -First 1


# Check if this is a cluster and if yes does the cert match the packages
if($cluster -eq $true -and $($ClusterStatus.status) -eq "Running"){
    write-output "this is cluster"
    $Array1 =@()
    $AG = (Get-ClusterResource | Where-Object {$_.ResourceType -eq "Network Name" -AND $_.name -ne "Cluster Name"} | Get-ClusterParameter -Name DnsName).value
    foreach($listener in $AG) {
        $DNS = $listener + "." + $env:USERDNSDOMAIN
        $array1 += $DNS
    }
    $same = [net.dns]::GetHostEntry($env:computername).Hostname
    foreach($p in $array1){
        $same += "," + $p
    }
    if($certs){
    $notsame = Compare-Object -ReferenceObject $same -DifferenceObject $certs.DnsNameList.Unicode
    if($notsame){
        $CertValide = $false
    } else {write-output "no cert"} 
    }
} else {write-output "Cluster isn't running"}

# check certificate is valid
if($($certs.NotAfter) -lt (Get-Date).AddDays(120)){
    $CertValide = $false
}

If($CertValide -eq $false){
    # Get new Cert
    Write-Output "Getting new cert"
    Set-SQL_Cert
    }

    $Subject = "CN=" + [net.dns]::GetHostEntry($env:computername).Hostname + ", O=Lab, C=GB"
    $certs = Get-Childitem -Path Cert:\LocalMachine\My | Where-Object {$_.subject -eq $Subject} |
    Sort-Object -Property NotBefore -Descending | Select-Object NotAfter, FriendlyName, DnsNameList, thumbprint -First 1

    # Set Thumbprint
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL14.$Instance\MSSQLServer\SuperSocketNetLib" -Name "Certificate" -Type String -Value "$($certs.thumbprint)"

    # Set Forced Encryption
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL14.$instance\MSSQLServer\SuperSocketNetLib" -Name "ForceEncryption" -Type DWord -Value "1"


