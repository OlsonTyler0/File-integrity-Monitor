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
    #Delete baseline.txt if it already exists
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
} # End of choice A

elseif ($response -eq "B".ToUpper()) {

    $fileHashDictonary = @{}
    #load file|hash from baseline.txt and store in dictonary
    $filePathesAndHashes = Get-Content -Path .\baseline.txt

    foreach ($f in $filePathsAndHashes) {
        $fileHashDictonary.add($f.Split("|")[0], $f.Split("|")[1])
    }

    #Begin continously
    while ($true) {
        Start-Sleep -Seconds 1
        
        $files = Get-ChildItem -Path .\files

        # for each file, calculate the hash and write to baseline.txt
        foreach ($f in $files) {
            $hash = Calculate-File-Hash $f.FullName

            #notify if a new file has been created
            if ($null -eq $fileHashDirectory[$hash.Path]) {
                # A new file has been created
                Write-Host "$($hash.Path) has been created!" -ForegroundColor Green
            }

            # notify if a new file has been changed
            if ($fileHashDictonary[$hash.Path] -eq $hash.Hash) {
                # Path has not changed
            }
            else {
                # file has been comprimised!
                Write-Host "$($hash.Path) Has been changed!" -ForegroundColor Yellow
            }

            # Notify if a file has been deleted
            
            foreach ($key in $fileHashDictonary.Keys) {
                $baselineFileStillExists = Test-Path -Path $key
                if (-Not $baselineFileStillExists) {
                    #One of the baseline files have been deleted notify user
                    Write-Host "$($key) has been deleted!" -ForegroundColor DarkMagenta
                }
            }
        } # end of for each
    } # End of while
} # end of choice B