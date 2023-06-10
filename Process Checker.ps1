# Process Checker.ps1, v0.2, 2023
#
# By Marcus
#==========================================
$cpu_info = Get-WmiObject Win32_Processor
$logical_cores = $cpu_info.NumberOfLogicalProcessors
while ($true) {
    $processName = Read-Host "Enter the name (or part) of the process to search for (or press Enter to exit)"

    if ([string]::IsNullOrWhiteSpace($processName)) {
        break
    }

    $processes = Get-Process | Where-Object { $_.Name -like "$processName*" }

    if ($processes) {
        $groupedProcesses = $processes | Group-Object -Property Name
		$date = Get-Date -Format "dd-MM-yyyy HH:mm:ss"

        Write-Host "`nProcess found for '$processName' at $date :`n"
        foreach ($group in $groupedProcesses) {
            $groupName = $group.Name
            $groupCount = $group.Count
            $groupCPU = ($group.Group | Measure-Object -Property CPU -Average).Average / $logical_cores
            $groupWorkingSet = ($group.Group | Measure-Object -Property WorkingSet -Sum).Sum / 2

            Write-Host "= $groupName.exe (Amount: $groupCount)"
            Write-Host "- CPU usage: $([Math]::Round($groupCPU, 1)) %"
            Write-Host "- Memory Usage: $([Math]::Round($groupWorkingSet / 1MB, 1)) MB"
			Write-Host ""
        }
    } else {
        Write-Host "Process $processName is not running."
    }

    Write-Host
}