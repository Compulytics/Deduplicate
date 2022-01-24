function Deduplicate{
	param([string]$FilePath, [string]$Action, [string]$NewDir)
	$FileTable = @()
	$HashTable = @{}
	Get-ChildItem $FilePath -Recurse -Force | Sort-Object -Property FullName -Descending | ForEach-Object {
		try {
			$CurrentFile = $_.FullName
			$CurrentHash = Get-FileHash $_.FullName -Algorithm MD5 | Select Hash
			$CurrentHashValue = $CurrentHash.Hash
			if ($CurrentHash.Hash){
				if ($CurrentHashValue -ne "D41D8CD98F00B204E9800998ECF8427E"){
					$FilePair = "$CurrentHashValue|$CurrentFile"
					$FileTable += "$FilePair"
					Write-Host "Processed File $_"
				}
			}
			else{
			}
		}
		catch {}
	}
	foreach ($HashName in $FileTable){
		$I=1
		$Hash = $HashName.Split("|")[-0]
		$File = $HashName.Split("|")[-1]
		if ($HashTable.ContainsKey($Hash)){
			$WriteHash = $HashTable[$Hash]
			if ($Action -eq "D"){
				Remove-Item -Path $File -Force -ErrorAction Stop
				Write-Host "$File Deleted."
				Add-Content Dedup_Report.csv "$WriteHash,$File,$Hash,Deleted"
			}
			elseif ($Action -eq "L"){
				Write-Host "$File Duplicate Logged."
				Add-Content Dedup_Report.csv "$WriteHash,$File,$Hash,Logged"	
			}
			elseif ($Action -eq "C"){
				Write-Host "$File Duplicate Not Copied."
				Add-Content Dedup_Report.csv "$WriteHash,$File,$Hash,Not Copied"
			}
			else{
				Write-Host "ERROR: Invalid Action."
			}
		}
		else{
			Write-Host "$File Original File Discovered."
			$HashTable[$Hash] = $File
			$FileDestinationName = Split-Path $File -leaf
			$FileDestinationPath = "$NewDir\$FileDestinationName"
			if ($Action -eq "C"){
				if (Test-Path -Path $FileDestinationPath -PathType Leaf){
					$NewFileDestinationName = "$NewDir\$I-$FileDestinationName"
					while (Test-Path -Path $NewFileDestinationName -PathType Leaf){
						$I++
						$NewFileDestinationName = "$NewDir\$I-$FileDestinationName"
					}
					Copy-Item $File -Destination $NewFileDestinationName
				}
				else{
					Copy-Item $File -Destination $NewDir
				}
			}
			else{
			}
		}
	}
}
function HELP{
	Write-Host "USAGE:"
	Write-Host "./THISPROGRAM FILE_PATH ACTION *DESTINATION_DIRECTORY*"
	Write-Host "----------------------------------------------------------"
	Write-Host "|--                      ACTIONS                       --|"
	Write-Host "|--------------------------------------------------------|"
	Write-Host "|                                                        |"
	Write-Host "| Copy Originals to *DESTINATION_DIRECTORY*............C |"
	Write-Host "| Delete doubles.......................................D |"
	Write-Host "| Log doubles..........................................L |"
	Write-Host "|                                                        |"
	Write-Host "----------------------------------------------------------"
}
$UserInput_FilePath=$args[0]
$UserInput_Action=$args[1]
$UserInput_NewDir=$args[2]
Remove-Item Dedup_Report.csv -ErrorAction SilentlyContinue
if ($UserInput_FilePath){
	if ($UserInput_Action){
		if (Test-Path -Path $UserInput_FilePath) {
			if ($UserInput_Action -eq "D"){
				Add-Content Dedup_Report.csv 'Original File,Duplicate File,File Hash,Action'
				Deduplicate $UserInput_FilePath $UserInput_Action
			}
			elseif ($UserInput_Action -eq "L"){
				Add-Content Dedup_Report.csv 'Original File,Duplicate File,File Hash,Action'
				Deduplicate $UserInput_FilePath $UserInput_Action
			}
			elseif ($UserInput_Action -eq "C"){
				if ($UserInput_NewDir){
					if (Test-Path -Path $UserInput_NewDir) {
							Add-Content Dedup_Report.csv 'Original File,Duplicate File,File Hash,Action'
							Deduplicate $UserInput_FilePath $UserInput_Action $UserInput_NewDir
					}
					else{
						Write-Host "Destination folder does not exist."
					}
				}
				else{
					Write-Host "No destination folder specified."
				}
			}
			else{
				HELP
			}
		} else {
			Write-Host "Specified path does not exist."
		}
	}
	else{
		HELP
	}
}
else{
	HELP
}
