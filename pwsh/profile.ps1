function GetDirectory($location) {
    if ([string]::IsNullOrWhiteSpace($location)) {
        $location = Get-Location
    }

    # Gets all contents of current directory, excluding system items
    Get-ChildItem -Path $location -Force -Attributes !S
}

function Get-WhichCommand($commandName) {
    if ([string]::IsNullOrWhiteSpace($commandName)) {
        throw "No command specified."
    }

    $command = Get-Command $commandName
    Write-Information ($command.Source) -InformationAction Continue
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

Set-Alias d GetDirectory
Set-Alias which Get-WhichCommand
