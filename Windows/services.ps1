param(
        [Parameter()]
        [string]$OldPath
    )
Push-Location $OldPath
function Edit-Service {
    param( $service, $newStatus, $newStartType )
    $service | Select-Object -Property DisplayName, Name, Status, StartType | Export-Csv -Append -Path ".\OutputInput\rollbackConfig.csv" -NoTypeInformation
    if ($newStatus -eq "Stopped") {
      $service | Stop-Service -Force
      $service | Set-Service -StartupType $newStartType
    } else {
      $service | Set-Service -StartupType $newStartType -Status $newStatus
    }
    $description = $service.DisplayName + " now has the start type of $newStartType and the status of $newStatus"
    Add-Content -Path ".\OutputInput\changeLog.txt" -Value $description
  }

Write-Host "Creating the necessary files for output."
if (Test-Path .\OutputInput\changeLog.txt) {
    Remove-Item -Path .\OutputInput\changeLog.txt
}
New-Item -Path .\OutputInput -ItemType File -Name "changeLog.txt" > $null  # Creates file for output

if (Test-Path .\OutputInput\rollbackConfig.csv) {
    Remove-Item -Path .\OutputInput\rollbackConfig.csv
}
New-Item -Path .\OutputInput -ItemType File -Name "rollbackConfig.csv" > $null # Creates csv for output

$win_version = Get-WmiObject -class Win32_OperatingSystem
$OS = $win_version.caption -join $win_version.version
if ($OS -match "Server") { # Checks if the image is a Server image
  $config = Import-Csv -Path .\OutputInput\win10config.csv -Delimiter ","
} else {
  $config = Import-Csv -Path .\OutputInput\win10config.csv -Delimiter ","
}
$allprocesses = Get-Service

Write-Host "Files created. Now configuring the services."

  foreach ($process in $config) {  # For every service with a config
    $currentProcess = $allprocesses | Where-Object {$_.DisplayName -eq $process.DisplayName}
    if($currentProcess -and $currentProcess.Status -eq $process.Status -and $currentProcess.StartType -eq $process.StartType) {
      Add-Content -Path .\OutputInput\changeLog.txt -Value ($currentProcess.DisplayName  + " was left unchanged")
    } elseif($currentProcess) {
      Edit-Service $currentProcess $process.status $process.startType
    }
  }

Write-Host "All services are configured. Check changeLog.txt for any changes. If you want to undo the changes, run rollback.ps1."
Read-Host "Press enter to exit the script"
