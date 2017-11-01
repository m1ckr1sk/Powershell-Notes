Function Get-GitStatus { git status }
Function Get-GitPull {git pull}

Set-Alias status Get-GitStatus -Description "Get the current status of the git repo at the current location"
Set-Alias pull Get-GitPull -Description "Pulls the git repo at the current location"