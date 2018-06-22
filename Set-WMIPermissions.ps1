Function Set-WMIPermissions {
    Param (
        [String]$Namespace = 'CIMV2',
        [String]$Account   = 'lab\Domain users',
        [String]$Computer  = $env:COMPUTERNAME
    )

    Function Get-Sid {
        Param (
            $Account
        )
        $ID = New-Object System.Security.Principal.NTAccount($Account)
        Return $ID.Translate([System.Security.Principal.SecurityIdentifier]).toString()
    }

    $SID = Get-Sid $Account
    $SDDL = "A;CI;CCSWWP;;;$SID"
    $DCOMSDDL = "A;;CCDCRP;;;$SID"
    $Reg = [WMICLASS]"\\$Computer\root\default:StdRegProv"
    $DCOM = $Reg.GetBinaryValue(2147483650,'software\microsoft\ole','MachineLaunchRestriction').uValue
    $Security = Get-WmiObject -ComputerName $Computer -Namespace "root\$Namespace" -Class __SystemSecurity
    $Converter = New-Object System.Management.ManagementClass Win32_SecurityDescriptorHelper
    $BinarySD = @($null)
    $Result = $Security.PsBase.InvokeMethod('GetSD', $BinarySD)
    $OutSDDL = $Converter.BinarySDToSDDL($BinarySD[0])
    $OutDCOMSDDL = $Converter.BinarySDToSDDL($DCOM)
    $NewSDDL = $OutSDDL.SDDL += '(' + $SDDL + ')'
    $NewDCOMSDDL = $OutDCOMSDDL.SDDL += '(' + $DCOMSDDL + ')'
    $WMIbinarySD = $Converter.SDDLToBinarySD($NewSDDL)
    $WMIconvertedPermissions = ,$WMIbinarySD.BinarySD
    $DCOMbinarySD = $Converter.SDDLToBinarySD($NewDCOMSDDL)
    $Result = $Security.PsBase.InvokeMethod('SetSD', $WMIconvertedPermissions)
    $Result = $Reg.SetBinaryValue(2147483650,'software\microsoft\ole','MachineLaunchRestriction', $DCOMbinarySD.binarySD)
    Write-Verbose 'WMI Permissions set'
}
