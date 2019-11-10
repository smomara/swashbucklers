# Thank you, https://github.com/JimMoyle/GUIDemo/blob/master/Ep1%20WPFGUIinTenLines/PoSHGUI.ps1
Add-Type -AssemblyName presentationframework, presentationcore
$wpf = @{ }
$inputXML = Get-Content -Path ".\CyberPatriot\CyberPatriot\MainWindow.xaml"
$inputXMLClean = $inputXML -replace 'mc:Ignorable="d"','' -replace "x:N",'N' -replace 'x:Class=".*?"','' -replace 'd:DesignHeight="\d*?"','' -replace 'd:DesignWidth="\d*?"',''
[xml]$xaml = $inputXMLClean
$reader = New-Object System.Xml.XmlNodeReader $xaml
$tempform = [Windows.Markup.XamlReader]::Load($reader)
$namedNodes = $xaml.SelectNodes("//*[@*[contains(translate(name(.),'n','N'),'Name')]]")
$namedNodes | ForEach-Object {
	$wpf.Add($_.Name, $tempform.FindName($_.Name))
}

# Once the button is clicked, the scripts are ran one after another if checked
$wpf.startButton.add_Click({
    if ($wpf.usersAndGroups.isChecked) {
        $ScriptToRun = $PSCommandPath + "\usersAndGroups.ps1"
        Invoke-Expression "cmd /c start powershell -NoExit -Command '& $ScriptToRun'"
        $wpf.usersAndGroups.isChecked = $false
    }
    if ($wpf.sharesAuditing.isChecked) {
        $ScriptToRun = $PSScriptRoot + "\shares.ps1"
        Invoke-Expression "cmd /c start powershell -NoExit -Command '& $ScriptToRun'"
        $wpf.sharesAuditing.isChecked = $false
    }
    if ($wpf.displayRecentFiles.isChecked) {
        $ScriptToRun = $PSScriptRoot + "\mostRecent.ps1"
        Invoke-Expression "cmd /c start powershell -NoExit -Command '& $ScriptToRun'"
        $wpf.displayRecentFiles.isChecked = $false
    }
    if ($wpf.localPolicies.isChecked) {
        $ScriptToRun = $PSScriptRoot + "\localPolicies.ps1"
        Invoke-Expression "cmd /c start powershell -NoExit -Command '& $ScriptToRun'"
        $wpf.localPolicies.isChecked = $false
    }
    if ($wpf.mozillaConfig.isChecked) {
        $ScriptToRun = $PSScriptRoot + "\mozillaAutoConfig.ps1"
        Invoke-Expression "cmd /c start powershell -NoExit -Command '& $ScriptToRun'"
        $wpf.mozillaConfig.isChecked = $false
    }
    if ($wpf.serviceAuditing.isChecked) {
        $ScriptToRun = $PSScriptRoot + "\services.ps1"
        Invoke-Expression "cmd /c start powershell -NoExit -Command '& $ScriptToRun'"
        $wpf.serviceAuditing.isChecked = $false
    }
    if ($wpf.sysInfo.isChecked) {
        $ScriptToRun = $PSScriptRoot + "\sysInfo.ps1"
        Invoke-Expression "cmd /c start powershell -NoExit -Command '& $ScriptToRun'"
        $wpf.sysInfo.isChecked = $false
    }
    if ($wpf.rebootOnceDone.isChecked) {
        Restart-Computer
    }
})

$wpf.CyberPatriotScriptLauncher.ShowDialog() | Out-Null  # actually starts the launcher

