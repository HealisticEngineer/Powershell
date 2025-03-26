# function to list installed software
function Get-InstalledSoftware {
  Get-WmiObject -Class Win32_Product | Select-Object -Property Name
}


# create function to unstinstall software
function Uninstall-Software {
  param(
    [Parameter(Mandatory=$true)][string]$SoftwareName,
    [Parameter(Mandatory=$false)][string]$uninstallswitch
  )

  # if software string is containers ++ then escape it, example here is Microsoft Visual C++ 2010 which has ++ in it and it needs to be escaped
  $SoftwareName = $SoftwareName -replace "\+\+", "\++"

  $MyApp = Get-WmiObject -Class Win32_Product | Where-Object{$_.Name -eq "$SoftwareName"}

  # check if sofware is installed
  if ($MyApp -eq $null) { write-output "Software is not installed"; return }
  
  # if software is installed then uninstall
  if ($uninstallswitch -ne $null) { $MyApp.Uninstall($uninstallswitch) }
  if ($uninstallswitch -eq $null) { $MyApp.Uninstall() }
  
  # cross check package is gone!
  if(Get-WmiObject -Class Win32_Product | Where-Object{$_.Name -eq "$SoftwareName"} -eq $null) {
    write-output "Software is uninstall sccessfully"
  } else {
    write-output "Software still installed"
  }
}
