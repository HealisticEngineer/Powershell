# ISO picker
class iso : System.Management.Automation.IValidateSetValuesGenerator {
    [String[]] GetValidValues() {
      $Global:iso = Get-ChildItem -Path $env:VBISO -Filter *.iso
      return ($Global:iso).name
    }
  }
  
  # Type picker
  class type : System.Management.Automation.IValidateSetValuesGenerator {
    [String[]] GetValidValues() {    
      $osdata = (& $env:vbpath\VBoxManage list ostypes | Select-String 'ID / Description:' | Where-Object {$_ -notmatch "Family ID:"}) -replace 'ID / Description:','' -replace ' ',''
      $os_array=@()
      $osdata | ForEach-Object {
      $os_array += $_.split("--")[0]
      }
      $Global:type = $os_array
      return ($Global:type)
    }
  }