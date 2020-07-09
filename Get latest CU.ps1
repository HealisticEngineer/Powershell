###  Example code
###  This is meant only as example
###  improved over youtube video version
# Variables
$hashtable =@{
    path = "D:\download"
}

# Array of currently active versions
$array =@(
    "https://www.microsoft.com/en-us/download/confirmation.aspx?id=100809",
    "https://www.microsoft.com/en-us/download/confirmation.aspx?id=56128",
    "https://www.microsoft.com/en-us/download/confirmation.aspx?id=56975"
)
# Download latest CU
Import-Module BitsTransfer
$array | ForEach-Object {
    $CU = (iwr $_ -UseBasicParsing).links | Where-Object {$_ -match "https://download.microsoft.com/download"} 
    $DownloadURL  = ($cu |Select-Object -first 1).href
    $file = $DownloadURL -split ('/') | Select-Object -last 1
    write-output "checking if $file already exists"
    if(!(Test-Path "$($hashtable.path)\$file" -PathType Leaf)){
        Write-Output "downloading $file"
        write-output "from $downloadurl"
        Start-BitsTransfer -Source $downloadurl -Destination "$($hashtable.path)\$file" 
    } else {write-output "File $file already exists"}
}

# update with newest version
(Get-ChildItem -Path $hashtable.path).VersionInfo | Sort-Object -Property ProductVersion -Descending
