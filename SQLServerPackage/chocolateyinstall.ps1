# Inspired by https://www.cisecurity.org benchmarks
$ErrorActionPreference = 'Stop'; # stop on all errors
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$url        = 'https://download.microsoft.com/download/E/F/2/EF23C21D-7860-4F05-88CE-39AA114B014B/SQLServer2017-x64-ENU-Dev.iso'

# Inspired by @riezebosch's SQL Server packages at https://github.com/riezebosch/BoxstarterPackages/tree/master/sql-server

$pp = Get-PackageParameters


# Installation defaults
$cimInstanceProc = Get-CimInstance -ClassName Win32_Processor
# init variables
$numberOfLogicalProcessors = 0
$numberOfCores = 0
# Loop through returned objects
foreach ($processor in $cimInstanceProc)
{
    # increment number of processors
    $numberOfLogicalProcessors += $processor.NumberOfLogicalProcessors
    # increment number of cores
    $numberOfCores += $processor.NumberOfCores
}
if ($numberOfLogicalProcessors -eq 1)                {
    $dynamicMaxDop = [Math]::Round($numberOfCores / 2, [System.MidpointRounding]::AwayFromZero)
} elseif ($numberOfCores -ge 8) { $dynamicMaxDop = 8 }  else {$dynamicMaxDop = $numberOfCores }


# SQL Instance Name
$instancename = "MSSQLSERVER"

# Create ramdom password
$pass = (New-Guid).Guid


$arguments = ""
$arguments += "/q /INSTANCEID=$InstanceName /INSTANCENAME=$InstanceName /ADDCURRENTUSERASSQLADMIN "
$hashtable = @{
    SECURITYMODE="SQL"
    SAPWD="$pass"
    IACCEPTPYTHONLICENSETERMS = "True"
    IACCEPTSQLSERVERLICENSETERMS = "True"
    ACTION = "install"
    SUPPRESSPRIVACYSTATEMENTNOTICE = "False"
    ENU = "True"
    QUIET = "False"
    QUIETSIMPLE = "False"
    USEMICROSOFTUPDATE = "False"
    FEATURES = "SQL"
    HELP = "False"
    INDICATEPROGRESS = "False"
    X86 = "False"
    INSTALLSHAREDDIR = '"C:\Program Files\Microsoft SQL Server"'
    INSTALLSHAREDWOWDIR = '"C:\Program Files (x86)\Microsoft SQL Server"'
    SQLSVCINSTANTFILEINIT ="True"
    INSTANCEDIR = '"C:\MSSQL"'
    AGTSVCSTARTUPTYPE = "Automatic"
    COMMFABRICPORT = "0"
    COMMFABRICNETWORKLEVEL = "0"
    COMMFABRICENCRYPTION = "0"
    MATRIXCMBRICKCOMMPORT = "0"
    SQLSVCSTARTUPTYPE = "Automatic"
    SQLTEMPDBFILECOUNT = "$dynamicMaxDop"
    SQLTEMPDBFILESIZE = "1024"
    SQLTEMPDBFILEGROWTH = "512"
    SQLTEMPDBLOGFILESIZE = "1024"
    SQLTEMPDBLOGFILEGROWTH = "512"
    SQLUSERDBDIR="C:\MSSQL\Data"
    SQLUSERDBLOGDIR="C:\MSSQL\Log"
    SQLTEMPDBDIR="C:\MSSQL\TempDB"
    SQLTEMPDBLOGDIR="C:\MSSQL\TempDB"
    ADDCURRENTUSERASSQLADMIN="False"
    TCPENABLED="1"
    NPENABLED="0"
    BROWSERSVCSTARTUPTYPE="Automatic"
    SQLSYSADMINACCOUNTS = '"DESKTOP-HE1A346\TipsForITPros"'
}

foreach ($argument in $hashtable.GetEnumerator()) {
$arguments += "/$($argument.name)=$($argument.Value) "
}

$silentArgs = "$($arguments)"


$packageArgs = @{
  packageName   = $env:ChocolateyPackageName

  fileType      = 'EXE'
  url           = $url

  softwareName  = 'Microsoft SQL Server 2017 (64-bit)'
  checksum      = '315D88E0211DB6B5087848A6D12ECD32FB530F8B58F185100502626EF2E32E74'
  checksumType  = 'sha256'

  silentArgs   = $silentArgs
  validExitCodes= @(0, 3010)
}

# Download 
  $chocTempDir = $env:TEMP
  $tempDir = Join-Path $chocTempDir "$($env:chocolateyPackageName)"
  if ($env:chocolateyPackageVersion -ne $null) {
     $tempDir = Join-Path $tempDir "$($env:chocolateyPackageVersion)"; 
  }

  $tempDir = $tempDir -replace '\\chocolatey\\chocolatey\\', '\chocolatey\'
  if (![System.IO.Directory]::Exists($tempDir)) { 
    [System.IO.Directory]::CreateDirectory($tempDir) | Out-Null
  }

  $fileFullPath = Join-Path $tempDir "SQLServer2017-x64-ENU-Dev.iso"
  Get-ChocolateyWebFile @packageArgs -FileFullPath $fileFullPath





