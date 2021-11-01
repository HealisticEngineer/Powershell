# Important you must first setup blue and change ip ranges to match your lab.

# set network
Get-NetConnectionProfile | Select-Object InterfaceAlias,NetworkCategory
Get-NetConnectionProfile | Set-NetConnectionProfile -NetworkCategory Private

winrm quickconfig
# Check list
Get-ChildItem -Path WSMan:\localhost\Client\TrustedHosts
# Set trusted hosts
Set-Item -Path WSMan:\localhost\Client\TrustedHosts -Value 10.0.0.*
# other examples
# Set-Item -Path WSMan:\localhost\Client\TrustedHosts -Value "192.168.1.*,*.yourdomain.com"  -Force

# use ssl connection to copy certificate
$PSSessionOption = New-PSSessionOption -SkipCACheck
$red = New-PSSession -ComputerName Blue -Credential (Get-Credential) -SessionOption $PSSessionOption -UseSSL
copy-item -Fromsession $red c:\cert.cer -Destination c:\cert.cer

# Importing Certificate
Import-Certificate -FilePath c:\cert.cer -CertStoreLocation Cert:\LocalMachine\root\
Import-Certificate -FilePath c:\cert.cer -CertStoreLocation Cert:\LocalMachine\TrustedPublisher
