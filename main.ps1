$file = "./files"
$Running = $true

while($Running) {

    function Ask-Choices() {
        # Write the initial choices to the console 
        Write-Host ""
        Write-Host "What would you like to do?"
        Write-Host "A) Collect new baseline"
        Write-Host "B) Begin monitoring files with saved baseline"
        Write-Host "C) Change Settings"
        Write-Host "exit) exit program"
        $response = Read-Host -Prompt "Please enter 'A' or 'B'"
        Write-Host ""
        return $response
    }
    $response = Ask-Choices

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
        $count = 0
        #Delete baseline.txt if it already exists
        Erase-Baseline-If-Already-Exists
        
        # Calculate hash from the target files and store in baseline
        Write-Host "Calculating Hashes..." -ForegroundColor Cyan

        #Collect all the files in the target folder
        $files = Get-ChildItem -Path $file

        # For each file, calculate the hash and write it to baseline.txt
        foreach ($f in $files) {
            $hash = Calculate-File-Hash $f.FullName
            "$($hash.Path) | $($hash.hash)" | Out-File -FilePath .\baseline.txt -Append
            $count +=1
        }
        Write-Host "Hashes calculated, $($count) total files hashed." -ForegroundColor Green
    } # End of choice A

    elseif ($response -eq "B".ToUpper()) {

        $fileHashDictionary = @{}
        $AlertDictionary = @{}
        #load file|hash from baseline.txt and store in dictonary
        $filePathsAndHashes = Get-Content -Path .\baseline.txt

        foreach ($f in $filePathsAndHashes) {
            $fileHashDictionary.add($f.Split("|")[0].Trim(), $f.Split("|")[1].Trim())
        }

        #Begin continously
        while ($true) {
            Start-Sleep -Seconds 1
            
            $files = Get-ChildItem -Path .\files

            # for each file, calculate the hash and write to baseline.txt
            foreach ($f in $files) {
                $hash = Calculate-File-Hash $f.FullName
                #notify if a new file has been created
                if ($null -eq $fileHashDictionary[$hash.Path]) {
                    # A new file has been created
                    Write-Host "$($hash.Path) has been created!" -ForegroundColor Green

                    # Adds to the directory to avoid repeat hits
                    $fileHashDictionary.add($hash.Path, $Hash.Hash)
                }
                else {
                    # notify if a new file has been changed
                    if ($fileHashDictionary[$hash.Path] -eq $($hash.Hash)) {
                        # Path has not changed
                    }
                    else {
                        # file has been comprimised!
                        Write-Host "$($hash.Path) Has been changed!" -ForegroundColor Yellow

                        # Adds to the directory to avoid repeat hits
                        $fileHashDictionary[$hash.Path] = $hash.Hash
                    }
                }

                # Notify if a file has been deleted
                
                foreach ($key in $fileHashDictionary.Keys) {
                    $baselineFileStillExists = Test-Path -Path $key
                    if ((-Not $baselineFileStillExists) -and ($null -eq $AlertDictionary[$key])) {
                        #One of the baseline files have been deleted notify user
                        Write-Host "$($key) has been deleted!" -ForegroundColor DarkMagenta

                        $AlertDictionary[$key] = $fileHashDictionary[$key]
                    }
                } # stopping looping through keys
            } # end of loop through files
        } # End of while
    } # end of choice B
    elseif ($response -eq "C".ToUpper()) {
        # Use this to change default directory of files
        $run = $true
        while ($run) {
            $reply = Read-Host -Prompt "What is the file path you would like to use?"
            if (Test-Path -Path $reply) {
                $file = $reply
                Write-Host "File successfully inputed." -ForegroundColor Green
                $run = $false
            }
            elseif ($reply -eq "exit".ToUpper()) {
                $run = $false
            }
            else {
                Write-Host "Error, File not valid please try again"
            }
        }

    }
    elseif ($response -eq "exit".ToUpper()) {
        Write-Host "Exiting program"
        $Running = $false
    }
    else {
        Write-host "Thats not a valid answer!" -ForegroundColor Red -BackgroundColor White
        Write-host "Please input either 'A' or 'B'"
    }
} # end of while running 