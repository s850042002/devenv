# install modules
Install-Module Terminal-Icons -Repository PSGallery -Force
Install-Module PSReadLine -AllowPreRelease -Force

# install fonts to display terminal icons in shell
.\install-font.ps1

# copy profile and theme to user's home directory
Copy-Item -Path .\pwsh-profile.ps1 -Destination $PROFILE
Copy-Item -Path .\starship.toml -Destination ~/.config/starship.toml

# reload profile
. $PROFILE