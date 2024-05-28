# oh-my-posh setup
# https://ohmyposh.dev/docs/installation/windows
# winget install JanDeDobbeleer.OhMyPosh -s winget
# winget upgrade JanDeDobbeleer.OhMyPosh -s winget
if ($IsWindows) {
    oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH/ah3.omp.json" | Invoke-Expression
} else {
    oh-my-posh init pwsh --config "/mnt/c/Users/ahale/AppData/Local/Programs/oh-my-posh/themes/ah3.omp.json" | Invoke-Expression
}

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
    if ($IsWindows) {
        Set-Location 'C:\git'
    } else {
        Set-Location '/mnt/c/git'
    }
}

function Set-LocationToGithubDirectory {
    if ($IsWindows) {
        Set-Location 'C:\github'
    } else {
        Set-Location '/mnt/c/github'
    }
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

    # sometimes the remote urls contain a semblance of a username which must be removed
    # https://org-name@dev.azure.com/org-name/CompanyProject/_git/AppRepo
    $usernameEnd = $remoteUrl.IndexOf('@') + 1
    if ($usernameEnd -gt 0) {
        $urlAnchor = '://'
        $usernameStart = $remoteUrl.IndexOf($urlAnchor) + $urlAnchor.Length
        $remoteUrlWithoutUsername = $remoteUrl.Remove($usernameStart, $usernameEnd - $usernameStart)
    } else {
        $remoteUrlWithoutUsername = $remoteUrl
    }

    explorer $remoteUrlWithoutUsername
}

function Complete-GitUnitOfWork([string]$PrimaryBranch = 'main', [switch]$Force = $false) {
    $branchName = git branch --show-current
    $detachedState = $false

    if ([string]::IsNullOrWhiteSpace($branchName)) {
        $detachedState = $true
        Write-Verbose 'Currently in a detached HEAD state; no branch will be deleted.' -Verbose
    }

    git switch $PrimaryBranch
    if ($LASTEXITCODE -ne 0) {
        throw "Primary branch '$PrimaryBranch' could not be found"
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

# Based on https://docs.gitignore.io/install/command-line#powershell-v3-script
Function Add-GitIgnore {
    param(
      [Parameter(Mandatory=$false)]
      [string[]]$IgnoreList = @('visualstudio'),
      [Parameter(Mandatory=$false)]
      [string]$Filename = '.gitignore',
      [Parameter(Mandatory=$false)]
      [switch]$Overwrite = $false,
      [Parameter(Mandatory=$false)]
      [string]$WorkingDirectory = (Get-Location).Path
    )

    $filepath = Join-Path -path $WorkingDirectory -ChildPath $Filename
    $params = ($IgnoreList | ForEach-Object { [uri]::EscapeDataString($_) }) -join ","
    $uri = "https://www.toptal.com/developers/gitignore/api/$params"
    $manualConfig = @()
    $ignoreContent = @()

    Write-Verbose "filepath: $filepath" -Verbose
    Write-Verbose "uri: $uri" -Verbose

    if (Test-Path -Path $filepath -PathType Leaf) {
        if (!$Overwrite) {
            Write-Warning "Overwrite is False and file already exists: $filepath"
            return
        }

        $existingContent = Get-Content -Path $filepath
        $manualStartIndex = $existingContent.IndexOf('### Begin manual configuration ###')
        $manualEndIndex = $existingContent.IndexOf('### End manual configuration ###')

        if ($manualStartIndex -ge 0 -and ($manualEndIndex - $manualStartIndex) -gt 1) {
            Write-Verbose 'preserving manual config:' -Verbose

            for ($i = $manualStartIndex; $i -le $manualEndIndex; $i++) {
                $line = $existingContent[$i]
                $manualConfig += $line

                if ($i -ne $manualStartIndex -and $i -ne $manualEndIndex -and
                    ![string]::IsNullOrWhiteSpace($line)) {
                    Write-Verbose "+ $line" -Verbose
                }
            }
        }
    }

    Write-Verbose 'generating git ignore file...' -Verbose

    $generatedContent = Invoke-RestMethod -Uri $uri -Method Get
    $generatedLines = $generatedContent.Split("`r`n").Split("`n")

    if ($manualConfig.Count -gt 0) {
        for ($i = 0; $i -lt $generatedLines.Count; $i++) {
            if ($i -eq 2) {
                $ignoreContent += ''
                $ignoreContent += $manualConfig
            }

            $ignoreContent += $generatedLines[$i]
        }
    } else {
        $ignoreContent += $generatedLines
    }

    # use WriteAllText instead of Set-Content to prevent the addition of an extra
    # blank line at the end of the file
    [System.IO.File]::WriteAllText( `
        $filepath, `
        $ignoreContent -join [Environment]::NewLine, `
        [System.Text.Encoding]::ASCII)

    Write-Verbose 'done' -Verbose
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

# https://ifconfig.me/
function Get-MyPublicIp {
    Invoke-RestMethod -Uri 'http://ifconfig.me/ip'
}

# https://github.com/microsoft/WSL/issues/8529
function Stop-Wsl {
    param(
        [switch]$Force = $false
    )

    if (!$IsWindows) {
        Write-Warning 'WSL can only be stopped from Windows'
        return
    }

    if ($Force) {
        $currentPrincipal = [Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
        if (-NOT $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
            throw 'Requires Administrator. To force WSL shutdown, need to run taskkill, which requires elevated permissions.'
        }

        taskkill /f /im wsl.exe
        taskkill /f /im wslhost.exe
        taskkill /f /im wslservice.exe
    }

    wsl --shutdown

    if ($Force) {
        taskkill /f /im wslservice.exe
    }
}

function Edit-PsHistory {
    code (Get-PSReadlineOption).HistorySavePath
}

# Aliases
Set-Alias d Get-Ah3ChildItem
Set-Alias dgit Set-LocationToGitDirectory
Set-Alias dgithub Set-LocationToGithubDirectory
Set-Alias which Get-WhichCommand
Set-Alias git-push Push-GitBranch
Set-Alias git-open-remote Open-GitRemote
Set-Alias git-complete Complete-GitUnitOfWork
Set-Alias git-ignore Add-GitIgnore
Set-Alias myip Get-MyPublicIp
Set-Alias getip Get-MyPublicIp
Set-Alias Get-PublicIp Get-MyPublicIp
