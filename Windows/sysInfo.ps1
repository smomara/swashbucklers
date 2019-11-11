param(
        [Parameter()]
        [string]$OldPath
    )
Push-Location $OldPath
# Creates main output file
if (Test-Path .\OutputInput\sysInfoOutput.txt) {
    Remove-item .\OutputInput\sysInfoOutput.txt
}
New-Item -Path .\OutputInput -ItemType File -Name "sysInfoOutput.txt" > $null
Write-Host (Get-Location)

$sysInfo = $true
$firewallStatus = $true
$hostsFile = $true
$scheduledTasks = $true
$processes = $true
$programs = $true
$patches
$programFiles = $true
$fileAccess = $true
$folderPermissions = $true
$systemFiles = $true
$credentials = $true

if ((Read-Host "Do you want to retrieve system info? (y/n)") -eq "n") {
    $sysInfo = $false
}
if ((Read-Host "Do you want to grab the firewall status? (y/n)") -eq "n") {
    $firewallStatus = $false
}
if ((Read-Host "Do you want to observe the hosts file? (y/n)") -eq "n") {
    $hostsFile = $false
}
if ((Read-Host "Do you want to compile the scheduled tasks? (y/n)") -eq "n") {
    $scheduledTasks = $false
}
if ((Read-Host "Do you want to organize the processes? (y/n)") -eq "n") {
    $processes = $false
}
if ((Read-Host "Do you want to look at the programs? (y/n)") -eq "n") {
    $programs = $false
}
if ((Read-Host "Do you want to observe the patches made? (y/n)") -eq "n") {
    $patches = $false
}
if ((Read-Host "Do you want to make a list of the folders in Program Files? (y/n)") -eq "n") {
    $programFiles = $false
}
if ((Read-Host "Do you want to generate a report of file access permissions? (y/n)") -eq "n") {
    $fileAccess = $false
}
if ((Read-Host "Do you want to create a list of bad folder access permissions? (y/n)") -eq "n") {
    $folderPermissions = $false
}
if ((Read-Host "Do you want to observe system files with passwords? (y/n)") -eq "n") {
    $systemFiles = $false
}
if ((Read-Host "Do you want to look at system credentials? (y/n)") -eq "n") {
    $credentials = $false
}


Clear-Host
Write-Host "Starting..."
$output = ""


# Basic Information
if ($sysInfo) {
    Write-Host "Fetching system information."
    $win_version = (Get-WmiObject -class Win32_OperatingSystem)
    $output += "Windows Version: " + (($win_version.caption -join $win_version.version) + "`r`n")
    $output += "Architecture: " + (($env:processor_architecture) + "`r`n")
    $output += "Hostname: " + (($env:ComputerName) + "`r`n")
    $output += "Current User: " + (($env:username) + "`r`n")
    $output += "Current Time/Date: " + (Get-Date) + "`r`n"
    $output += "Workgroup: " + (Get-WmiObject -Class Win32_ComputerSystem).Workgroup  + "`r`n"
}

# Determines if firewall is enabled or not
if ($firewallStatus) {
    Write-Host "Determining firewall status."
    $Firewall = New-Object -com HNetCfg.FwMgr
        $FireProfile = $Firewall.LocalPolicy.CurrentProfile  
        if ($FireProfile.FirewallEnabled -eq $False) {
            Add-Content -Path .\OutputInput\sysInfoOutput.txt -Value "Firewall is Disabled`r`n"
            } else {
            Add-Content -Path .\OutputInput\sysInfoOutput.txt -Value "Firewall is Enabled`r`n"
        }
}

# Look at System32\drivers\etc\hosts
if ($hostsFile) {
    Write-Host "Check the System32\drivers\etc\hosts file. There should be nothing in it."
    $output += "\drivers\etc\hosts`r`n"
    $output += (Get-Content $env:windir\System32\drivers\etc\hosts) + "`r`n"
}

# Outputs scheduled tasks
if ($scheduledTasks) {
    Write-Host "Compiling the list of scheduled tasks."
    $output += "List of scheduled tasks`n`r"
    $output += (schtasks /query /FO CSV /v |
                ConvertFrom-Csv |
                Where-Object { $_.TaskName -ne "TaskName" } |
                Select-Object "TaskName","Run As User", "Task to Run"  |
                Format-List |
                Out-String
            )
    $output += "`r`n"
}


# Outputs processes
if ($processes) {
    Write-Host "Organizing all processes."
    $output += "List of processes`r`n"
    $output += (Get-WmiObject win32_process |
                Select-Object Name, ProcessID, @{n='Owner';e={$_.GetOwner().User}},CommandLine |
                Sort-Object name |
                Format-Table -Wrap -Autosize |
                Out-String
            )
    $output += "`r`n"    
}

