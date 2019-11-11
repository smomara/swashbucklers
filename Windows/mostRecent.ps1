param(
    [Parameter()]
    [string]$OldPath
)
Push-Location $OldPath

# Prompts the user for the number of files they want outputted at the end
$numberOfFiles = Read-Host -Prompt "How many files do you want outputted?"

# Makes sure the two files do not exist and creates them
if (Test-Path .\OutputInput\recentList.txt) {
    Remove-Item -Path .\OutputInput\recentList.txt
}
New-Item -Path .\OutputInput -ItemType File -Name "recentList.txt" > $null  # Creates file for output

if (Test-Path .\OutputInput\recentAnalysis.txt) {
    Remove-Item -Path .\OutputInput\recentAnalysis.txt
}
New-Item -Path .\OutputInput -ItemType File -Name "recentAnalysis.txt" > $null # Creates file for output

Write-Host "Searching all files in the C directory."
# Searches the C directory for the most recently written to files
$mostRecent = Get-ChildItem "C:\" -Recurse -File -ErrorAction SilentlyContinue | 
    Select-Object -Property Name, LastWriteTime, Directory |  # Grabs the name, time, and location
    Sort-Object -Descending LastWriteTime |
    Select-Object -first $numberOfFiles

Write-Host "All files in the C directory have been searched. Beginning analysis."


# Outputs the top files to recentList.txt
$mostRecent | Format-Table Name, LastWriteTime, Directory -AutoSize | Out-File -FilePath .\OutputInput\recentList.txt -Width 4096

# Checks the most recent files for these words, signals if they contain them
$words = @("password", "secret", "bad", "data", "private")

foreach ($file in $mostRecent) {
    foreach ($word in $words) {
        if ($file.Name -like ("*" + $word + "*")) {
            $text = $file.Name + " contains the word " + $word + ". The directory is " + $file.Directory
            Add-Content -Path .\OutputInput\recentAnalysis.txt -Value $text
        }
    }
}
Write-Host "Analysis Complete. Check recentAnalysis.txt and recentList.txt for the outputs."
Read-Host "Press any character to exit the script"
