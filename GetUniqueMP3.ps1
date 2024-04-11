$MySrcDir = "C:\Users"
$MyDestDir = "C:\Music"
$FileCount = 1
$FileHashes = @{}
$DouplicateSize = 0
get-childitem -LiteralPath $MySrcDir -Recurse -Force | Foreach-Object {
	if ($_.Directory -and $_.Name -match ".mp3" -and !($_.Name -match ".part")){
		Write-Host -NoNewline "Processing"$_.Name"............"
		$CurrentHash = Get-FileHash -LiteralPath $_.FullName -Algorithm MD5 | Select Hash
		Write-Host $CurrentHash.Hash
		if ($FileHashes.ContainsKey($CurrentHash.Hash)){
			Write-Host $_.Name"is a douplicate of"$FileHashes[$CurrentHash.Hash]
			$DouplicateSize += $_.Length
		}
		else{
			$FileHashes[$CurrentHash.Hash] = $_.FullName
			$DestFile = ""
			$DestFile += $MyDestDir
			$DestFile += "\"
			$DestFile += $_.Name
			While (Test-Path -LiteralPath $DestFile) {
				$DestFile = ""
				$DestFile += $MyDestDir
				$DestFile += "\"
				$DestFile += [string]$FileCount
				$DestFile += "-"
				$DestFile += $_.Name
				$FileCount += 1
			}
			$FileCount = 1
			Write-Host "Copying"$_.Name
			Copy-Item -LiteralPath $_.FullName -Destination $DestFile
		}
	}
}
if ($DouplicateSize -lt 1024){
	Write-Host "*******************************************************"
	Write-Host "Total duplicate size: $DouplicateSize Bytes"
	Write-Host "*******************************************************"
}
elseif ($DouplicateSize -lt 1048576){
	$DouplicateSize = [math]::Round($DouplicateSize/1024)
	Write-Host "*******************************************************"
	Write-Host "Total duplicate size: $DouplicateSize KiloBytes"
	Write-Host "*******************************************************"
}
elseif ($DouplicateSize -lt 1073741824){
	$DouplicateSize = [math]::Round($DouplicateSize/1048576)
	Write-Host "*******************************************************"
	Write-Host " Total duplicate size: $DouplicateSize MegaBytes"
	Write-Host "*******************************************************"
}
elseif ($DouplicateSize -lt 137438953472){
	$DouplicateSize = [math]::Round($DouplicateSize/1073741824)
	Write-Host "*******************************************************"
	Write-Host " Total duplicate size: $DouplicateSize GigaBytes"
	Write-Host "*******************************************************"
}
else{
	$DouplicateSize = [math]::Round($DouplicateSize/137438953472)
	Write-Host "*************************************************"
	Write-Host " Total duplicate size: $DouplicateSize TeraBytes"
	Write-Host "*************************************************"
}
