# Get the latest Docker version from the download directory
$dockerDownloadPage = "https://download.docker.com/win/static/stable/x86_64/"
$pageContent = Invoke-WebRequest -Uri $dockerDownloadPage -UseBasicParsing
$versionPattern = 'docker-(\d+\.\d+\.\d+)\.zip'
$versions = $pageContent.Content | Select-String -Pattern $versionPattern -AllMatches | 
    ForEach-Object { $_.Matches } | 
    ForEach-Object { [Version]$_.Groups[1].Value } | 
    Sort-Object -Descending

if (-not $versions) {
    throw "No Docker versions found at $dockerDownloadPage"
}

$latestVersion = $versions[0]
$dockerUrl = "https://download.docker.com/win/static/stable/x86_64/docker-$latestVersion.zip"
echo "Latest Docker version found: $latestVersion"

echo "Downloading Docker from: $dockerUrl"
curl.exe -o docker.zip -LO $dockerUrl

# Remove existing Docker installation if it exists
if (Test-Path "C:\Program Files\docker") {
    echo "Removing existing Docker installation"
    Remove-Item "C:\Program Files\docker" -Recurse -Force
}

echo "Extracting Docker to C:\Program Files\"
Expand-Archive docker.zip -DestinationPath "C:\Program Files\" -Force

[Environment]::SetEnvironmentVariable("Path", "$($env:path);C:\Program Files\docker", [System.EnvironmentVariableTarget]::Machine)
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine")

# Change to the Docker directory and register the service
Set-Location "C:\Program Files\docker"

# Unregister existing Docker service if it exists
try {
    Stop-Service docker -Force -ErrorAction SilentlyContinue
    dockerd --unregister-service
    echo "Existing Docker service stopped and unregistered"
} catch {
    echo "No existing Docker service to unregister"
}

echo "Registering Docker service"
dockerd --register-service

# Wait a moment for service registration to complete
Start-Sleep -Seconds 3

echo "Starting Docker service"
try {
    Start-Service docker
    echo "Docker service started successfully"
} catch {
    echo "Failed to start Docker service. Trying alternative approach..."
    # Try starting dockerd directly first
    Start-Process -FilePath "dockerd.exe" -ArgumentList "--run-service" -NoNewWindow -PassThru
    Start-Sleep -Seconds 5
    Start-Service docker
}