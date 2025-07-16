# Create a directory for TFLint in your user profile
$installDir = "$env:USERPROFILE\bin"
New-Item -ItemType Directory -Force -Path $installDir

# Get the latest release info
$latestRelease = Invoke-RestMethod -Uri "https://api.github.com/repos/terraform-linters/tflint/releases/latest"
$version = $latestRelease.tag_name

# Download the Windows version
$downloadUrl = "https://github.com/terraform-linters/tflint/releases/download/$version/tflint_windows_amd64.zip"
$zipPath = "$env:TEMP\tflint.zip"

Write-Host "Downloading TFLint $version..."
Invoke-WebRequest -Uri $downloadUrl -OutFile $zipPath

# Extract and install
Write-Host "Extracting and installing..."
Expand-Archive -Path $zipPath -DestinationPath $env:TEMP -Force
Move-Item "$env:TEMP\tflint.exe" "$installDir\tflint.exe" -Force

# Clean up
Remove-Item $zipPath

# Add to PATH if not already there
$currentPath = [Environment]::GetEnvironmentVariable("PATH", "User")
if ($currentPath -notlike "*$installDir*") {
    [Environment]::SetEnvironmentVariable("PATH", "$currentPath;$installDir", "User")
    Write-Host "Added $installDir to your PATH"
}

Write-Host "TFLint installed successfully!"

# Refresh your PATH in the current PowerShell session
#$env:PATH = [Environment]::GetEnvironmentVariable("PATH", "User") + ";" + [Environment]::GetEnvironmentVariable("PATH", "Machine")

# cd "C:\Users\Personal\Desktop\arc-aks"
# tflint --init
# tflint

# Run with format to see if it's actually processing anything
# tflint --format=json

# Get-ChildItem *.tf
# $env:TFLINT_LOG = "info"
# tflint
