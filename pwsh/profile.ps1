# oh-my-posh setup
# https://ohmyposh.dev/docs/installation/windows
# winget install JanDeDobbeleer.OhMyPosh -s winget
# winget upgrade JanDeDobbeleer.OhMyPosh -s winget
oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH/ah3.omp.json" | Invoke-Expression

# https://ohmyposh.dev/docs/segments/git
# https://github.com/dahlbyk/posh-git
# Install-Module -Name posh-git -Scope CurrentUser -Repository PSGallery
Import-Module posh-git
$env:POSH_GIT_ENABLED = $true

# terminal icons setup
# https://github.com/devblackops/Terminal-Icons
# Install-Module -Name Terminal-Icons -Scope CurrentUser -Repository PSGallery
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

function Push-GitBranch([string]$remoteName = 'origin') {
    $branchName = git branch --show-current

    if ([string]::IsNullOrWhiteSpace($branchName)) {
        throw 'Currently in a detached HEAD state; no branch to push.'
    }

    # example status:
    # ## ah3/test...origin/ah3/test
    #  M my-file.txt
    $status = git status -sb
    $firstStatusLine = $status.Count -gt 1 ? $status[0] : $status

    if ($firstStatusLine.Contains('...')) {
        git push
    } else {
        Write-Verbose "Setting upstream branch on $remoteName" -Verbose
        git push --set-upstream $remoteName $branchName
    }
}

function Open-GitRemote([string]$remoteName = 'origin') {
    $remoteUrl = git config --get remote.$remoteName.url

    if ([string]::IsNullOrWhiteSpace($remoteUrl)) {
        throw "No url found for remote: $remoteName"
    }

    explorer $remoteUrl
}

function Complete-GitUnitOfWork([string]$primaryBranch = 'main', [switch]$Force = $false) {
    $branchName = git branch --show-current
    $detachedState = $false

    if ([string]::IsNullOrWhiteSpace($branchName)) {
        $detachedState = $true
        Write-Verbose 'Currently in a detached HEAD state; no branch will be deleted.' -Verbose
    }

    git switch $primaryBranch
    if ($LASTEXITCODE -ne 0) {
        throw "Primary branch '$primaryBranch' could not be found"
    }

    git pull

    if ($detachedState) {
        return
    } elseif ($Force) {
        git branch -D $branchName
    } else {
        git branch -d $branchName
    }
}

function New-AzdoRestApiHeader([string]$PAT) {
    if ([string]::IsNullOrWhiteSpace($PAT)) {
        throw 'No PAT provided'
    }

    $user = '' # not needed when using PAT
    $authString = "{0}:{1}" -f $user, $PAT
    $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes($authString))
    $auth = "Basic $base64AuthInfo"
    return @{ Authorization = $auth }
}

# Aliases
Set-Alias d Get-Ah3ChildItem
Set-Alias dgit Set-LocationToGitDirectory
Set-Alias dgithub Set-LocationToGithubDirectory
Set-Alias which Get-WhichCommand
Set-Alias git-push Push-GitBranch
Set-Alias git-open-remote Open-GitRemote
Set-Alias git-complete Complete-GitUnitOfWork
