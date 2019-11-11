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

# Previously used " Invoke-Expression "cmd /c start powershell -NoExit -Command '& $ScriptToRun'" " but that didn't create an administrator instance

# To any futures eyes wandering this project, turn away fast. Sorry

$wpf.startButton.add_Click({
    if ($wpf.usersAndGroups.isChecked) {
        $ScriptToRun = "\usersAndGroups.ps1"
        $path = [String](Get-Location)
        Start-Process -FilePath "powershell" -Verb RunAs -Wait -ArgumentList "-File $path\$ScriptToRun $path"
        $wpf.usersAndGroups.isChecked = $false
    }
    if ($wpf.sharesAuditing.isChecked) {
        $ScriptToRun = "\shares.ps1"
        $path = [String](Get-Location)
        Start-Process -FilePath "powershell" -Verb RunAs -Wait -ArgumentList "-File $path\$ScriptToRun $path"
        $wpf.sharesAuditing.isChecked = $false
    }
    if ($wpf.displayRecentFiles.isChecked) {
        $ScriptToRun = "\mostRecent.ps1"
        $path = [String](Get-Location)
        Start-Process -FilePath "powershell" -Verb RunAs -Wait  -ArgumentList "-File $path\$ScriptToRun $path"
        $wpf.displayRecentFiles.isChecked = $false
    }
    if ($wpf.localPolicies.isChecked) {
        $ScriptToRun = "\localPolicies.ps1"
        $path = [String](Get-Location)
        Start-Process -FilePath "powershell" -Verb RunAs -Wait -ArgumentList "-File $path\$ScriptToRun $path"
        $wpf.localPolicies.isChecked = $false
    }
    if ($wpf.mozillaConfig.isChecked) {
        $ScriptToRun = "\mozillaAutoConfig.ps1"
        $path = [String](Get-Location)
        Start-Process -FilePath "powershell" -Verb RunAs -Wait -ArgumentList "-File $path\$ScriptToRun $path"
        $wpf.mozillaConfig.isChecked = $false
    }
    if ($wpf.serviceAuditing.isChecked) {
        $ScriptToRun = "\services.ps1"
        $path = [String](Get-Location)
        Start-Process -FilePath "powershell" -Verb RunAs -Wait -ArgumentList "-File $path\$ScriptToRun $path"
        $wpf.serviceAuditing.isChecked = $false
    }
    if ($wpf.sysInfo.isChecked) {
        $ScriptToRun = "\sysInfo.ps1"
        $path = [String](Get-Location)
        Start-Process -FilePath "powershell" -Verb RunAs -Wait -ArgumentList "-File $path\$ScriptToRun $path"
        $wpf.sysInfo.isChecked = $false
    }
    if ($wpf.rebootOnceDone.isChecked) {
        Restart-Computer
    }
})

$wpf.CyberPatriotScriptLauncher.ShowDialog() | Out-Null  # actually starts the launcher