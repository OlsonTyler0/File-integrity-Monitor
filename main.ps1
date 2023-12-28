

Write-Host ""
Write-Host "What would you like to do?"
Write-Host "A) Collect new baseline"
Write-Host "B) Begin monitoring files with saved baseline"

$response = Read-Host -Prompt "Please enter 'A' or 'B'"
Write-Host ""

function Calculate-File-Hash($filepath) {
    $filehash = Get-FileHash -Path $filepath -Algorithm SHA512
    return $filehash
    
}

function Erase-Baseline-If-Already-Exists() {
    $baselineExists = Test-Path -Path .\baseline.txt
    
    if($baselineExists) {
        #delete it
        Remove-Item -Path .\baseline.txt
    }
}

if ($response -eq "A".ToUpper()) {
    #Delete baseline.txt if it exists
    Erase-Baseline-If-Already-Exists
    
    # Calculate hash from the target files and store in baseline
    Write-Host "Calculate hashes, make a new baseline.txt" -ForegroundColor Cyan

    #Collect all the files in the target folder
    $files = Get-ChildItem -Path .\files

    # For each file, calculate the hash and write it to baseline.txt
    foreach ($f in $files) {
        $hash = Calculate-File-Hash $f.FullName
        "$($hash.Path) | $($hash.hash)" | Out-File -FilePath .\baseline.txt -Append
    }
}
elseif ($response -eq "B".ToUpper()) {
    <# Begin monitoring files with saved baseline #>
    Write-Host "Read existing baseline.txt, start monitoring files." -ForegroundColor Yellow
}