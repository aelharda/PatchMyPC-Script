# Define the URL for the PSWindowsUpdate package
$packageUrl = "https://psg-prod-eastus.azureedge.net/packages/pswindowsupdate.2.2.1.5.nupkg"
$packagePath = "$env:TEMP\pswindowsupdate.2.2.1.5.nupkg"
$modulePath = "C:\Program Files\WindowsPowerShell\Modules\PSWindowsUpdate"

# Download the package
Write-Host "Downloading PSWindowsUpdate package..."
Invoke-WebRequest -Uri $packageUrl -OutFile $packagePath

# Check if the package was downloaded successfully
if (-Not (Test-Path -Path $packagePath)) {
    Write-Host "Failed to download the PSWindowsUpdate package."
    exit 1
}

# Create the module directory if it doesn't exist
if (-Not (Test-Path -Path $modulePath)) {
    Write-Host "Creating module directory..."
    New-Item -ItemType Directory -Path $modulePath
}

# Extract the package
Write-Host "Extracting PSWindowsUpdate package..."
try {
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::ExtractToDirectory($packagePath, $modulePath)
} catch {
    Write-Host "Failed to extract the PSWindowsUpdate package."
    exit 1
}

# Clean up the downloaded package
Remove-Item $packagePath

# Import the module
Write-Host "Importing PSWindowsUpdate module..."
try {
    Import-Module PSWindowsUpdate
} catch {
    Write-Host "Failed to import the PSWindowsUpdate module."
    exit 1
}

# Retrieve the list of available updates
Write-Host "Retrieving list of available updates..."
$availableUpdates = Get-WindowsUpdate -IsInstalled:$false

# Check if updates are available
if ($availableUpdates.Count -eq 0) {
    Write-Host "No available updates found."
    return
}

# Display available updates for debugging purposes
Write-Host "Available updates:"
$availableUpdates | Format-Table -AutoSize

# Filter updates based on the KB article pattern
Write-Host "Filtering updates based on the KB article pattern 'KBPMPC-*'..."
$filteredUpdates = $availableUpdates | Where-Object {
    $_.KB -match 'KBPMPC-*'
}

# Check if any updates match the pattern
if ($filteredUpdates.Count -eq 0) {
    Write-Host "No updates found matching the pattern 'KBPMPC-*'."
    return
}

# Display the filtered updates for confirmation
Write-Host "Found updates matching the pattern 'KBPMPC-*':"
$filteredUpdates | Format-Table -AutoSize

# Install the filtered updates without auto-reboot
Write-Host "Installing the filtered updates without auto-reboot..."
$filteredUpdates | ForEach-Object {
    Write-Host "Installing update: $($_.Title)"
    Install-WindowsUpdate -KBArticleID $_.KB -AcceptAll -IgnoreReboot
}
Write-Host "Updates installation completed."