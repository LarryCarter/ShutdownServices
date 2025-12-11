$serviceName = "SUS_TestService"         # This matches the prefix SUS_
$displayName = "SUS Test Service"
$exePath     = "C:\Users\larry\source\repos\ShutdownServices\SUS.TestService\publish\SUS.TestService.exe"

New-Service `
    -Name $serviceName `
    -DisplayName $displayName `
    -BinaryPathName "`"$exePath`"" `
    -StartupType Automatic