# boot straping
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
# Trust PS Gallery
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

# DSC Active Directory
Install-Module PSDscResources, ActiveDirectoryDsc, ComputerManagementDsc, NetworkingDsc, xDHCPServer -force -Verbose

#  Varibles for Create Mof
$SafeModePW = 'NeverSafe2Day'
$NewADUser = 'ADUser'
 
# Configuration Data for AD
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

# Run script configure Active Directory
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
 
    #Import-DscResource -ModuleName 'PSDesiredStateConfiguration'
    Import-DscResource -ModuleName PSDscResources 
    Import-DscResource -module xDHCpServer
    Import-DscResource -ModuleName 'ActiveDirectoryDsc'
    Import-DscResource -ModuleName 'ComputerManagementDsc'
    Import-DscResource -ModuleName 'NetworkingDsc'
    Node $AllNodes.Where{$_.Role -eq "Primary DC"}.Nodename
    {
        
        LocalConfigurationManager
        {
            ActionAfterReboot = 'ContinueConfiguration'            
            ConfigurationMode = 'ApplyAndAutoCorrect'
            RebootNodeIfNeeded = $true
            ConfigurationModeFrequencyMins  = 15
        }

        NetIPInterface DisableDhcp
        {
            InterfaceAlias = 'Ethernet'
            AddressFamily  = 'IPv4'
            Dhcp           = 'Disabled'
        }

        IPAddress NewIPv4Address
        {
            IPAddress      = $Node.IPAddress
            InterfaceAlias = 'Ethernet'
            AddressFamily  = 'IPV4'
        }

        DefaultGatewayAddress SetDefaultGateway
        {
            Address        = '172.16.0.1'
            InterfaceAlias = 'Ethernet'
            AddressFamily  = 'IPv4'
        }

        DnsServerAddress PrimaryAndSecondary
        {
            Address        = '172.16.0.10','8.8.8.8'
            InterfaceAlias = 'Ethernet'
            AddressFamily  = 'IPv4'
        }   

        WindowsFeature DNS
        {
            Ensure = "Present"
            Name = "DNS"
        }

        WindowsFeature DNSTools
        {
            Ensure = "Present"
            Name = "RSAT-DNS-Server"
        }
        WindowsFeature DHCP
        {
            Name = 'DHCP'
            Ensure = 'PRESENT'
            IncludeAllSubFeature = $true                                                                                                                              
        }

        WindowsFeature DHCPTools
        {
            DependsOn= '[WindowsFeature]DHCP'
            Ensure = 'Present'
            Name = 'RSAT-DHCP'
            IncludeAllSubFeature = $true
        }

        WindowsFeature 'ADDS'
        {
            Name   = 'AD-Domain-Services'
            Ensure = 'Present'
        }

        WindowsFeature 'RSAT'
        {
            Name   = 'RSAT-AD-PowerShell'
            Ensure = 'Present'
        }

        WindowsFeature 'RSATGUI'
        {
            Name   = 'RSAT-ADDS'
            Ensure = 'Present'
            IncludeAllSubFeature = $true
        }


        ADDomain 'NewDomain'
        {
            DomainName                    = $Node.DomainName
            Credential                    = $domainCred
            SafemodeAdministratorPassword = $safemodeAdministratorCred
            ForestMode                    = 'WinThreshold'
        }

        PendingReboot RebootAfterDomainJoin
        {
            Name = 'DomainJoin'
        }


        WaitForADDomain DscForestWait
        {
            DomainName = $Node.DomainName
            WaitTimeout = 600
            DependsOn = "[PendingReboot]RebootAfterDomainJoin"
        }

        ADOrganizationalUnit 'Office'
        {
            Name                            = 'Office'
            Path                            = 'DC=lab,DC=net'
            ProtectedFromAccidentalDeletion = $true
            Description                     = 'Offices'
            Ensure                          = 'Present'
        }

        ADOrganizationalUnit 'Zurich'
        {
            Name                            = 'Zurich'
            Path                            = 'OU=Office,DC=Lab,DC=net'
            ProtectedFromAccidentalDeletion = $true
            Description                     = 'Zurich Office'
            Ensure                          = 'Present'
        }

        ADOrganizationalUnit 'Budapest'
        {
            Name                            = 'Budapest'
            Path                            = 'OU=Office,DC=Lab,DC=net'
            ProtectedFromAccidentalDeletion = $true
            Description                     = 'Budapest Office'
            Ensure                          = 'Present'
        }
        
        ADOrganizationalUnit 'NewYork'
        {
            Name                            = 'NewYork'
            Path                            = 'OU=Office,DC=Lab,DC=net'
            ProtectedFromAccidentalDeletion = $true
            Description                     = 'NewYork Office'
            Ensure                          = 'Present'
        }


        ADUser FirstUser
        {
            DomainName = $Node.DomainName
            UserName = $NewADUser
            Password = $NewADUserCred
            Ensure = "Present"
            DependsOn = "[WaitForADDomain]DscForestWait"
        }
        

        xDhcpServerAuthorization LocalServerActivation
        {
        Ensure = 'Present'
        }
        xDhcpServerScope Scope
        {
            Ensure = 'Present'
            IPEndRange = '172.16.0.254'
            IPStartRange = '172.16.0.50'
            ScopeID = '172.16.0.0'
            Name = 'Lab-Range'
            SubnetMask = '255.255.255.0'
            LeaseDuration = ((New-TimeSpan -Hours 8 ).ToString())
            State = 'Active'
            AddressFamily = 'IPv4'
            DependsOn = "[WaitForADDomain]DscForestWait"
        }
        xDhcpServerOption Option
        {
            Ensure = 'Present'
            ScopeID = '172.16.0.0'
            DnsDomain = 'lab.net'
            DnsServerIPAddress = '172.16.0.10','8.8.8.8'
            Router = '172.16.0.1'
            AddressFamily = 'IPv4'
            DependsOn = "[WaitForADDomain]DscForestWait"
        }

    }
}


DomainLab -configurationData $ConfigData `
-safemodeAdministratorCred (New-Object System.Management.Automation.PSCredential ('guest', (ConvertTo-SecureString $SafeModePW -AsPlainText -Force))) `
-domainCred (New-Object System.Management.Automation.PSCredential ('Administrator', (ConvertTo-SecureString $SafeModePW -AsPlainText -Force))) `
-NewADUserCred (New-Object System.Management.Automation.PSCredential ($NewADUser, (ConvertTo-SecureString $SafeModePW -AsPlainText -Force))) -NewADUser $NewADUser
# Run DSC
Start-DscConfiguration -Wait -Force -Verbose -ComputerName $env:Computername -Path .\DomainLab
