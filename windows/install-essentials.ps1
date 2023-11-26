# List of essential tools
$essentialTools = @(
    "git",
    "microsoft-windows-terminal",
    "pwsh",
    "awscli",
    "sops"
    "vscode",
    "7zip",
    "notepadplusplus",
    "starship"
)

# Function to install or update a package and print result
function InstallOrUpdate-ChocolateyPackage($packageName) {
  if (choco outdated $packageName --exit-code) {
      choco upgrade $packageName -y
      Write-Host "Updated $packageName"
  }
  else {
      choco install $packageName -y
      Write-Host "Installed $packageName"
  }
}

# check whether chocolatey is already exist
if (!(Get-Command choco.exe -errorAction SilentlyContinue)) {
  # install chocolatey
  Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

  if (Get-Command choco.exe -errorAction SilentlyContinue) {
    Write-Host "install chocolatey successfully"
  }
  else {
    Write-Error "install chocolatey failed"
    return
  }
}

# install or update essential tools
foreach ($tool in $essentialTools) {
  InstallOrUpdate-ChocolateyPackage $tool
}

# Display versions of installed tools
Write-Host "Versions of installed tools:"
choco list --localonly