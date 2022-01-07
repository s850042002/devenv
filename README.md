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
./install-essentials.sh
./install-configs.sh
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
- oh-my-posh
- vscode
- 7zip
- notepad++

3. Execute `pwsh-gear.ps1` by `pwsh` with Administator privilege
```
.\pwsh-gear.ps1
```
