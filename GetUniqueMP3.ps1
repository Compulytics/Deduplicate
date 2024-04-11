$MySrcDir = "C:\Users"
$MyDestDir = "C:\Music"
$FileCount = 1
$FileHashes = @{}
$DuplicateSize = 0

Get-ChildItem -LiteralPath $MySrcDir -Recurse -Force | ForEach-Object {
    if ($_.Directory -and $_.Name -match ".mp3" -and !($_.Name -match ".part")) {
        Write-Verbose "Processing $($_.Name)............"
        $CurrentHash = Get-FileHash -LiteralPath $_.FullName -Algorithm MD5 | Select-Object -ExpandProperty Hash
        Write-Verbose $CurrentHash
        if ($FileHashes.ContainsKey($CurrentHash)) {
            Write-Verbose "$($_.Name) is a duplicate of $($FileHashes[$CurrentHash])"
            $DuplicateSize += $_.Length
        }
        else {
            $FileHashes[$CurrentHash] = $_.FullName
            $DestFile = Join-Path -Path $MyDestDir -ChildPath $_.Name
            while (Test-Path -LiteralPath $DestFile) {
                $DestFile = Join-Path -Path $MyDestDir -ChildPath "$FileCount-$($_.Name)"
                $FileCount++
            }
            Write-Verbose "Copying $($_.Name)"
            Copy-Item -LiteralPath $_.FullName -Destination $DestFile
        }
    }
}

if ($DuplicateSize -lt 1024) {
    Write-Output "*******************************************************"
    Write-Output "Total duplicate size: $DuplicateSize Bytes"
    Write-Output "*******************************************************"
}
elseif ($DuplicateSize -lt 1048576) {
    $DuplicateSize = [math]::Round($DuplicateSize / 1024)
    Write-Output "*******************************************************"
    Write-Output "Total duplicate size: $DuplicateSize KiloBytes"
    Write-Output "*******************************************************"
}
elseif ($DuplicateSize -lt 1073741824) {
    $DuplicateSize = [math]::Round($DuplicateSize / 1048576)
    Write-Output "*******************************************************"
    Write-Output "Total duplicate size: $DuplicateSize MegaBytes"
    Write-Output "*******************************************************"
}
elseif ($DuplicateSize -lt 137438953472) {
    $DuplicateSize = [math]::Round($DuplicateSize / 1073741824)
    Write-Output "*******************************************************"
    Write-Output "Total duplicate size: $DuplicateSize GigaBytes"
    Write-Output "*******************************************************"
}
else {
    $DuplicateSize = [math]::Round($DuplicateSize / 137438953472)
    Write-Output "*************************************************"
    Write-Output "Total duplicate size: $DuplicateSize TeraBytes"
    Write-Output "*************************************************"
}
