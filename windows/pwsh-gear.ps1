# install modules
Install-Module oh-my-posh -Scope CurrentUser -Force
Install-Module Terminal-Icons -Repository PSGallery -Force
Install-Module PSReadLine -AllowPreRelease -Force

# install fonts to display terminal icons in shell
Invoke-WebRequest -Uri "https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/CascadiaCode.zip" -OutFile CascadiaCode.zip
$tmpFolder = New-TemporaryFile | %{ rm $_; mkdir $_ }
Expand-Archive -LiteralPath CascadiaCode.zip -DestinationPath $tmpFolder
Remove-Item -Path .\CascadiaCode.zip
.\install-font.ps1 -Scope User -Path $tmpFolder

# copy profile and theme to user's home directory
Copy-Item -Path .\pwsh-profile.ps1 -Destination $PROFILE
Copy-Item -Path .\ohmyposh-johnny-theme.json -Destination ~/.ohmyposh-johnny-theme.json

# reload profile
. $PROFILE