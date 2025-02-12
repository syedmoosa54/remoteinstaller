# Bypass execution policy for ESET environment
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
$ErrorActionPreference = "Stop"

# Set variables
$AgentURL = "https://desktopcentral.manageengine.in/download?encapiKey=PHtE6r1bRem63jV59RIG4v%2B%2BFsGiY41%2F%2B%2BMzJAFHuY8QW6MCSk1X%2BIwuxGfhoksrUfZKQf%2BdnIpvsb%2BZtLiGI2a7YzxOCmqyqK3sx%2FVYSPOZqf3t0UBI4Fo%3D&os=Windows"
$DownloadPath = "$env:TEMP\DefaultRemoteOffice_Agent.exe"
$LogFile = "$env:SystemRoot\Temp\ME_AgentInstall.log"
$AgentInstalledPath = "C:\Program Files (x86)\Desktop Central\DesktopCentral_Agent\AgentHandler.exe" # Modify this to the actual location of the installed agent

# Function to check admin rights
function Test-Admin {
    return ([System.Security.Principal.WindowsPrincipal] [System.Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Ensure script is run as Administrator
if (-not (Test-Admin)) {
    Add-Content -Path $LogFile -Value "Script must be run as Administrator!"
    exit 1
}

# Check if agent is already installed
if (Test-Path $AgentInstalledPath) {
    Add-Content -Path $LogFile -Value "Agent is already installed. Skipping installation."
    exit 0
}

# Download agent
Add-Content -Path $LogFile -Value "Downloading agent from: $AgentURL"
try {
    Invoke-WebRequest -Uri $AgentURL -OutFile $DownloadPath
} catch {
    Add-Content -Path $LogFile -Value "Download failed: $_"
    exit 1
}

# Install agent
$InstallCmd = "$DownloadPath /silent"
Add-Content -Path $LogFile -Value "Installing agent: $InstallCmd"
Start-Process -FilePath $DownloadPath -ArgumentList "/silent" -NoNewWindow -Wait

# Clean up installer
Remove-Item -Path $DownloadPath -Force -ErrorAction SilentlyContinue
Add-Content -Path $LogFile -Value "Installation completed."