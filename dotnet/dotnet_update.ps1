# Function to retrieve installed .NET and ASP.NET Core versions from specific directories.
function Get-dotnet {
    # declare folder paths
    $ASPNETCoreX86 = "C:\Program Files (x86)\dotnet\shared\Microsoft.aspnetcore"
    $ASPNETCoreX64 = "C:\Program Files\dotnet\shared\Microsoft.aspnetcore"
    $dotnetcoreX64 = "C:\Program Files\dotnet\shared\Microsoft.NETCore.App"
    $dotnetcoreX86 = "C:\Program Files (x86)\dotnet\shared\Microsoft.NETCore.App"

    # Create empty array for results
    $array = @()

    # test if folder exists X64
    if (Test-Path -Path "$dotnetcoreX64" ) {
        # if folder exists list directories, and collect versions
        $dotnetcoreVersionsX64 = (Get-ChildItem -Path "$dotnetcoreX64" -Directory).Name
        # create hashtable to store versions
        $dotnetcoreVersionsX64 | ForEach-Object {
            $hash = [ordered]@{ 
                "version" = $_
                "platform" = "x64" 
                "edition" = "dotnet"
            }
            $return = [PSCustomObject]$hash
            $array += $return
        }
    }
    # test if folder exists X86
    if (Test-Path -Path "$dotnetcoreX86" ) {
        # if folder exists list directories, and collect versions
        $dotnetcoreVersionsX86 = (Get-ChildItem -Path "$dotnetcoreX86" -Directory).Name
        # create hashtable to store versions
        $dotnetcoreVersionsX86 | ForEach-Object {
            $hash = [ordered]@{ 
                "version" = $_
                "Platform"  = "x86"
                "edition" = "dotnet"
            }
            $return = [PSCustomObject]$hash
            $array += $return
        }
    }

    # test if folder exists X64
    if (Test-Path -Path "$ASPNETCoreX64" ) {
        # if folder exists list directories, and collect versions
        $ASPcoreVersionsX64 = (Get-ChildItem -Path "$ASPNETCoreX64" -Directory).Name
        # create hashtable to store versions
        $ASPcoreVersionsX64 | ForEach-Object {
            $hash = [ordered]@{ 
                "version" = $_
                "Platform"  = "x64"
                "edition" = "aspnetcore"
            }
            $return = [PSCustomObject]$hash
            $array += $return
        }
    }
    # test if folder exists X86
    if (Test-Path -Path "$ASPNETCoreX86" ) {
        # if folder exists list directories, and collect versions
        $ASPcoreVersionsX86 = (Get-ChildItem -Path "$ASPNETCoreX86" -Directory).Name
        # create hashtable to store versions
        $ASPcoreVersionsX86 | ForEach-Object {
            $hash = [ordered]@{ 
                "version" = $_
                "Platform"  = "x86"
                "edition" = "aspnetcore"
            }
            $return = [PSCustomObject]$hash
            $array += $return
        }
    }

    # return array
    Return $array
}

# Function to check for updates to .NET or ASP.NET Core versions and generate download URLs for newer versions.
function Update-DotNet {
        # pipe line paramiter
        [CmdletBinding()]
            Param(
                [Parameter(ValueFromPipelineByPropertyName,Mandatory)]$version,
                [Parameter(ValueFromPipelineByPropertyName,Mandatory)][ValidateSet("x64","x86")]$platform,
                [Parameter(ValueFromPipelineByPropertyName,Mandatory)][ValidateSet("dotnet","aspnetcore")]$edition
    )

    Begin {
        # common param
        $AzureFeed = 'https://dotnetcli.azureedge.net/dotnet'
        # array of URL's for download
        $PayloadURL =@() 
    }

    process {
        # remove build so can check for latest of this version
        $channel = $version.SubString(0,3)

        # loop each version
        $VersionFileUrl = @()

        if ($edition -eq "dotnet") {
                $channel | ForEach-Object {
                    $VersionFileUrl += "$AzureFeed/Runtime/$_/latest.version"
                }   
            } elseif ($edition -eq "aspnetcore") {
                $channel | ForEach-Object {
                    $VersionFileUrl += "$AzureFeed/aspnetcore/Runtime/$_/latest.version"
                }
                
            } elseif ($edition -eq "windowsdesktop") {
                $VersionFileUrl = "$AzureFeed/WindowsDesktop/$Channel/latest.version" 
            }

        $SpecificVersion =@()
        $VersionFileUrl | ForEach-Object {
            $SpecificVersion += (Invoke-WebRequest -uri "$_").content
        }
        # check if version is higher
        if($SpecificVersion -gt $version){
            # loop over each version
            if ($edition -eq "dotnet") {
                $SpecificVersion | ForEach-Object {
                    $hash = [ordered]@{ 
                        "url" = "$AzureFeed/Runtime/$_/dotnet-runtime-$_-win-$platform.exe"
                    }
                    $return = [PSCustomObject]$hash
                    $PayloadURL += $return
                }   
            } elseif ($edition -eq "aspnetcore") {
                $SpecificVersion | ForEach-Object {
                    $hash = [ordered]@{ 
                        "url" = "$AzureFeed/aspnetcore/Runtime/$_/aspnetcore-runtime-$_-win-$platform.exe"
                    }
                    $return = [PSCustomObject]$hash
                    $PayloadURL += $return
                }
            }
        }
        
    }

    End{
        # change from output to download and install
        Return $PayloadURL
    }
}

# Function to download and install .NET or ASP.NET Core updates using the provided URLs.
function Start-dotnetupgrade {
    # pipe line paramiter
    [CmdletBinding()]
    Param(
        [Parameter(ValueFromPipelineByPropertyName,Mandatory)]$url
    )
       
    $url | ForEach-Object {
        $file = $_ -split('/') | Select-Object -Last 1
        Start-BitsTransfer -source $_ -Destination $file # download file
        #Installer       
        Start-Process -FilePath .\$file -ArgumentList "/q" -wait
    }  
}

# Set the working directory to c:\temp and initiate the update process.
If (-not (Test-Path -Path "c:\temp")) {New-Item -Path "c:\temp" -ItemType Directory}
Set-Location c:\temp
$update = Get-dotnet | Update-DotNet 
if($update -ne $null) { Start-dotnetupgrade $update.url }
