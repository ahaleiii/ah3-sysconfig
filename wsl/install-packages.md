# Packages to Install in WSL

## From Microsoft

Some Microsoft packages (.NET 6.0 & .NET 7.0) are listed in the main Ubuntu package repository, while others (PowerShell) depend on the Microsoft package repository. Some setup will need to be done so that certain packages are pulled from the correct source.

### Setup

#### Package Preferences

If Ubuntu version is 22.04 or lower, need to use the Microsoft repository for .NET 6 and 7.

- <https://learn.microsoft.com/en-us/dotnet/core/install/linux-package-mixup?pivots=os-linux-ubuntu#i-need-a-version-of-net-that-isnt-provided-by-my-linux-distribution>
- `sudo apt-get remove 'dotnet*' 'aspnet*' 'netstandard*'`
- `sudo touch /etc/apt/preferences`
- `sudo vim /etc/apt/preferences`

```config
Package: dotnet* aspnet* netstandard*
Pin: origin "archive.ubuntu.com"
Pin-Priority: -10
```

If Ubuntu version is 22.10, the Ubuntu repository can be used for .NET 6 and 7.

- <https://learn.microsoft.com/en-us/dotnet/core/install/linux-package-mixup?pivots=os-linux-ubuntu#my-linux-distribution-provides-net-packages-and-i-want-to-use-them>
- In `/etc/apt/preferences`, set line to `Pin: origin "packages.microsoft.com"`

#### Microsoft Repository

- <https://learn.microsoft.com/en-us/powershell/scripting/install/install-ubuntu?view=powershell-7.3#installation-via-package-repository>
- `sudo apt-get update`
- `sudo apt-get install -y wget apt-transport-https software-properties-common`
- `wget -q "https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb"`
- `sudo dpkg -i packages-microsoft-prod.deb`
- `rm packages-microsoft-prod.deb`
- `sudo apt-get update`

### dotnet

- <https://learn.microsoft.com/en-us/dotnet/core/install/linux-ubuntu-2204>
- `sudo apt-get install -y dotnet-sdk-7.0 dotnet-sdk-6.0`

### pwsh

- <https://learn.microsoft.com/en-us/powershell/scripting/install/install-ubuntu?view=powershell-7.3#installation-via-package-repository>
- `sudo apt-get install -y powershell`

## oh-my-posh

<https://ohmyposh.dev/docs/installation/linux>

### Install Homebrew

- <https://docs.brew.sh/Homebrew-on-Linux>
- `sudo apt-get install -y build-essential curl file git`
- `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`
- `test -d ~/.linuxbrew && eval "$(~/.linuxbrew/bin/brew shellenv)"`
- `test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"`
- `test -r ~/.bash_profile && echo "eval \"\$($(brew --prefix)/bin/brew shellenv)\"" >> ~/.bash_profile`
- `echo "eval \"\$($(brew --prefix)/bin/brew shellenv)\"" >> ~/.profile`

### Install oh-my-posh

- `brew install jandedobbeleer/oh-my-posh/oh-my-posh`
- To update: `brew update && brew upgrade oh-my-posh`
- Add to `~/.profile`: `eval "$(oh-my-posh init bash --config '/mnt/c/Users/ahale/AppData/Local/Programs/oh-my-posh/themes/ah3.omp.json')"`
