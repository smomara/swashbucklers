# $allProcesses = @()
# Get-Service | ForEach-Object { $allProcesses += $_.DisplayName + " {" + $_.Name + "}`n" }
# Write-Host $allProcesses

$processStartTypes = "Automatic", "Disabled", "Manual", "Stopped", "Running"  # Lists all filter categories

function Make-List {  # function that returns all processes with a certain state/config
    param( $name )
    $temp = @()
    if ( $name -eq "Automatic" -or $name -eq "Disabled" -or $name -eq "Manual" ) {  # Checks if the status or starttype should be tested
        $filter = "StartType"
    }
    else {
        $filter = "Status"
    }
    Get-Service | 
    Where-Object { $_.$filter -eq $name} | 
        ForEach-Object { $temp += $_.DisplayName + " {" + $_.Name + "}"}
    return $temp  # Actually returns the process list
}

if (Test-Path ./ProcessInformation) {  # If the directory already exists, remove it
    Remove-Item -Path ./ProcessInformation -Recurse
}
New-Item -Path . -Name "ProcessInformation" -ItemType "directory" > $null # Creates the directory and pushes the output to null
Write-Host "Created the ProcessInformation directory"

foreach ( $processType in $processStartTypes ) {  # For every category, create a txt file with all processes in it
    $temp += Make-List $processType
    $name = $processType + "Processes.txt"  # File name
    New-Item -Path ./ProcessInformation -Name $name -ItemType "file" > $null  # Creates specific .txt file
    Write-Host "Created" $name
    foreach ($line in $temp) {
        Add-Content -Path ./ProcessInformation/$name -Value $line
    }
}
Write-Host "`nDone"