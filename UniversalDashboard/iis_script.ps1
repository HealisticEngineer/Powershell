# Install IIS and dotnet core
Install-WindowsFeature "Web-Server","Web-Windows-Auth","Web-ASP","Web-Asp-Net","Web-Asp-Net45" -IncludeManagementTools

$maxAttempts = 30
$attemptCount = 0
$source = "https://download.visualstudio.microsoft.com/download/pr/633b17e5-a489-4da4-9713-5ddedf17a5f0/5c18f4203e837dd90ba3da59eee92b01/dotnet-hosting-2.1.15-win.exe"
$file = "C:\Windows\Temp\dotnet-hosting-2.1.15-win.exe"

Do {
    $attemptCount++
    Invoke-WebRequest $source -OutFile $file | Out-Null
} while (((Test-Path $file) -eq $false) -and ($attemptCount -le $maxAttempts))

Unblock-File -Path $file
Start-Process -FilePath $file -ArgumentList '/install','/quiet','/norestart' -Wait
# Clean up
Remove-Item -Force $file


Import-Module WebAdministration

# disable anonymous
Set-WebConfigurationProperty `
  -filter "/system.webserver/security/authentication/anonymousAuthentication" `
  -name "enabled" `
  -value "False"
# enable Windows authentication
Set-WebConfigurationProperty `
  -filter "/system.webserver/security/authentication/windowsAuthentication" `
  -name "enabled" `
  -value "True"

# download module
if(!(Get-PackageProvider -Name nuget)){
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.208 -Force
}
$udpath = "C:\inetpub\wwwroot"
Save-Module -Name UniversalDashboard -Path C:\temp\ -RequiredVersion 2.8.3 -Force 
Copy-Item -Path "C:\temp\UniversalDashboard\2.8.3\*" -Destination "$udpath" -Recurse

# enable windows forwarding
$webconf = get-content "$udpath\web.config"
$webconf = $webconf -replace 'forwardWindowsAuthToken="false"','forwardWindowsAuthToken="true"'
$webconf | set-content "$udpath\web.config"

# deploy test dashboard
$content = 'Start-UDDashboard -Wait -Dashboard (
    New-UDDashboard -Title "Hello, IIS" -Content {
        New-UDCard -Title "Hello, IIS"
    }
)'

$content | set-content "$udpath\dashboard.ps1"

IISReset /restart
