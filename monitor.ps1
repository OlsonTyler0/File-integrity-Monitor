function Monitor-File ()
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
  } # end of function 