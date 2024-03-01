function Get-SqlServerBuild2022 {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [string]$currentVersion
    )

    # regex version example 16.0.4105.2
    $regex = ([regex]::new("(16\.\d{1}\.\d{4}\.\d+)"))

    # find version string
    $source = Invoke-WebRequest "https://sqlserverbuilds.blogspot.com/" 
    # find all matches
    $version = ($regex.Matches($source.Content) | Sort-Object Value -Descending | Select-Object -First 1).Value
    
    # if current version is not null, compare
    if ($currentVersion -ne $null) {
        if ($version -eq $currentVersion) {
            Write-Output "You are up to date"
        } else {
            return $version
        }
    }
    
}

function Get-SqlServerBuild2019 {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [string]$currentVersion
    )

    # regex version example 15.0.4105.2
    $regex = ([regex]::new("(15\.\d{1}\.\d{4}\.\d+)"))

    # find version string
    $source = Invoke-WebRequest "https://sqlserverbuilds.blogspot.com/" 
    # find all matches
    $version = ($regex.Matches($source.Content) | Sort-Object Value -Descending | Select-Object -First 1).Value
    
    # if current version is not null, compare
    if ($currentVersion -ne $null) {
        if ($version -eq $currentVersion) {
            Write-Output "You are up to date"
        } else {
            return $version
        }
    }
    
}

function Get-SqlServerBuild2017 {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [string]$currentVersion
    )

    # regex version example 14.0.4105.2
    $regex = ([regex]::new("(14\.\d{1}\.\d{4}\.\d+)"))

    # find version string
    $source = Invoke-WebRequest "https://sqlserverbuilds.blogspot.com/" 
    # find all matches
    $version = ($regex.Matches($source.Content) | Sort-Object Value -Descending | Select-Object -First 1).Value
    
    # if current version is not null, compare
    if ($currentVersion -ne $null) {
        if ($version -eq $currentVersion) {
            Write-Output "You are up to date"
        } else {
            return $version
        }
    }
    
}

# import content from buildversions.json
$builds = Get-Content -Path "buildversions.json" | ConvertFrom-Json

# check the build version in $builds vs the latest version from functions
$builds.sqlServerVersions | ForEach-Object {
    if ($_.version -eq "2017") { $latest = Get-SqlServerBuild2017 -currentVersion $_.buildVersion } 
    if ($_.version -eq "2019") { $latest = Get-SqlServerBuild2019 -currentVersion $_.buildVersion } 
    if ($_.version -eq "2022") { $latest = Get-SqlServerBuild2022 -currentVersion $_.buildVersion }
    
    if ($latest -ne $null) {
        Write-Output "New version available for $($_.version): $latest"
    }
}
