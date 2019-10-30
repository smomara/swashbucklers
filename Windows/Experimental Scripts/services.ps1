function Edit-Service {
    param( $serviceName, $newStatus, $newStartType )
    Set-Service -Name $serviceName -StartupType $newStartType -Status $newStatus
    $description = "$serviceName now has the StartType of $newStartType and the Status of $newStatus"
    Add-Content -Path ./changeLog.txt -Value $description
}


$allProcesses = @()
Get-Service | ForEach-Object { $allProcesses += , @($_.DisplayName, $_.Name, $_.Status, $_.StartType)}  
# Every service running has an array in the format DisplayName, Name, Status, StartType

$config = @()
foreach ($line in Get-Content -Path ./config.txt) {  # Creates a similar array for easy comparisons
    $config += , $line.split(" ")
}

New-Item -Path . -Name "changeLog.txt" -ItemType File
foreach ($process in $config) {  # For every service with a config
    foreach ($currentProcess in $allProcesses) {  # Check with every service on the computer
        if ($currentProcess[0] -eq $process[0]) {  # If the service is on the computer
            if ($currentProcess[2] -eq $process[2] -and $currentProcess[3] -eq $process[3]) {  # Check if the config is correct
                break
            }
            else {  # If not, edit it
                Edit-Service $currentProcess[0] $process[2] $process[3]
                break
            }
        }
    }
}


# If a txt for each category is wanted/needed

# $processStartTypes = "Automatic", "Disabled", "Manual", "Stopped", "Running"  # Lists all filter categories

# function Make-List {  # function that returns all processes with a certain state/config
#     param( $name )
#     $temp = @()
#     if ( $name -eq "Automatic" -or $name -eq "Disabled" -or $name -eq "Manual" ) {  # Checks if the status or starttype should be tested
#         $filter = "StartType"
#     }
#     else {
#         $filter = "Status"
#     }
#     Get-Service | 
#     Where-Object { $_.$filter -eq $name} | 
#         ForEach-Object { $temp += $_.DisplayName + " {" + $_.Name + "}"}
#     return $temp  # Actually returns the process list
# }

# if (Test-Path ./ProcessInformation) {  # If the directory already exists, remove it
#     Remove-Item -Path ./ProcessInformation -Recurse
# }
# New-Item -Path . -Name "ProcessInformation" -ItemType "directory" > $null # Creates the directory and pushes the output to null
# Write-Host "Created the ProcessInformation directory"

# foreach ( $processType in $processStartTypes ) {  # For every category, create a txt file with all processes in it
#     $temp += Make-List $processType
#     $name = $processType + "Processes.txt"  # File name
#     New-Item -Path ./ProcessInformation -Name $name -ItemType "file" > $null  # Creates specific .txt file
#     Write-Host "Created" $name
#     foreach ($line in $temp) {
#         Add-Content -Path ./ProcessInformation/$name -Value $line
#     }
# }
# Write-Host "`nDone"