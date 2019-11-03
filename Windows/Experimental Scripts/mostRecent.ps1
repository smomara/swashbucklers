if (-not (Test-Path ./recentList.txt) ) {
    New-Item -Path . -ItemType File -Name "recentList.txt" > $null  # Creates file for output
}
if (-not (Test-Path ./recentAnalysis.txt) ) {
    New-Item -Path . -ItemType File -Name "recentAnalysis.txt" > $null # Creates file for output
}

$mostRecent = Get-ChildItem "C:\" -Recurse -File -ErrorAction SilentlyContinue | 
    Select-Object -Property Name, LastWriteTime, Directory |
    Sort-Object -Descending LastWriteTime |
    Select-Object -first 200


$mostRecent | Format-Table Name, LastWriteTime, Directory -AutoSize | Out-File -FilePath ./recentList.txt -Width 4096
$words = @("password", "secret", "bad", "data", "private")

foreach ($file in $mostRecent) {
    foreach ($word in $words) {
        if ($file.Name -like ("*" + $word + "*")) {
            $text = $file.Name + " contains the word " + $word + ". The directory is " + $file.Directory
            Add-Content -Path ./recentAnalysis.txt -Value $text
        }
    }
}
