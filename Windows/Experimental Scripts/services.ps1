function Edit-Service {
    param( $service, $newStatus, $newStartType )
    $service | Set-Service -StartupType $newStartType -Status $newStatus
    $description = $service.DisplayName + " now has the start type of $newStartType and the status of $newStatus"
    Add-Content -Path ./changeLog.txt -Value $description
    # $rollbackInfo = @()
    # Get-Service -Name $serviceName | ForEach-Object { $rollbackInfo += , @($_.DisplayName, $_.Name, $_.Status, $_.StartType) }
    # Add-Content -Path ./rollbackConfig.txt -Value $rollbackInfo
  }
  
  $config = Import-Csv -Path .\config.csv -Delimiter ","
  $allprocesses = Get-Service

  foreach ($process in $config) {  # For every service with a config
    $currentProcess = $allprocesses | Where-Object {$_.DisplayName -eq $process.DisplayName}
    if($currentProcess -and $currentProcess.Status -eq $process.Status -and $currentProcess.StartType -eq $process.StartType) {
      # Add-Content -Path ./changeLog.txt -Value ($currentProcess.DisplayName  + " was left unchanged")
    } elseif($currentProcess) {
    #   Add-Content -Path ./changeLog.txt -Value ($currentProcess.DisplayName + " was changed")
    #   Write-Host $currentProcess, $process.status #<- change $currentprocess here to access some of the properties you actually want to print.
      Edit-Service $currentProcess $process.status $process.startType
    }
  }
