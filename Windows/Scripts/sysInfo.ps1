# Basic Information
$win_version = (Get-WmiObject -class Win32_OperatingSystem)
$sysOutput += "Windows Version: " + (($win_version.caption -join $win_version.version) + "`r`n")
$sysOutput += "Architecture: " + (($env:processor_architecture) + "`r`n")
$sysOutput += "Hostname: " + (($env:ComputerName) + "`r`n")
$sysOutput += "Current User: " + (($env:username) + "`r`n")
$sysOutput += "Current Time/Date: " + (Get-Date) + "`r`n"
$sysOutput += "Workgroup: " + (Get-WmiObject -Class Win32_ComputerSystem).Workgroup  + "`r`n"

Write-Host $sysOutput

$output = ""
# Determines if firewall is enabled or not
$Firewall = New-Object -com HNetCfg.FwMgr
    $FireProfile = $Firewall.LocalPolicy.CurrentProfile  
    if ($FireProfile.FirewallEnabled -eq $False) {
        Write-Host "Firewall is Disabled`r`n"
        } else {
        Write-Host "Firwall is Enabled`r`n"
        }


Write-Host "Check the \drivers\etc\hosts file. There should be nothing in it`r`n"
Write-Host (get-content $env:windir\System32\drivers\etc\hosts | out-string) + "`r`n"

# $output = $output +  "Current System Time: " + (get-date)
# $output = $output + (schtasks /query /FO CSV /v | convertfrom-csv | where { $_.TaskName -ne "TaskName" } | select "TaskName","Run As User", "Task to Run"  | fl | out-string)
# $output = $output +  "`r`n"

# Outputs programs
# $output = $output +  (get-wmiobject -Class win32_product | select Name, Version, Caption | ft -hidetableheaders -autosize| out-string -Width 4096)
# $output = $output +  "`r`n"

$output = $output + "`n`rC:\Program Files`r`n"
$output = $output +  "-------------"
$output = $output + (Get-ChildItem "C:\Program Files"  -ErrorAction SilentlyContinue  | Select-Object Name  | Format-Table -HideTableHeaders -AutoSize | Out-String )
$output = $output + "C:\Program Files (x86)`r`n"
$output = $output +  "-------------------"
$output = $output + (Get-ChildItem "C:\Program Files (x86)"  -ErrorAction SilentlyContinue  | Select-Object Name  | Format-Table -HideTableHeaders -AutoSize | Out-String )
$output = $output +  "`r`n"

Write-Host $output
