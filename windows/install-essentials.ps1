# check whether chocolatey is already exist
if (!(Get-Command choco.exe -errorAction SilentlyContinue)) {
  # install chocolatey
  Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

  if (Get-Command choco.exe -errorAction SilentlyContinue) {
    Write-Host "install chocolatey successfully"
  }
  else {
    Write-Host "install chocolatey failed"
    return
  }
}

# show version of chocolatey
choco outdated

# install essential tools
choco install git.install -y
choco install powershell-core -y
choco install microsoft-windows-terminal -y
choco install vscode -y 
choco install 7zip -y
choco install notepadplusplus -y