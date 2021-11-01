# set network
Get-NetConnectionProfile | Select-Object InterfaceAlias,NetworkCategory
Get-NetConnectionProfile | Set-NetConnectionProfile -NetworkCategory Private
# enable ps remoting
Enable-PSRemoting –force

# Create certificate
$hostName = $env:COMPUTERNAME
$serverCert = New-SelfSignedCertificate -CertStoreLocation Cert:\LocalMachine\My -DnsName $hostName

# Import certificate to winrm
Get-ChildItem wsman:\localhost\Listener\ | Where-Object -Property Keys -eq 'Transport=HTTP' | Remove-Item -Recurse
New-Item -Path WSMan:\localhost\Listener\ -Transport HTTPS -Address * -CertificateThumbPrint $serverCert.Thumbprint -Force
Get-ChildItem wsman:\localhost\Listener

# This needs to be added to Trusted Root on all labcomputers 
Export-Certificate -Cert $serverCert -FilePath C:\cert.cer

# create firewall ( use your own lab range )
# this line will need changing
New-NetFirewallRule -Displayname 'WinRM - Powershell remoting HTTPS-In' -Name 'WinRM - Powershell remoting HTTPS-In' `
-Profile Any -LocalPort 5986 -Protocol TCP -RemoteAddress 192.168.0.1/24  172.16.5.4-172.16.5.50
