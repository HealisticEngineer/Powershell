<#
    Code Type: Function
    Description: Restore the missing Package(*.msi)/Patches(*.msp) files from another remote source (machine or folder).
    Author: Ahmad Gad
    Contact Email: ahmad.gad@jemmpress.com, ahmad.adel@jemmail.com
    WebSite: http://ahmad.jempress.com
    Created On: 21/09/2016
    Updated On: 11/03/2017
	Title: Restore-InstallerFiles
    Minimum PowerShell Version: 2.0
    Minimum CLR Version: 2.0

	Description: This script was designed as a fix Windows "Installer" by restoring the missing Package(*.msi)/Patches(*.msp) files with the following steps:
		1. Identifying the missing files.
		2. Crawl the missing files from specified folder or other healthy machine.
	
	Examples:
	---------
	.\Restore-InstallerFiles.ps1 -SourceMachine "Machine1", "Machine2", "Machine3";
	.\Restore-InstallerFiles.ps1 -SourceFolder "D:\InstallerFiles", "E:\InstallerFiles", "\\MachineX\D$\MSI Files";
	.\Restore-InstallerFiles.ps1 -SourceFolder "D:\InstallerFiles", "E:\InstallerFiles", "D:\InstallerFiles2" -LogFile "D:\Log.txt";

    # For further details, please run "Get-Help .\Restore-InstallerFiles.ps1 -Detailed;";
#>

<#
      .SYNOPSIS
      Restoring the missing Package(*.msi)/Patches(*.msp) files from another source folder(s) or machine(s).
      .DESCRIPTION
      Detects the missing Package(*.msi)/Patches(*.msp) and restore them from another source folder(s) or another healthy machine(s).
      .EXAMPLE
      Restore-InstallerFiles -SourceFolder "D\installer_bak";
      .EXAMPLE
      Restore-InstallerFiles -SourceFolder "D\installer_bak", "D\installer_bak2", "E\installer_bak3";
	  .EXAMPLE
      Restore-InstallerFiles -SourceMachine "MachineName";
	  .EXAMPLE
      Restore-InstallerFiles -SourceMachine "Machine1_Name", "Machine2_Name", "Machine3_Name", "Machine4_Name";
	  .EXAMPLE
      Restore-InstallerFiles -SourceMachine "MachineName" -LogFile "D:\Log.txt";
	  .EXAMPLE
      Restore-InstallerFiles -SourceMachine "MachineName" -Verbose;
	  .EXAMPLE
      Restore-InstallerFiles -SourceMachine "MachineName" -Verbose -LogFile "D:\Log.txt";
	  .EXAMPLE
      Restore-InstallerFiles -ScanOnly -Verbose -LogFile "D:\Log.txt";
	  .EXAMPLE
      Restore-InstallerFiles -ScanOnly;
      .PARAMETER SourceMachine
        Alias: M
        Data Type: System.String[]
        Mandatory: True
        Description: The name of the source machine(s) where the script can find the missing files there, and restore them to the target machine with the correct names.
        Example(s): "Machine1_Name", "Machine2_Name", "Machine3_Name", "Machine4_Name"
        Default Value: N/A
        Notes: This parameter is a mandatory if the the "SourceFolder" not specified.
      .PARAMETER SourceFolder
        Alias: F
        Data Type: System.String[]
        Mandatory: True
        Description: The source folder(s) where the script can find the missing files there, and restore them to the target machine with the correct names.
        Example(s): "D\installer_bak", "D\installer_bak2", "E\installer_bak3"
        Default Value: N/A
        Notes: This parameter is a mandatory if the the "SourceMachine" not specified.
      .PARAMETER ScanOnly
        Alias: S
        Data Type: Switch
        Mandatory: True
        Description: Only scan for the missing files and then display them without attempting the fix.
        Example(s): N/A
        Default Value: N/A
        Notes: This parameter is a mandatory and cannot be combined with the two parameters "SourceMachine" or "SourceFolder".
      .PARAMETER LogFile
        Alias: L
        Data Type: System.String
        Mandatory: False
        Description: The location of the output transcript logging file.
        Example(s): "D:\Log.txt"
        Default Value: N/A
        Notes: N/A
