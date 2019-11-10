# Script to rollback any service configurations that went awry
function Edit-Service {
    param( $service, $newStatus, $newStartType )
    $service | Set-Service -StartupType $newStartType -Status $newStatus
  }

$config = Import-Csv -Path .\OutputInput\rollbackConfig.csv -Delimiter ","

Write-Host "Rolling back changes."
foreach ($process in $config) {  # For every service with a config
    Edit-Service $process $process.status $process.startType
}
Write-Host "Changes reversed, script complete."