# Outputs programs
if ($programs) {
    Write-Host "Creating list of programs."
    $output += "List of programs`n`r"
    $output += (Get-Wmiobject -Class win32_product |
                Select-Object Name, Version, Caption |
                Format-Table -HideTableHeaders -AutoSize |
                Out-String -Width 4096
            )
    $output += "`r`n"
}

# Installed patches
if ($patches) {
    Write-Host "Observing patches made."
    $output += " Installed Patches`r`n"
    $output += (Get-Wmiobject -class Win32_QuickFixEngineering -Namespace "root\cimv2" |
                Select-Object HotFixID, InstalledOn |
                Format-Table -Autosize |
                Out-String
            )
    $output += "`r`n"
}

# Outputs file in Program Files
if ($programFiles) {
    Write-Host "Creating a list of all items in Program Files and Program Files (x86)."
    $output += "Files in C:\Program Files`n`r"
    $output += (Get-ChildItem "C:\Program Files"  -ErrorAction SilentlyContinue  | Select-Object Name  | Format-Table -HideTableHeaders -AutoSize | Out-String)
    $output += "`r`n"
    $output += "Files in C:\Program Files (x86)`n`r"
    $output += (Get-ChildItem "C:\Program Files (x86)"  -ErrorAction SilentlyContinue  | Select-Object Name  | Format-Table -HideTableHeaders -AutoSize | Out-String)
    $output += "`r`n"
}

# Files with full access permissions
if ($fileAccess) {
    Write-Host "Finding files with full access permissions."
    $output += " Files with Full Control and Modify Access`r`n"
    $files = get-childitem C:\
    foreach ($file in $files){
        try {
            $output += (
                Get-Childitem "C:\$file" -Include *.ps1,*.bat,*.com,*.vbs,*.txt,*.html,*.conf,*.rdp,.*inf,*.ini -Recurse -ErrorAction SilentlyContinue | 
                Get-Acl -ErrorAction SilentlyContinue |
                Select-Object Path -Expand Access |
                Where-Object {$_.identityreference -notmatch "BUILTIN|NT AUTHORITY|EVERYONE|CREATOR OWNER|NT SERVICE"} | 
                Where-Object {$_.filesystemrights -match "FullControl|Modify"} | 
                Format-Table @{Label=""; Expression={Convert-Path $_.Path}}  -HideTableHeaders -Autosize |
                Out-String -Width 4096
                )
            }
        catch {
            $output += "`nFailed to read more files`r`n"
        }
    }
}

# Folders with full access permissions
if ($folderPermissions) {
    Write-Host "Finding folders with full access permissions."
    $output += "Folders with Full Control and Modify Access`r`n"
    $folders = Get-Childitem C:\
    foreach ($folder in $folders){
        try {
            $output += (
                Get-ChildItem -Recurse "C:\$folder" -ErrorAction SilentlyContinue |
                Where-Object { $_.PSIsContainer} |
                Get-Acl -ErrorAction SilentlyContinue |
                Select-Object Path -Expand Access | 
                Where-Object {$_.identityreference -notmatch "BUILTIN|NT AUTHORITY|CREATOR OWNER|NT SERVICE"}  |
                Where-Object {$_.filesystemrights -match "FullControl|Modify"} |
                Select-Object Path, filesystemrights, IdentityReference |
                Format-Table @{Label="";Expression={Convert-Path $_.Path}}  -HideTableHeaders -Autosize |
                Out-String -Width 4096
                )
            }
        catch {
            $output += "`nFailed to read more folders`r`n"
        }
    }
}

# Checks system files with passwords
if ($systemFiles) {
    Write-Host "Observing system files with passwords."
    $output += "System Files with Passwords`r`n"
    $files = ("unattended.xml", "sysprep.xml", "autounattended.xml","unattended.inf", "sysprep.inf", "autounattended.inf","unattended.txt", "sysprep.txt", "autounattended.txt")
    $output += (Get-ChildItem C:\ -Recurse -Include $files -ErrorAction SilentlyContinue  |
                Select-String -Pattern "<Value>" |
                Out-String
            )
    $output += "`r`n"
}

# Checks stored credentials
if ($credentials) {
    Write-Host "Looking at stored credentials."
    $output += "Stored Credentials`r`n"
    $output += (cmdkey /list |
                Out-String
            )
}


Write-Host "Script is complete. Check \OutputInput\sysInfoOutput.txt for some mad insight."
Add-Content -Path .\OutputInput\sysInfoOutput.txt -Value $output
