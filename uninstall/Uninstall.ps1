
# get a list of installed software
$list = Get-WmiObject -Class Win32_Product | Select-Object -Property Name

# loop over package you want to remove so both x86 and x64 are removed
foreach ($i in ($list.name -cmatch "Microsoft Visual C\++ 2010")) {
  $MyApp = Get-WmiObject -Class Win32_Product | Where-Object{$_.Name -eq "$i"} # pass package into variable
  $MyApp.Uninstall() # use the uninstall to remove the package listed in variable
  
  # cross check package is gone!
  if(Get-WmiObject -Class Win32_Product | Where-Object{$_.Name -eq "$i"} -eq $null) {
    write-output "Package is not present"
  } else {
    write-output "package still installed"
  }
  
}
