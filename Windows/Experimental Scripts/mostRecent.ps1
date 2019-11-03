# Prompts the user for the number of files they want outputted at the end
$numberOfFiles = Read-Host -Prompt "How many files do you want outputted?"

# Makes sure the two files do not exist and creates them
if (Test-Path ./recentList.txt) {
    Remove-Item -Path ./recentList.txt
}
New-Item -Path . -ItemType File -Name "recentList.txt" > $null  # Creates file for output
if (Test-Path ./recentAnalysis.txt) {
    Remove-Item -Path ./recentAnalysis.txt
}
New-Item -Path . -ItemType File -Name "recentAnalysis.txt" > $null # Creates file for output

# Searches the C directory for the most recently written to files
$mostRecent = Get-ChildItem "C:\" -Recurse -File -ErrorAction SilentlyContinue | 
    Select-Object -Property Name, LastWriteTime, Directory |  # Grabs the name, time, and location
    Sort-Object -Descending LastWriteTime |
    Select-Object -first $numberOfFiles

# Outputs the top files to recentList.txt
$mostRecent | Format-Table Name, LastWriteTime, Directory -AutoSize | Out-File -FilePath ./recentList.txt -Width 4096

# Checks the most recent files for these words, signals if they contain them
$words = @("password", "secret", "bad", "data", "private")

foreach ($file in $mostRecent) {
    foreach ($word in $words) {
        if ($file.Name -like ("*" + $word + "*")) {
            $text = $file.Name + " contains the word " + $word + ". The directory is " + $file.Directory
            Add-Content -Path ./recentAnalysis.txt -Value $text
        }
    }
}
