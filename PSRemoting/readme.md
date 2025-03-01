# Configure Powershell Remoting

This contains files Blue and Red as per the Demo!

Red plays the part of the remote computer while Blue plays the part as the users workstation or notebook that connects to red

# Configure Powershell Remoting

This repository contains two scripts, `Red.ps1` and `Blue.ps1`, which are used to configure PowerShell remoting between two computers. In this setup, "Red" represents the remote computer, while "Blue" represents the user's workstation or notebook that connects to the remote computer.

## Instructions

### Red.ps1

The `Red.ps1` script is used to configure the remote computer (Red) for PowerShell remoting. It performs the following tasks:

1. **Set Network Profile**: Sets the network profile to Private.
    ```powershell
    Get-NetConnectionProfile | Select-Object InterfaceAlias,NetworkCategory
    Get-NetConnectionProfile | Set-NetConnectionProfile -NetworkCategory Private
    ```

2. **Enable PowerShell Remoting**: Enables PowerShell remoting on the remote computer.
    ```powershell
    Enable-PSRemoting –force
    ```

3. **Create and Export Certificate**: Creates a self-signed certificate and exports it to a file.
    ```powershell
    $hostName = $env:COMPUTERNAME
    $serverCert = New-SelfSignedCertificate -CertStoreLocation Cert:\LocalMachine\My -DnsName $hostName
    Export-Certificate -Cert $serverCert -FilePath C:\cert.cer
    ```

4. **Configure WinRM Listener**: Configures the WinRM listener to use HTTPS with the created certificate.
    ```powershell
    Get-ChildItem wsman:\localhost\Listener\ | Where-Object -Property Keys -eq 'Transport=HTTP' | Remove-Item -Recurse
    New-Item -Path WSMan:\localhost\Listener\ -Transport HTTPS -Address * -CertificateThumbPrint $serverCert.Thumbprint -Force
    Get-ChildItem wsman:\localhost\Listener
    ```

5. **Create Firewall Rule**: Creates a firewall rule to allow PowerShell remoting over HTTPS.
    ```powershell
    New-NetFirewallRule -Displayname 'WinRM - Powershell remoting HTTPS-In' -Name 'WinRM - Powershell remoting HTTPS-In' `
    -Profile Any -LocalPort 5986 -Protocol TCP -RemoteAddress 192.168.0.1/24  172.16.5.4-172.16.5.50
    ```

### Blue.ps1

The [Blue.ps1](http://_vscodecontentref_/2) script is used to configure the local workstation (Blue) to connect to the remote computer (Red). It performs the following tasks:

1. **Set Network Profile**: Sets the network profile to Private.
    ```powershell
    Get-NetConnectionProfile | Select-Object InterfaceAlias,NetworkCategory
    Get-NetConnectionProfile | Set-NetConnectionProfile -NetworkCategory Private
    ```

2. **Configure WinRM**: Configures WinRM on the local workstation.
    ```powershell
    winrm quickconfig
    ```

3. **Set Trusted Hosts**: Sets the  hoststrusted for WinRM.
    ```powershell
    Set-Item -Path WSMan:\localhost\Client\TrustedHosts -Value 10.0.0.*
    ```

4. **Copy and Import Certificate**: Copies the certificate from the remote computer and imports it into the local certificate store.
    ```powershell
    $PSSessionOption = New-PSSessionOption -SkipCACheck
    $red = New-PSSession -ComputerName Blue -Credential (Get-Credential) -SessionOption $PSSessionOption -UseSSL
    copy-item -Fromsession $red c:\cert.cer -Destination c:\cert.cer
    Import-Certificate -FilePath c:\cert.cer -CertStoreLocation Cert:\LocalMachine\root\
    Import-Certificate -FilePath c:\cert.cer -CertStoreLocation Cert:\LocalMachine\TrustedPublisher
    ```

By following these instructions, you can set up PowerShell remoting between the two computers.
