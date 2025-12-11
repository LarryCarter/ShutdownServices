[CmdletBinding()]
param(
    [string]$ServicePrefix = "SUS_",
    [string]$LogFilePath   = "C:\Logs\SUS_ServiceShutdown.log",
    [switch]$DryRun
)

#region Helper Functions

function Write-Log {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,

        [ValidateSet("INFO", "WARN", "ERROR")]
        [string]$Level = "INFO"
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $entry     = "[{0}] [{1}] {2}" -f $timestamp, $Level, $Message

    # Console output
    switch ($Level) {
        "INFO"  { Write-Host $entry }
        "WARN"  { Write-Warning $entry }
        "ERROR" { Write-Error $entry }
    }

    # Ensure log directory exists
    $logDir = Split-Path -Path $LogFilePath -Parent
    if (-not [string]::IsNullOrWhiteSpace($logDir) -and -not (Test-Path $logDir)) {
        New-Item -Path $logDir -ItemType Directory -Force | Out-Null
    }

    # Append to log file
    Add-Content -Path $LogFilePath -Value $entry
}

function Test-IsAdmin {
    try {
        $currentIdentity  = [Security.Principal.WindowsIdentity]::GetCurrent()
        $principal        = New-Object Security.Principal.WindowsPrincipal($currentIdentity)
        $isAdmin          = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
        return $isAdmin
    }
    catch {
        return $false
    }
}

#endregion Helper Functions

#region Start Script

$scriptStart = Get-Date
Write-Log -Message "==================================================================" -Level "INFO"
Write-Log -Message "Service shutdown script started." -Level "INFO"
Write-Log -Message "Service prefix: '$ServicePrefix'" -Level "INFO"
Write-Log -Message "Log file: '$LogFilePath'" -Level "INFO"
Write-Log -Message ("Dry run mode: {0}" -f ($DryRun.IsPresent)) -Level "INFO"

# Permission check (skip only if DryRun is enabled)
if (-not $DryRun) {
    if (-not (Test-IsAdmin)) {
        Write-Log -Message "Script is not running with administrative privileges. Exiting." -Level "ERROR"
        Write-Host ""
        Write-Host "Please run this script in an elevated PowerShell session (Run as Administrator)." -ForegroundColor Yellow
        exit 1
    }
}

# Discover services
$services = Get-Service | Where-Object { $_.Name -like "$ServicePrefix*" }

if (-not $services -or $services.Count -eq 0) {
    Write-Log -Message "No services found with prefix '$ServicePrefix'." -Level "WARN"
    $scriptEnd = Get-Date
    Write-Log -Message ("Service shutdown script completed. Duration: {0}" -f ($scriptEnd - $scriptStart)) -Level "INFO"
    exit 0
}

Write-Log -Message ("Found {0} service(s) with prefix '{1}'." -f $services.Count, $ServicePrefix) -Level "INFO"

# Counters
[int]$totalProcessed = 0
[int]$totalStopped   = 0
[int]$totalSkipped   = 0
[int]$totalFailed    = 0

foreach ($svc in $services) {
    $totalProcessed++
    $serviceName  = $svc.Name
    $displayName  = $svc.DisplayName
    $status       = $svc.Status.ToString()

    Write-Log -Message ("Processing service: Name='{0}', DisplayName='{1}', Status='{2}'" -f $serviceName, $displayName, $status) -Level "INFO"

    if ($status -ne "Running") {
        # Skip services that are not running
        Write-Log -Message ("Service '{0}' is not running (Status='{1}'). Skipping." -f $serviceName, $status) -Level "WARN"
        $totalSkipped++
        continue
    }

    if ($DryRun) {
        Write-Log -Message ("[DryRun] Would attempt to stop service '{0}' ('{1}')." -f $serviceName, $displayName) -Level "INFO"
        $totalSkipped++
        continue
    }

    try {
        Write-Log -Message ("Attempting to stop service '{0}' ('{1}')..." -f $serviceName, $displayName) -Level "INFO"

        # Attempt graceful stop
        Stop-Service -Name $serviceName -ErrorAction Stop

        # Re-check status
        $svc.Refresh()
        if ($svc.Status -eq [System.ServiceProcess.ServiceControllerStatus]::Stopped) {
            Write-Log -Message ("Service '{0}' stopped successfully." -f $serviceName) -Level "INFO"
            $totalStopped++
        }
        else {
            Write-Log -Message ("Service '{0}' did not report 'Stopped' after Stop-Service call. Current status: {1}" -f $serviceName, $svc.Status) -Level "WARN"
            $totalFailed++
        }
    }
    catch {
        $errorMsg = $_.Exception.Message
        Write-Log -Message ("Failed to stop service '{0}'. Error: {1}" -f $serviceName, $errorMsg) -Level "ERROR"
        $totalFailed++
        continue
    }
}

$scriptEnd = Get-Date
$duration  = $scriptEnd - $scriptStart

Write-Log -Message "-------------------- Summary --------------------" -Level "INFO"
Write-Log -Message ("Total services matched:  {0}" -f $services.Count) -Level "INFO"
Write-Log -Message ("Total processed:         {0}" -f $totalProcessed) -Level "INFO"
Write-Log -Message ("Total stopped:           {0}" -f $totalStopped) -Level "INFO"
Write-Log -Message ("Total skipped:           {0}" -f $totalSkipped) -Level "INFO"
Write-Log -Message ("Total failed:            {0}" -f $totalFailed) -Level "INFO"
Write-Log -Message ("Script completed. Duration: {0}" -f $duration) -Level "INFO"
Write-Log -Message "==================================================" -Level "INFO"

#endregion End Script
