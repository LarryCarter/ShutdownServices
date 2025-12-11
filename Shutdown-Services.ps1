<#
.SYNOPSIS
    Shuts down Windows services safely and gracefully.

.DESCRIPTION
    This script provides functionality to stop Windows services with proper error handling,
    timeout management, and logging. It supports stopping individual services, multiple services,
    or services matching a pattern. The script checks for administrator privileges and handles
    dependencies appropriately.

.PARAMETER ServiceNames
    Array of specific service names to shut down.
    Example: -ServiceNames "wuauserv","BITS"

.PARAMETER ServicePattern
    Pattern to match service names (supports wildcards).
    Example: -ServicePattern "SQL*"

.PARAMETER Force
    Force stop services immediately without waiting for graceful shutdown.

.PARAMETER Timeout
    Maximum time in seconds to wait for each service to stop gracefully (default: 30).

.PARAMETER ExcludeServices
    Array of service names to exclude from shutdown.

.PARAMETER WhatIf
    Shows what would happen if the script runs without actually stopping services.

.EXAMPLE
    .\Shutdown-Services.ps1 -ServiceNames "wuauserv","BITS"
    Stops the Windows Update and Background Intelligent Transfer Service.

.EXAMPLE
    .\Shutdown-Services.ps1 -ServicePattern "SQL*" -Force
    Force stops all services starting with "SQL".

.EXAMPLE
    .\Shutdown-Services.ps1 -ServiceNames "MyService" -Timeout 60
    Stops MyService with a 60-second timeout.

.EXAMPLE
    .\Shutdown-Services.ps1 -ServicePattern "*" -ExcludeServices "CriticalService1","CriticalService2" -WhatIf
    Shows what services would be stopped, excluding critical services.

.NOTES
    Author: ShutdownServices Project
    Requires: PowerShell 3.0 or higher
    Requires: Administrator privileges
#>

[CmdletBinding(SupportsShouldProcess=$true)]
param(
    [Parameter(Mandatory=$false, ValueFromPipeline=$true)]
    [string[]]$ServiceNames,

    [Parameter(Mandatory=$false)]
    [string]$ServicePattern,

    [Parameter(Mandatory=$false)]
    [switch]$Force,

    [Parameter(Mandatory=$false)]
    [int]$Timeout = 30,

    [Parameter(Mandatory=$false)]
    [string[]]$ExcludeServices = @()
)

# Set error action preference
$ErrorActionPreference = "Continue"

# Function to check if running as administrator
function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Function to write log messages
function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    
    switch ($Level) {
        "ERROR" { Write-Host $logMessage -ForegroundColor Red }
        "WARNING" { Write-Host $logMessage -ForegroundColor Yellow }
        "SUCCESS" { Write-Host $logMessage -ForegroundColor Green }
        default { Write-Host $logMessage -ForegroundColor White }
    }
}

# Function to stop a service gracefully
function Stop-ServiceGracefully {
    param(
        [System.ServiceProcess.ServiceController]$Service,
        [int]$TimeoutSeconds,
        [bool]$ForceStop
    )
    
    try {
        # Check if service is already stopped
        if ($Service.Status -eq 'Stopped') {
            Write-Log "Service '$($Service.Name)' is already stopped." "INFO"
            return $true
        }

        # Check if service can be stopped
        if (-not $Service.CanStop) {
            Write-Log "Service '$($Service.Name)' cannot be stopped (CanStop = false)." "WARNING"
            return $false
        }

        Write-Log "Attempting to stop service '$($Service.Name)' (Display Name: $($Service.DisplayName))..." "INFO"

        if ($ForceStop) {
            # Force stop using Stop-Service with -Force
            Stop-Service -Name $Service.Name -Force -ErrorAction Stop
            Write-Log "Service '$($Service.Name)' force stopped successfully." "SUCCESS"
            return $true
        } else {
            # Graceful stop
            $Service.Stop()
            
            # Wait for service to stop
            $Service.WaitForStatus('Stopped', [TimeSpan]::FromSeconds($TimeoutSeconds))
            
            Write-Log "Service '$($Service.Name)' stopped successfully." "SUCCESS"
            return $true
        }
    }
    catch [System.ServiceProcess.TimeoutException] {
        Write-Log "Service '$($Service.Name)' did not stop within $TimeoutSeconds seconds." "WARNING"
        
        # Attempt force stop if not already forced
        if (-not $ForceStop) {
            Write-Log "Attempting force stop for service '$($Service.Name)'..." "WARNING"
            try {
                Stop-Service -Name $Service.Name -Force -ErrorAction Stop
                Write-Log "Service '$($Service.Name)' force stopped successfully." "SUCCESS"
                return $true
            }
            catch {
                Write-Log "Failed to force stop service '$($Service.Name)': $($_.Exception.Message)" "ERROR"
                return $false
            }
        }
        return $false
    }
    catch {
        Write-Log "Error stopping service '$($Service.Name)': $($_.Exception.Message)" "ERROR"
        return $false
    }
}

