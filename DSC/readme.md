# Active Directory Configuration Script

This PowerShell script automates the setup and configuration of an Active Directory Domain Controller using Desired State Configuration (DSC).

## Prerequisites

- PowerShell 5.1 or later
- Administrator privileges on the machine where the script will be executed

## Modules Installed

The script installs the following PowerShell modules:
- PSDscResources
- ActiveDirectoryDsc
- ComputerManagementDsc
- NetworkingDsc
- xDHCPServer

## Configuration Data

The script uses the following configuration data:
- **Nodename**: The name of the node (computer) where the script is executed.
- **Role**: The role of the node, set to "Primary DC".
- **DomainName**: The name of the Active Directory domain, set to "lab.net".
- **IPAddress**: The IP address of the node, set to '172.16.0.10'.
- **PSDscAllowPlainTextPassword**: Allows plain text passwords, set to `$true`.

## Script Overview

1. **Install Package Provider and Trust PS Gallery**:
    ```powershell
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
    ```

2. **Install DSC Modules**:
    ```powershell
    Install-Module PSDscResources, ActiveDirectoryDsc, ComputerManagementDsc, NetworkingDsc, xDHCPServer -force -Verbose
    ```

3. **Define Configuration Data**:
    ```powershell
    $ConfigData = @{
        AllNodes = @(
            @{
                Nodename    = "$env:Computername"
                Role        = "Primary DC"
                DomainName  = "lab.net"
                IPAddress   = '172.16.0.10'
                PSDscAllowPlainTextPassword = $true
            }
        )
    }
    ```

4. **Configure Reboot on Node**:
    ```powershell
    [DSCLocalConfigurationManager()]
    Configuration ConfigureRebootOnNode
    {
        Param ($ComputerName)
        
        Node $ComputerName
        {
            Settings
            {
                RebootNodeIfNeeded = $true
                ActionAfterReboot = 'ContinueConfiguration'
                ConfigurationMode = 'ApplyAndAutoCorrect'
                ConfigurationModeFrequencyMins  = 15
            }
        }
    }
    ConfigureRebootOnNode -ComputerName $env:Computername -Verbose
    Set-DscLocalConfigurationManager -Path .\ConfigureRebootOnNode -Verbose
    ```

5. **Run Active Directory Configuration**:
    ```powershell
    configuration DomainLab
    {
        param
        (
            [Parameter(Mandatory)]
            [pscredential]$safemodeAdministratorCred,
            [Parameter(Mandatory)]
            [pscredential]$domainCred,
            [Parameter(Mandatory)]
            [pscredential]$NewADUserCred,
            [Parameter(Mandatory)]
            [string]$NewADUser
        )
        
        Import-DscResource -ModuleName PSDscResources 
        Import-DscResource -module xDHCpServer
        Import-DscResource -ModuleName 'ActiveDirectoryDsc'
        Import-DscResource -ModuleName 'ComputerManagementDsc'
        Import-DscResource -ModuleName 'NetworkingDsc'
        
        Node $AllNodes.Where{$_.Role -eq "Primary DC"}.Nodename
        {
            # Configuration details...
        }
    }
    
    DomainLab -configurationData $ConfigData `
    -safemodeAdministratorCred (New-Object System.Management.Automation.PSCredential ('guest', (ConvertTo-SecureString $SafeModePW -AsPlainText -Force))) `
    -domainCred (New-Object System.Management.Automation.PSCredential ('Administrator', (ConvertTo-SecureString $SafeModePW -AsPlainText -Force))) `
    -NewADUserCred (New-Object System.Management.Automation.PSCredential ($NewADUser, (ConvertTo-SecureString $SafeModePW -AsPlainText -Force))) -NewADUser $NewADUser
    
    Start-DscConfiguration -Wait -Force -Verbose -ComputerName $env:Computername -Path .\DomainLab
    ```

## Usage

1. Open PowerShell with Administrator privileges.
2. Navigate to the directory containing the `Active Directory.ps1` script.
3. Execute the script:
    ```powershell
    .\Active Directory.ps1
    ```

## Notes

- Ensure that the machine's network settings and firewall rules allow for the necessary communication for Active Directory and DHCP services.
- The script sets up a basic Active Directory environment and may need to be customized for specific organizational requirements.

## License

This script is provided "as-is" without any warranty. Use at your own risk.