$MountResult = Mount-DiskImage -ImagePath $fileFullPath -StorageType ISO -PassThru
$MountVolume = $MountResult | Get-Volume
$MountLocation = "$($MountVolume.DriveLetter):"

Install-ChocolateyInstallPackage @packageArgs -File "$($MountLocation)\setup.exe"

Dismount-DiskImage -ImagePath $fileFullPath

# Post install steps 
if (!(Get-PackageProvider -Name nuget)){
  Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -force
}
if (!(Get-Module -ListAvailable -Name SQLSERVER)) {
    Install-module SQLServer -force
}
if (!(Get-Module -name SQLServer)){
    Import-Module SQLServer -force
}

try {
    # Set hidden instance
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL14.$InstanceName\MSSQLServer\SuperSocketNetLib" -Name HideInstance -Value 1 -Force | Out-Null
    #Change logfile to 20
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL14.$InstanceName\MSSQLServer" -Name NumErrorLogs -Value 20 -Force | Out-Null
    # change SQL Server port
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL14.$InstanceName\MSSQLServer\SuperSocketNetLib\Tcp\IPAll" -Name TcpDynamicPorts -Value '' -Force | Out-Null
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL14.$InstanceName\MSSQLServer\SuperSocketNetLib\Tcp\IPAll" -Name TcpPort -Value 1433 -Force | Out-Null

    # set startup flags
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL14.$InstanceName\MSSQLServer\Parameters" -Name SQLArg3 -Value '-T834' -Force | Out-Null
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL14.$InstanceName\MSSQLServer\Parameters" -Name SQLArg4 -Value '-T3226' -Force | Out-Null
} catch { Throw "issue setting security" }

# Set memory settings
try {
  $physicalMemory = ((Get-CimInstance -ClassName Win32_PhysicalMemory).Capacity | Measure-Object -Sum).Sum
  $physicalMemoryInMegaBytes = [Math]::Round($physicalMemory / 1MB)
  # Find how much to save for OS: 20% of total ram for under 15GB / 12.5% for over 20GB
  if ($physicalMemoryInMegaBytes -ge 20480)
  {$reservedOperatingSystemMemory = [Math]::Round((0.125 * $physicalMemoryInMegaBytes))} else {$reservedOperatingSystemMemory = [Math]::Round((0.2 * $physicalMemoryInMegaBytes))}
  $numberOfCores = (Get-CimInstance -ClassName Win32_Processor | Measure-Object -Property NumberOfCores -Sum).Sum
  # Get the number of SQL threads.
  if ($numberOfCores -ge 4) {$numberOfSqlThreads = 256 + ($numberOfCores - 4) * 8 } else {$numberOfSqlThreads = 0}
  $operatingSystemArchitecture = (Get-CimInstance -ClassName Win32_OperatingSystem).OSArchitecture
  # Find threadStackSize 1MB x86/ 2MB x64/ 4MB IA64
  if ($operatingSystemArchitecture -eq '32-bit'){$threadStackSize = 1} elseif ($operatingSystemArchitecture -eq '64-bit'){$threadStackSize = 2} else{$threadStackSize = 4}
  $maxMemory = $physicalMemoryInMegaBytes - $reservedOperatingSystemMemory - ($numberOfSqlThreads * $threadStackSize) - (1024 * [System.Math]::Ceiling($numberOfCores / 4))
  $QRYMemory ="
  EXEC sp_configure 'show advanced options', 1;
  RECONFIGURE;
  EXEC sp_configure 'max server memory', $maxMemory;
  RECONFIGURE;"
  Invoke-Sqlcmd -ServerInstance "$ENV:COMPUTERNAME" -Query $QRYMemory -Username 'sa' -Password "$pass" -DisableVariables -ErrorAction Stop
}
catch { throw "error setting memory"
$_ }

Try{
    $query = "
    --Change remote accesss
    EXEC sp_configure 'remote access', 0
    RECONFIGURE;
    --Remove guest from new databases
    USE [model];
    REVOKE CONNECT FROM guest;
    ALTER DATABASE [model] SET PAGE_VERIFY CHECKSUM;
    --Rename the SA account
    USE [master];
    ALTER LOGIN sa WITH NAME = [SQLADMIN];
    ALTER LOGIN [SQLADMIN] DISABLE;
    "
    Invoke-Sqlcmd -ServerInstance "$ENV:COMPUTERNAME" -Query $query -Username 'sa' -Password "$pass" -DisableVariables -ErrorAction Stop

} catch { throw "issue with settring database settings" }

# Change login mode
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL14.$InstanceName\MSSQLServer" -Name LoginMode -Value 1 -Force | Out-Null

Restart-service $instancename -Force