# Main script execution
Write-Log "=== Windows Service Shutdown Script Started ===" "INFO"

# Check for administrator privileges
if (-not (Test-Administrator)) {
    Write-Log "This script requires administrator privileges. Please run as Administrator." "ERROR"
    exit 1
}

# Validate parameters
if (-not $ServiceNames -and -not $ServicePattern) {
    Write-Log "Please specify either -ServiceNames or -ServicePattern parameter." "ERROR"
    Write-Log "Use 'Get-Help .\Shutdown-Services.ps1 -Full' for more information." "INFO"
    exit 1
}

# Get services to stop
$servicesToStop = @()

if ($ServiceNames) {
    Write-Log "Looking up specified services..." "INFO"
    foreach ($serviceName in $ServiceNames) {
        try {
            $service = Get-Service -Name $serviceName -ErrorAction Stop
            $servicesToStop += $service
        }
        catch {
            Write-Log "Service '$serviceName' not found." "WARNING"
        }
    }
}

if ($ServicePattern) {
    Write-Log "Searching for services matching pattern '$ServicePattern'..." "INFO"
    $matchedServices = Get-Service -Name $ServicePattern -ErrorAction SilentlyContinue
    if ($matchedServices) {
        $servicesToStop += $matchedServices
    } else {
        Write-Log "No services found matching pattern '$ServicePattern'." "WARNING"
    }
}

# Remove duplicates
$servicesToStop = $servicesToStop | Sort-Object -Property Name -Unique

# Apply exclusions
if ($ExcludeServices.Count -gt 0) {
    Write-Log "Applying exclusions: $($ExcludeServices -join ', ')" "INFO"
    $servicesToStop = $servicesToStop | Where-Object { $_.Name -notin $ExcludeServices }
}

# Check if any services found
if ($servicesToStop.Count -eq 0) {
    Write-Log "No services found to stop." "WARNING"
    exit 0
}

Write-Log "Found $($servicesToStop.Count) service(s) to stop." "INFO"

# Display services that will be stopped
Write-Log "Services to be stopped:" "INFO"
foreach ($service in $servicesToStop) {
    Write-Log "  - $($service.Name) ($($service.DisplayName)) [Status: $($service.Status)]" "INFO"
}

Write-Log "" "INFO"

# Stop services
$successCount = 0
$failureCount = 0

Write-Log "" "INFO"
Write-Log "Beginning service shutdown..." "INFO"

foreach ($service in $servicesToStop) {
    $target = "$($service.Name) ($($service.DisplayName))"
    $action = if ($Force) { "Force stop service" } else { "Stop service gracefully with $Timeout second timeout" }
    
    if ($PSCmdlet.ShouldProcess($target, $action)) {
        $result = Stop-ServiceGracefully -Service $service -TimeoutSeconds $Timeout -ForceStop $Force
        if ($result) {
            $successCount++
        } else {
            $failureCount++
        }
    }
}

# Summary
Write-Log "" "INFO"
Write-Log "=== Service Shutdown Summary ===" "INFO"
Write-Log "Total services processed: $($servicesToStop.Count)" "INFO"
Write-Log "Successfully stopped: $successCount" "SUCCESS"
if ($failureCount -gt 0) {
    Write-Log "Failed to stop: $failureCount" "ERROR"
}
Write-Log "=== Windows Service Shutdown Script Completed ===" "INFO"

# Return exit code based on results
if ($failureCount -gt 0) {
    exit 1
} else {
    exit 0
}
