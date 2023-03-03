# oh-my-posh setup
# https://ohmyposh.dev/docs/installation/windows
# winget install JanDeDobbeleer.OhMyPosh -s winget
# winget upgrade JanDeDobbeleer.OhMyPosh -s winget
oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH/ah3.omp.json" | Invoke-Expression

# terminal icons setup
# https://github.com/devblackops/Terminal-Icons
# install: Install-Module -Name Terminal-Icons -Repository PSGallery
Import-Module -Name Terminal-Icons

function Get-Ah3ChildItem($location) {
    if ([string]::IsNullOrWhiteSpace($location)) {
        $location = Get-Location
    }

    # Gets all contents of current directory, excluding system items
    Get-ChildItem -Path $location -Force -Attributes !S
}

function Set-LocationToGitDirectory {
    Set-Location 'C:\git'
}

function Set-LocationToGithubDirectory {
    Set-Location 'C:\github'
}

function Get-WhichCommand($commandName) {
    if ([string]::IsNullOrWhiteSpace($commandName)) {
        throw "No command specified."
    }

    $command = Get-Command $commandName
    return $command.Source
}

# https://devblogs.microsoft.com/scripting/powertip-find-all-powershell-profile-locations/
function Get-ProfileLocations {
    $PROFILE | Format-List -Force
}

function Edit-Profile {
    code $PROFILE.CurrentUserAllHosts
}

# https://devblogs.microsoft.com/scripting/generate-random-letters-with-powershell/
function Get-RandomHexString([int]$length = 16) {
    $lowercaseAsciA = 97
    $lowercaseAsciF = 102
    return ((0..9) + ($lowercaseAsciA..$lowercaseAsciF)) * $length | Get-Random -Count $length | ForEach-Object {
        if ($_ -gt 9) {
            [char]$_
        } else {
            $_
        }
    } | Join-String
}

# Aliases
Set-Alias d Get-Ah3ChildItem
Set-Alias dgit Set-LocationToGitDirectory
Set-Alias dgithub Set-LocationToGithubDirectory
Set-Alias which Get-WhichCommand

# TODO:
# git-push
# git-open-remote
# git-complete