#>
[CmdletBinding()]
Param
(
    [Parameter(Mandatory=$True, Position=0, ParameterSetName="M")][Alias("M")][String[]]$SourceMachine,
    [Parameter(Mandatory=$True, Position=1, ParameterSetName="F")][Alias("F")][String[]]$SourceFolder,
    [Parameter(Mandatory=$True, Position=2, ParameterSetName="S")][Alias("S")][Switch]$ScanOnly,
    [Parameter(Mandatory=$False, Position=3)][Alias("L")][String]$LogFile
)
#region Public Functions
Function Restore-InstallerFiles
{
	<#
      .SYNOPSIS
      Restoring the missing Package(*.msi)/Patches(*.msp) files from another source folder(s) or machine(s).
      .DESCRIPTION
      Detects the missing Package(*.msi)/Patches(*.msp) and restore them from another source folder(s) or another healthy machine(s).
      .EXAMPLE
      Restore-InstallerFiles -SourceFolder "D\installer_bak";
      .EXAMPLE
      Restore-InstallerFiles -SourceFolder "D\installer_bak", "D\installer_bak2", "E\installer_bak3";
	  .EXAMPLE
      Restore-InstallerFiles -SourceMachine "MachineName";
	  .EXAMPLE
      Restore-InstallerFiles -SourceMachine "Machine1_Name", "Machine2_Name", "Machine3_Name", "Machine4_Name";
	  .EXAMPLE
      Restore-InstallerFiles -SourceMachine "MachineName" -LogFile "D:\Log.txt";
	  .EXAMPLE
      Restore-InstallerFiles -SourceMachine "MachineName" -Verbose;
	  .EXAMPLE
      Restore-InstallerFiles -SourceMachine "MachineName" -Verbose -LogFile "D:\Log.txt";
	  .EXAMPLE
      Restore-InstallerFiles -ScanOnly -Verbose -LogFile "D:\Log.txt";
	  .EXAMPLE
      Restore-InstallerFiles -ScanOnly;
      .PARAMETER SourceMachine
        Alias: M
        Data Type: System.String[]
        Mandatory: True
        Description: The name of the source machine(s) where the script can find the missing files there, and restore them to the target machine with the correct names.
        Example(s): "Machine1_Name", "Machine2_Name", "Machine3_Name", "Machine4_Name"
        Default Value: N/A
        Notes: This parameter is a mandatory if the the "SourceFolder" not specified.
      .PARAMETER SourceFolder
        Alias: F
        Data Type: System.String[]
        Mandatory: True
        Description: The source folder(s) where the script can find the missing files there, and restore them to the target machine with the correct names.
        Example(s): "D\installer_bak", "D\installer_bak2", "E\installer_bak3"
        Default Value: N/A
        Notes: This parameter is a mandatory if the the "SourceMachine" not specified.
      .PARAMETER ScanOnly
        Alias: S
        Data Type: Switch
        Mandatory: True
        Description: Only scan for the missing files and then display them without attempting the fix.
        Example(s): N/A
        Default Value: N/A
        Notes: This parameter is a mandatory and cannot be combined with the two parameters "SourceMachine" or "SourceFolder".
      .PARAMETER LogFile
        Alias: L
        Data Type: System.String
        Mandatory: False
        Description: The location of the output transcript logging file.
        Example(s): "D:\Log.txt"
        Default Value: N/A
        Notes: N/A
    #>
	[CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$True, Position=0, ParameterSetName="M")][Alias("M")][String[]]$SourceMachine,
        [Parameter(Mandatory=$True, Position=1, ParameterSetName="F")][Alias("F")][String[]]$SourceFolder,
        [Parameter(Mandatory=$True, Position=2, ParameterSetName="S")][Alias("S")][Switch]$ScanOnly,
        [Parameter(Mandatory=$False, Position=3)][Alias("L")][String]$LogFile
    )

    #region Private Functions
    Function Copy-MissingFiles
    {
        [CmdletBinding()]
        Param
        (
            [Parameter(Mandatory=$True, Position=0)][Alias("SF")][String]$SourceFolder,
            [Parameter(Mandatory=$True, Position=1)][Alias("DF")][String]$DestinationFolder,
            [Parameter(Mandatory=$True, Position=2)][Alias("MF")][Ref]$MissingFiles,
            [Parameter(Mandatory=$True, Position=3)][Alias("FA")][String[]]$FilterArray
        )

        $Verbose = $PSCmdlet.MyInvocation.BoundParameters[“Verbose”].IsPresent -Eq $True;
        Write-Verbose "Validating the source path ""$SourceFolder"" ... ";
        Write-Verbose "-------------------------------------------------";

        Write-Host -NoNewline -ForegroundColor Yellow "Validating the source path ""$SourceFolder"" ... ";
        If(!(Test-Path $SourceFolder -PathType Container))
        {
            Write-Host -ForegroundColor Red "Could not access the source location ""$SourceFolder""!";
            Write-Verbose "Could not access the source location ""$SourceFolder""!";
            Return;
        }
        else
        {
            Write-Host -ForegroundColor Green "OK!";
            Write-Verbose "The source location is OK!";
        }

        Write-Host -ForegroundColor Cyan "Proceeding with crawling the missing file(s) from the source. Please be patient as it could take a while ... ";
        Write-Verbose "Proceeding with crawling the missing file(s) from the source ...";
        Write-Verbose "-------------------------------------------------------------";
        $mFiles = {$missedFiles}.Invoke();
        $count = $mFiles.Count;
        $c = $count.ToString("d2")
        $d = $c.Length;

        $files = Get-ChildItem -Path $SourceFolder\* -Include $FilterArray;
        $sourceFilesCount = $files.Count;
        Write-Verbose "Found ""$sourceFilesCount"" package/patch file(s) in the source location!";
        Write-Host -ForegroundColor Green "Found ""$sourceFilesCount"" package/patch file(s) in the source location!";
        $i = 0;
        ForEach($file in $files)
        { 
            $subject = $null;
            $revisionNumber = $null;

            $fileFullName = $file.FullName;
            Write-Verbose "";
            Write-Verbose "Processing the file:  $fileFullName";

            $revisionNumber = Get-FileRevisionNumber -File $fileFullName -Verbose:$Verbose;

            Write-Verbose "Revision Number:  $revisionNumber";

            ForEach($mFile in $mFiles)
            {
                $mName = $mFile.Name;
                $destinationFile  = "$DestinationFolder\$mName";

                $ext = $mFile.Name.Split(".")[1];
                $mSubject = $mFile.Subject;
                $mRevisionNumber = ([String]$mFile.RevisionNumber).Trim();

                if([String]::IsNullOrEmpty($mRevisionNumber) -eq $false -And [String]::IsNullOrEmpty($revisionNumber) -eq $false)
                {
                    If ($mRevisionNumber -eq $revisionNumber -or $revisionNumber.StartsWith($mRevisionNumber))
                    {
                        Write-Verbose "The file Revision Number (""$mRevisionNumber"") is matching with the missing file: $mName";
                        
                        $i++;
                        $index = $i.ToString("d$d");

                        Copy-TheMissingFile -SF $file.FullName -DF $destinationFile -Index $index -Count $c -Verbose:$Verbose;
                    
                        $silent = $mFiles.Remove($mFile);
                        Break;
                    }
                }
                else
                {
                    Write-Verbose "No ""Revision Number"" has been detected for the file ""$fileFullName""!";
                    Write-Verbose "Attempting to to verify with the ""Subject"" property for ""$fileFullName""...";
                    $subject = Get-FileSubject -File $fileFullName -Verbose:$Verbose;
                    Write-Verbose "Registry Subject: $mSubject";
                    Write-Verbose "File Subject: $subject";

                    If ($mSubject -eq $subject -and [String]::IsNullOrEmpty($subject) -eq $false)
                    {
                        Write-Verbose "The file Subject (""$mSubject"") is matching with the missing file: $mName";
                        $duplicate = $mFiles | ? {$_.Subject -eq $subject};
                        if ($duplicate.Count -gt 1)
                        {
                            Write-Host -ForegroundColor Red "$mName : Could not detect the Package Code for the file as well as diplicate display name ""$subject""";
                            Write-Verbose "$mName : Could not detect the Package Code for the file as well as diplicate display name ""$subject""";

                            Break;
                        }
                        else
                        {
                            $i++;
                            $index = $i.ToString("d$d");

                            Copy-TheMissingFile -SF $file.FullName -DF $destinationFile -Index $index -Count $c -Verbose:$Verbose;
                        
                            $silent = $mFiles.Remove($mFile);
                            Break;
                        }
                    }
                }

            }

            If ($mFiles.Count -eq 0)
            {
                Break;
            }
        }

        $MissingFiles.Value = $mFiles;
        Return $i;
    }

    Function Copy-TheMissingFile
    {
        [CmdletBinding()]
        Param
        (
            [Parameter(Mandatory=$True, Position=0)][Alias("SF")][String]$SourceFile,
            [Parameter(Mandatory=$True, Position=1)][Alias("DF")][String]$DestinationFile,
            [Parameter(Mandatory=$False, Position=2)][Alias("I")][String]$Index,
            [Parameter(Mandatory=$False, Position=2)][Alias("C")][String]$Count
        )

        Try
        {
            Write-Verbose "Attempting to copy from ""$SourceFile"" to ""$destinationFile"" ...";
            Copy-Item -Path $SourceFile -Destination $DestinationFile;
            Write-Host -ForegroundColor Yellow "[$index/$c] - $mName : $SourceFile  >>>>>  $DestinationFile";
            Write-Verbose "Success [$index/$c] - $mName : $fileFullName  >>>>>  $DestinationFile";
            Write-Verbose "";
        }
        Catch
        {
            $errMsg = $_.Exception.InnerException.Message;
            Write-Verbose "Failed to copy the file!";
            Write-Verbose "Error Message: $errMsg";            
        }
    }

    Function Get-MissingFiles
    {
        [CmdletBinding()]
        Param ()

        $regKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer";
        $rKeys = Get-ChildItem -Path $regKey -Recurse | ? {$_.Property -eq "LocalPackage"};

        $mFiles = New-Object System.Collections.Generic.List[PSObject];
        ForEach($key in $rKeys)
        {
            $file = [IO.FileInfo] $key.GetValue("LocalPackage");
            if(Test-Path -Path $file -PathType Leaf)
            {
                Continue;
            }

            $mFile = New-FileObject;
            $mFile.Name = $file.Name;
            if($file.Extension -eq ".msp")
            {
                $mFile.RevisionNumber = Get-ProductCodeGuid -CompressedGuid $key.PSChildName;
            }
            else
            {
                $chainKeys = $key.PSParentPath.Split("\");
                $productCodeCompString = $chainKeys[$chainKeys.Length - 1];
                $productCodeRegKeyString = $regKey = "Registry::HKEY_CLASSES_ROOT\Installer\Products\$productCodeCompString";
                If(Test-Path $productCodeRegKeyString)
                {
                    $productCodeRegKey = Get-Item -Path $productCodeRegKeyString;
                    $packageCode = $productCodeRegKey.GetValue("PackageCode");
                    Try
                    {
                        $mFile.RevisionNumber = Get-ProductCodeGuid -CompressedGuid $packageCode;
                    }
                    Catch
                    {
                        Write-Verbose "Failed to decompress the Product Code GUID!";
                    }
                }
                else
                {
                    $fullName = $file.FullName;
                    Write-Verbose "Failed to retrieve the RevisionNumber/PackageCode from registry for the file ""$fullName""!";
                }
            }

            $mFile.Subject = $key.GetValue("DisplayName");

            $mFiles.Add($mFile);
        }

        Return [PSObject[]]$mFiles;
    }

    Function Get-FileSubject
    {
        [CmdletBinding()]
        Param
        (
            [Parameter(Mandatory=$True, Position=0)][Alias("F")][String]$File
        )
        Try
        {
            $fileItem = Get-Item $File;
            $folder = $fileItem.Directory.FullName;
            $fileName = $fileItem.Name;
            $shell = New-Object -ComObject "Shell.Application";
            $objFolder = $shell.Namespace($folder);
            $objFolderItem = $objFolder.ParseName($fileName);
        
            $val = $objFolder.GetDetailsOf($objFolderItem, 22);

            Return $val;
        }
        Catch
        {
            $methods = $_.Exception.Data.Values.MethodName;
            $codeLine = $_.InvocationInfo.Line;
            $positionMessage = $_.InvocationInfo.PositionMessage;
            $ErrorMessage = $_.Exception.Message;
            
            Write-Verbose "Exception: $ErrorMessage";
            Write-Verbose "Source Method(s): $methods";
            Write-Verbose "Code Line: $codeLine";
            Write-Verbose "Position Message: $positionMessage";
            Write-Verbose $nullInstaller;
        }
    }

    Function Get-FileRevisionNumber
    {
        [CmdletBinding()]
        Param
        (
            [Parameter(Mandatory=$True, Position=0)][Alias("F")][String]$File
        )
        
        Write-Verbose "Enters ""Get-FileRevisionNumber"" ...";
        $WindowsInstaller = $null;
        $SummaryInfo = $null;
        Try
        {
            Write-Verbose "Creating a ""WindowsInstaller.Installer"" COM object ...";
            $WindowsInstaller = New-Object -ComObject "WindowsInstaller.Installer";
            If(!($WindowsInstaller))
            {
                Write-Verbose "Get-FileRevisionNumber: Failed to create the ""WindowsInstaller.Installer"" COM object!";
                Write-Host -ForegroundColor Red "Failed to access the metadata of the file ""$File""!";
                Return $null;
            }
            
            Write-Verbose """WindowsInstaller.Installer"" COM object has been created successfully!";
            Write-Verbose "";
            Write-Verbose "Retrieving the ""SummaryInfo"" of the file ""$File"" ...";

            [Object[]]$args = @($File, 0);
            $SummaryInfo = $WindowsInstaller.GetType().InvokeMember("SummaryInformation", [System.Reflection.BindingFlags]::GetProperty, $null, $WindowsInstaller, $args);

            If(!($SummaryInfo))
            {
                Write-Verbose "Get-FileRevisionNumber: Failed to get the summary info of the file ""$File""!";
                Write-Host -ForegroundColor Red "Failed to access the metadata of the file ""$File""!";
                Return $null;
            }

            [Object[]]$args = @(9);
            $rn = $SummaryInfo.GetType().InvokeMember("Property", [System.Reflection.BindingFlags]::GetProperty, $null, $SummaryInfo, $args);
            If(!($rn))
            {
                Write-Verbose "Get-FileRevisionNumber: Failed to get the revision number of the file ""$File""!";
                Write-Host -ForegroundColor Red "Failed to access the metadata of the file ""$File""!";
                Return $null;
            }

            Return $rn.ToString();
        }
        Catch
        {
            $methods = $_.Exception.Data.Values.MethodName;
            $codeLine = $_.InvocationInfo.Line;
            $positionMessage = $_.InvocationInfo.PositionMessage;
            $ErrorMessage = $_.Exception.Message;
            
            $nullInstaller = "Windows Installer is null? " + ($WindowsInstaller -eq $null);
            $nullSumInfo = "SummaryInfo is null? " + ($SummaryInfo -eq $null);
            Write-Verbose "Exception: $ErrorMessage";
            Write-Verbose "Source Method(s): $methods";
            Write-Verbose "Code Line: $codeLine";
            Write-Verbose "Position Message: $positionMessage";
            Write-Verbose $nullInstaller;
            Write-Verbose $nullSumInfo;
            
            Write-Host -ForegroundColor Red "Failed to access the metadata of the file ""$File""!";
            Return $null;
        }
        Finally
        {
            Write-Verbose "Exits ""Get-FileRevisionNumber""!";
        }
    }

    Function Get-ProductCodeGuid
    {
         [CmdletBinding()]
         [OutputType([System.String])]
         Param 
         (
             [Parameter(Mandatory=$True)][ValidatePattern('^[0-9a-fA-F]{32}$')][string]$CompressedGuid
         )

         $Indexes=New-Object System.Collections.Specialized.OrderedDictionary;
         $Indexes.Add(0,8); 
         $Indexes.Add(8,4); 
         $Indexes.Add(12,4); 
         $Indexes.Add(16, 2); 
         $Indexes.Add(18,2); 
         $Indexes.Add(20,2); 
         $Indexes.Add(22,2); 
         $Indexes.Add(24,2); 
         $Indexes.Add(26,2); 
         $Indexes.Add(28,2); 
         $Indexes.Add(30,2); 

         $Guid = '{';
         foreach ($index in $Indexes.GetEnumerator()) 
         {
            $part = $CompressedGuid.Substring($index.Key, $index.Value).ToCharArray();
            [Array]::Reverse($part);
            $Guid += $part -Join '';
         }
         
         $Guid = $Guid.Insert(9,'-').Insert(14, '-').Insert(19, '-').Insert(24, '-');
         $Guid += '}';

         Return $Guid;
    }

    Function Assert-LogFile
    {
        [CmdletBinding()]
        Param
        (
            [Parameter(Mandatory=$True, Position=0)][Alias("F")][String]$File
        )
        
        Write-Host -ForegroundColor Yellow "Log file specified!";
        Write-Verbose "Log file specified!";

        Write-Host -ForegroundColor Yellow -NoNewline "Validating the log file location ... ";
        Write-Verbose "Validating the log file location ... ";

        If (Test-Path -Path ([System.IO.FileInfo] $File).DirectoryName -PathType Container)
        {
            Write-Host -ForegroundColor Green "OK!";
            Write-Verbose "OK!";
        }
        else
        {
            Write-Host -ForegroundColor Red "Cannot access the specified location. Operation terminated!";
            Write-Verbose "Cannot access the specified location. Operation terminated!";
            Return $false;
        }

        $force = $false;
        If (Test-Path -Path $File -PathType Leaf)
        {
            Write-Host -ForegroundColor White "File already exists which action do you like to take?";
            $choice = Read-Host "[A]-Abort, [O]-Override or [P]-Append (Default is ""A"")";
            If(!($choice) -Or $choice -eq "A")
            {
                Return $false;
            }

            Switch ($choice)
            {
                "P"
                {
                    Return $True;
                }
                "O"
                {
                    $force = $True;
                }
                Default
                {
                    Return $false;
                }
            }
        }

        Write-Host -ForegroundColor Yellow -NoNewline "Attempting to create the log file ... ";
        Write-Verbose "Attempting to create the log file ... ";
  
        Try
        {
            Out-File -FilePath $File -Encoding UniCode -Force:$force;
            Write-Host -ForegroundColor Green "OK!";
            Write-Verbose "OK!";
            Return $True;
        }
        Catch
        {
            Write-Host -ForegroundColor Green "FAILED!";
            $errMsg = $_.Exception.InnerException.Message;
            Write-Verbose "Failed to create the file!";
            Write-Verbose "Error Message: $errMsg";
            Return $false          
        }
    }

    Function Start-Logging
    {
	    [CmdletBinding()]
        Param
        (
            [Parameter(Mandatory=$True, Position=0)][Alias("L")][String]$LogFile
        )

        $ErrorActionPreference="SilentlyContinue";
        Stop-Transcript | Out-Null;
        $ErrorActionPreference = "Continue";
        $Error.Clear();
        Try
        {
            $chd = Get-Help Start-Transcript;
            If($chd.Synopsis.Contains("[-IncludeInvocationHeader]"))
            {
                Start-Transcript -Path $LogFile -Append -IncludeInvocationHeader;
            }
            else
            {
                Start-Transcript -Path $LogFile -Append -Force;
            }
            
            Write-Verbose ([System.String]::Format("PSVersion: {0}", $PSVersionTable.PSVersion));
            Write-Verbose ([System.String]::Format("CLR Version: {0}", $PSVersionTable.CLRVersion));
            $windows = (Get-WmiObject -class Win32_OperatingSystem).Caption;
            $winVer = [System.Environment]::OSVersion.Version.ToString(); 
            $is64 = [System.Environment]::Is64BitOperatingSystem; 
            $sp = [System.Environment]::OSVersion.ServicePack; 

            Write-Verbose "OS: $windows";
            Write-Verbose "Win Ver: $winVer";
            Write-Verbose "Is 64 Bit: $is64";
            Write-Verbose "SP: $sp";

            $Global:JLogging = $True;
        }
        Catch
        {}
    }

    Function Stop-Logging
    {
	    [CmdletBinding()]
        Param
        (
        )

        Try
        {
            If($Global:JLogging)
            {
                $ErrorActionPreference="SilentlyContinue";
                Stop-Transcript;
                $ErrorActionPreference = "Continue";
                Remove-Variable -Scope "Global" -Name "JLogging";
            }
        }
        Catch
        {}
    }
    #endregion Private Functions

    #region Class
    Function New-FileObject
    {
        [CmdletBinding()]
        Param()

        $file = New-Object PSObject;
        $file | Add-Member -Type NoteProperty -Name "Name" -Value $null;
        $file | Add-Member -Type NoteProperty -Name "RevisionNumber" -Value $null;
        $file | Add-Member -Type NoteProperty -Name "Subject" -Value $null;

        Return $file;
    }
    #endregion Class

    $Error.Clear();
    $Verbose = $PSCmdlet.MyInvocation.BoundParameters[“Verbose”].IsPresent -Eq $True;
    If($Verbose)
    {
        Function Local:Write-Host() {};
    }

    If($LogFile)
    {
        If(!(Assert-LogFile -File $LogFile -Verbose:$Verbose))
        {
            Return;
        }

        Start-Logging -LogFile $LogFile;
    }

    If ($ScanOnly)
    {
       Write-Host -ForegroundColor White "ScanOnly Parameter has been specified!";
       Write-Verbose "ScanOnly Parameter has been specified!";
    }

    Write-Host -ForegroundColor Yellow -NoNewline "Scanning for the missing Package/Patch file(s) ... ";
    Write-Verbose "Scanning for the missing Package/Patch file(s) ... ";
    $missedFiles = Get-MissingFiles -Verbose:$Verbose;

    $foundCount = $missedFiles.Count;
    If($missedFiles -eq $null -Or $missedFiles.Count -eq 0)
    {
        Write-Host -ForegroundColor Green """0"" found!";
        Write-Verbose """0"" found!";
        Stop-Logging; Return;
    }

    Write-Host -ForegroundColor Red """$foundCount"" found!";
    Write-Verbose """$foundCount"" found!";

    If ($ScanOnly)
    {
       $mfs = $missedFiles | FT -A;
       Out-Host -InputObject $mfs;
       Stop-Logging;
       Return $missedFiles; 
    }

    Switch ($PsCmdlet.ParameterSetName)
    {
        "M"
        {
            foreach($sm in $SourceMachine)
            {
                $sm = $sm.TrimStart("\");
                $sm = $sm.TrimStart("/");
                $sm = $sm.TrimEnd("\");
                $sm = $sm.TrimEnd("/");

                $SourceFolder += "\\$sm\C$\Windows\Installer";
            }
        }
    }

    $destinationFolder = "$env:windir\Installer";

    $totalRestoredCount = 0;

    foreach($source in $SourceFolder)
    {
        $requiredExt = $missedFiles | Select @{Name="Ext"; Expression = {$_.Name.Split(".")[1]}} -Unique;
        [String[]] $filterArray = $requiredExt | Foreach {"*." + $_.ext};

        $newFoundCount = $missedFiles.Count;
        $restoredCount = Copy-MissingFiles -SourceFolder $source -DestinationFolder $destinationFolder -MissingFiles ([Ref] $missedFiles) -FilterArray $filterArray -Verbose:$Verbose;
        
        $totalRestoredCount += $restoredCount;

        if($SourceFolder.Count -gt 1)
        {
            Write-Host -ForegroundColor Green "[$restoredCount/$newFoundCount] had been restored so far!";
            Write-Verbose "[$restoredCount/$newFoundCount] had been restored so far!";
            Write-Verbose "===============================================================================";
        }

        Write-Host; Write-Host;
        Write-Verbose ""; Write-Verbose "";
        
        if($totalRestoredCount -eq $foundCount)
        {
            Break;
        }
    }
    
    Write-Host; Write-Host;
    Write-Verbose ""; Write-Verbose "";

    Write-Host -ForegroundColor Green "Operation Completed. [$totalRestoredCount/$foundCount] had been restored!";
    Write-Verbose "Operation Completed. [$totalRestoredCount/$foundCount] had been restored!";

    Write-Host;

    If($missedFiles -and $missedFiles.Count -gt 0)
    {
        Write-Host;
        Write-Host -ForegroundColor Yellow "The missing file(s):";
        Write-Host -ForegroundColor Yellow "--------------------";

        Write-Output $missedFiles | Ft -A;
        Write-Host;
    }

    Stop-Logging; Return;
}
#endregion Public Functions

$Error.Clear();
$Verbose = $PSCmdlet.MyInvocation.BoundParameters[“Verbose”].IsPresent -Eq $True;

Switch ($PsCmdlet.ParameterSetName)
{
    "M"
    {
        Return Restore-InstallerFiles -SourceMachine $SourceMachine -LogFile $LogFile -Verbose:$Verbose;
    }
    "F"
    {
         Return Restore-InstallerFiles -SourceFolder $SourceFolder -LogFile $LogFile -Verbose:$Verbose;
    }
    "S"
    {
        Return Restore-InstallerFiles -ScanOnly -LogFile $LogFile -Verbose:$Verbose;
    }
}
