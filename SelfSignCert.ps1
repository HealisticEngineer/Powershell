$rootcert = New-SelfSignedCertificate -CertStoreLocation cert:\CurrentUser\My -DnsName "SystemCenterDudes Lab CA" -KeyUsage CertSign
Write-host "Certificate Thumbprint: $($rootcert.Thumbprint)"

#This needs to be added to Trusted Root on all labcomputers 
Export-Certificate -Cert $rootcert -FilePath C:\certtemp\SCDudesRootCA.cer


# Other key options
-KeyAlgorithm RSA/ECDSA_secp384r1 -KeyLength 2048/4096
-NotAfter (Get-Date).AddMonths(6)



#Imports certificate to Trusted Publishers (Requires "Run as Administrator")
Import-Certificate -FilePath C:\certtemp\SCDudesRootCA.cer -CertStoreLocation Cert:\LocalMachine\Root


#the thumbprint of need to be changed to your root certificate. 
$rootca = Get-ChildItem cert:\CurrentUser\my | Where-Object {$_.Thumbprint -eq "C46F2E3F10E61DFBCA006FFD8F245125AC4B371D"}

#Path can be changed to 'cert:\CurrentUser\My\' if needed
New-SelfSignedCertificate -certstorelocation cert:\LocalMachine\My -dnsname mylabserver.scdudeslab.com -Signer $rootca
