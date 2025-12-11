# Shutdown-Services

A PowerShell script to shut down specified services. You will have to run the script as Administrator.

How to use it

Example runs:

Default (prefix SUS_, real stop, log in C:\Logs\SUS_ServiceShutdown.log):
.\Shutdown-PrefixedServices.ps1


Custom prefix and log path:
.\Shutdown-PrefixedServices.ps1 -ServicePrefix "APP_" -LogFilePath "D:\Logs\AppServiceShutdown.log"


Dry run (see what would be stopped, no changes):
.\Shutdown-PrefixedServices.ps1 -DryRun


PS C:\source\repos\ShutdownServices> .\Shutdown-Services.ps1 -ServicePrefix "SUS_" -LogFilePath "C:\Logs\SUS_Shutdown.log"
[2025-12-11 08:40:24] [INFO] ==================================================================
[2025-12-11 08:40:24] [INFO] Service shutdown script started.
[2025-12-11 08:40:24] [INFO] Service prefix: 'SUS_'
[2025-12-11 08:40:24] [INFO] Log file: 'C:\Logs\SUS_Shutdown.log'
[2025-12-11 08:40:24] [INFO] Dry run mode: False
[2025-12-11 08:40:24] [INFO] Found 1 service(s) with prefix 'SUS_'.
[2025-12-11 08:40:24] [INFO] Processing service: Name='SUS_TestService', DisplayName='SUS Test Service', Status='Running'
[2025-12-11 08:40:24] [INFO] Attempting to stop service 'SUS_TestService' ('SUS Test Service')...
[2025-12-11 08:40:24] [INFO] Service 'SUS_TestService' stopped successfully.
[2025-12-11 08:40:24] [INFO] -------------------- Summary --------------------
[2025-12-11 08:40:24] [INFO] Total services matched:  1
[2025-12-11 08:40:24] [INFO] Total processed:         1
[2025-12-11 08:40:24] [INFO] Total stopped:           1
[2025-12-11 08:40:24] [INFO] Total skipped:           0
[2025-12-11 08:40:24] [INFO] Total failed:            0
[2025-12-11 08:40:24] [INFO] Script completed. Duration: 00:00:00.3542418
[2025-12-11 08:40:24] [INFO] ==================================================

