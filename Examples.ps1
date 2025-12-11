<#
.SYNOPSIS
    Example usage scenarios for Shutdown-Services.ps1

.DESCRIPTION
    This file contains common usage examples for the Shutdown-Services.ps1 script.
    These examples are commented out - uncomment and modify as needed for your use case.
#>

# Example 1: Stop specific services
# .\Shutdown-Services.ps1 -ServiceNames "wuauserv","BITS"

# Example 2: Stop all services matching a pattern
# .\Shutdown-Services.ps1 -ServicePattern "SQL*"

# Example 3: Force stop services immediately
# .\Shutdown-Services.ps1 -ServiceNames "MyService" -Force

# Example 4: Stop services with custom timeout
# .\Shutdown-Services.ps1 -ServiceNames "MyService" -Timeout 60

# Example 5: Stop services with exclusions
# .\Shutdown-Services.ps1 -ServicePattern "Test*" -ExcludeServices "TestCritical","TestEssential"

# Example 6: WhatIf mode - see what would happen without actually stopping services
# .\Shutdown-Services.ps1 -ServicePattern "*MyApp*" -WhatIf

# Example 7: Stop multiple specific services with force and custom timeout
# .\Shutdown-Services.ps1 -ServiceNames "Service1","Service2","Service3" -Force -Timeout 45

# Example 8: Complex scenario - stop all services starting with "Dev" except critical ones
# .\Shutdown-Services.ps1 -ServicePattern "Dev*" -ExcludeServices "DevCritical","DevDB" -Timeout 120

# Example 9: Pipeline input
# "wuauserv","BITS","Spooler" | .\Shutdown-Services.ps1

# Example 10: Stop web-related services
# .\Shutdown-Services.ps1 -ServiceNames "W3SVC","WAS","IISADMIN" -Timeout 60

Write-Host "Examples.ps1 - This file contains example usage patterns."
Write-Host "Uncomment and modify the examples above to use them."
Write-Host ""
Write-Host "For detailed help, run:"
Write-Host "  Get-Help .\Shutdown-Services.ps1 -Full"
