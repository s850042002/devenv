This is an environment
setup for personal use only.

# **How to Use (Ubuntu/Linux)**
Clone this repo

```
git clone https://github.com/s850042002/devenv
```

Enter repo and execute script with `bash`
```
cd devenv
sudo ./install-essentials.sh
sudo ./install-configs.sh
```

## **Install/Update Golang**
The `golang-upgrade.sh` is copied from https://github.com/udhos/update-golang

```sh
sudo ./golang-upgrade.sh
```

# **How to Use (Windows)**
1. Clone this repo and enter windows directory
```
git clone https://github.com/s850042002/devenv
cd devenv/windows
```

2. Execute `install-essentials.ps1` by `powershell` or `pwsh` with Administator privilege
```
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol; .\install-essentials.ps1
```
Following components will be installed
- git
- Windows Terminal
- pwsh (Powershell Core)
- starship
- vscode
- awscli
- sops
- 7zip
- notepad++

3. Execute `pwsh-gear.ps1` by `pwsh` with Administator privilege, `nerd-fonts` will be installed as well
```
.\pwsh-gear.ps1
```

4. [optional] Install `nerd-fonts` independently. The script will retrieve the latest release from the [GitHub repository](https://github.com/ryanoasis/nerd-fonts/).
```
.\install-font.ps1
```


4. [optional] Install Docker independently. The script downloads the latest Docker engine and CLI from the [official Docker repository](https://download.docker.com/win/static/stable/x86_64/). 

**Note:** This installation only supports Windows containers. To run Linux containers, you'll need to install Docker Desktop separately.

```
.\install-docker.ps1
```