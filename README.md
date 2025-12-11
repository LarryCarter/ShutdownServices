# ShutdownServices

PowerShell Script to safely shut down Windows services with proper error handling and logging.

## Overview

This repository contains `Shutdown-Services.ps1`, a robust PowerShell script designed to gracefully stop Windows services. The script includes features like timeout management, force stop options, pattern matching, exclusion lists, and comprehensive logging.

## Features

- ✅ **Graceful Shutdown**: Attempts to stop services gracefully before forcing
- ✅ **Timeout Management**: Configurable timeout for service shutdown
- ✅ **Pattern Matching**: Support for wildcards to match multiple services
- ✅ **Exclusion Lists**: Exclude specific services from shutdown
- ✅ **Error Handling**: Comprehensive error handling and logging
- ✅ **Administrator Check**: Verifies script is run with admin privileges
- ✅ **WhatIf Mode**: Preview what would happen without actually stopping services
- ✅ **Confirmation Prompt**: Asks for confirmation before stopping services

## Requirements

- Windows Operating System
- PowerShell 3.0 or higher
- Administrator privileges

## Usage

### Basic Syntax

```powershell
.\Shutdown-Services.ps1 [-ServiceNames <string[]>] [-ServicePattern <string>] [-Force] [-Timeout <int>] [-ExcludeServices <string[]>] [-WhatIf]
```

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `ServiceNames` | string[] | No* | Array of specific service names to shut down |
| `ServicePattern` | string | No* | Pattern to match service names (supports wildcards) |
| `Force` | switch | No | Force stop services immediately without graceful shutdown |
| `Timeout` | int | No | Maximum time in seconds to wait for graceful shutdown (default: 30) |
| `ExcludeServices` | string[] | No | Array of service names to exclude from shutdown |
| `WhatIf` | switch | No | Preview mode - shows what would happen without stopping services |

*At least one of `ServiceNames` or `ServicePattern` must be specified.

## Examples

### Example 1: Stop Specific Services

Stop Windows Update and Background Intelligent Transfer Service:

```powershell
.\Shutdown-Services.ps1 -ServiceNames "wuauserv","BITS"
```

### Example 2: Stop Services by Pattern

Stop all services starting with "SQL":

```powershell
.\Shutdown-Services.ps1 -ServicePattern "SQL*"
```

### Example 3: Force Stop Services

Force stop all services matching a pattern:

```powershell
.\Shutdown-Services.ps1 -ServicePattern "MyApp*" -Force
```

### Example 4: Custom Timeout

Stop a service with a 60-second timeout:

```powershell
.\Shutdown-Services.ps1 -ServiceNames "MyService" -Timeout 60
```

### Example 5: Exclude Services

Stop services matching a pattern while excluding critical services:

```powershell
.\Shutdown-Services.ps1 -ServicePattern "Test*" -ExcludeServices "TestCritical","TestEssential"
```

### Example 6: WhatIf Mode

Preview what services would be stopped without actually stopping them:

```powershell
.\Shutdown-Services.ps1 -ServicePattern "*" -WhatIf
```

### Example 7: Pipeline Input

Stop services from pipeline:

```powershell
"wuauserv","BITS" | .\Shutdown-Services.ps1
```

## Common Service Names

Here are some common Windows service names you might want to manage:

| Service Name | Display Name | Description |
|--------------|--------------|-------------|
| `wuauserv` | Windows Update | Windows Update service |
| `BITS` | Background Intelligent Transfer Service | Background file transfer |
| `Spooler` | Print Spooler | Print job management |
| `W3SVC` | World Wide Web Publishing Service | IIS web server |
| `MSSQLSERVER` | SQL Server | Microsoft SQL Server |
| `MSSQLServerOLAPService` | SQL Server Analysis Services | SSAS service |

## How It Works

1. **Administrator Check**: Verifies the script is running with administrator privileges
2. **Parameter Validation**: Ensures required parameters are provided
3. **Service Discovery**: Finds services matching the specified names or patterns
4. **Exclusion Filter**: Removes any excluded services from the list
5. **Display & Confirm**: Shows services to be stopped and asks for confirmation
6. **Graceful Shutdown**: Attempts to stop each service gracefully with timeout
7. **Force Stop**: If graceful shutdown fails, attempts force stop
8. **Summary Report**: Displays results with success/failure counts

## Output and Logging

The script provides colored console output with timestamps:

- **White**: Informational messages
- **Green**: Successful operations
- **Yellow**: Warnings
- **Red**: Errors

Example output:
```
[2024-12-11 16:00:00] [INFO] === Windows Service Shutdown Script Started ===
[2024-12-11 16:00:00] [INFO] Looking up specified services...
[2024-12-11 16:00:00] [INFO] Found 2 service(s) to stop.
[2024-12-11 16:00:01] [INFO] Attempting to stop service 'wuauserv'...
[2024-12-11 16:00:02] [SUCCESS] Service 'wuauserv' stopped successfully.
[2024-12-11 16:00:02] [INFO] === Service Shutdown Summary ===
[2024-12-11 16:00:02] [INFO] Total services processed: 2
[2024-12-11 16:00:02] [SUCCESS] Successfully stopped: 2
```

## Exit Codes

- `0`: Success - all services stopped successfully
- `1`: Failure - one or more services failed to stop or insufficient privileges

## Best Practices

1. **Always run as Administrator**: The script requires elevated privileges
2. **Use WhatIf first**: Preview the impact before actually stopping services
3. **Test with non-critical services**: Validate the script behavior in a test environment
4. **Be cautious with patterns**: Wildcards can match more services than intended
5. **Use exclusion lists**: Protect critical services from accidental shutdown
6. **Backup configurations**: Before stopping services in production environments

## Troubleshooting

### "This script requires administrator privileges"
Run PowerShell as Administrator (right-click PowerShell → "Run as Administrator")

### "Service cannot be stopped (CanStop = false)"
Some system services cannot be stopped. This is a Windows security feature.

### "Service did not stop within X seconds"
Increase the timeout value using the `-Timeout` parameter or use `-Force` to stop immediately.

### "Execution Policy" Error
If you get an execution policy error, run:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

## License

See the [LICENSE](LICENSE) file for details.

## Support

For issues, questions, or contributions, please use the GitHub issue tracker.
