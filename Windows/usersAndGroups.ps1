# Makes random password and outputs password in Password.txt
function Get-RandomCharacters($length, $characters) {
    $random = 1..$length | ForEach-Object { Get-Random -Maximum $characters.length }
    $private:ofs=""
    return [String]$characters[$random]
}
 
function Edit-String([string]$inputString){     
    $characterArray = $inputString.ToCharArray()   
    $scrambledStringArray = $characterArray | Get-Random -Count $characterArray.Length     
    $outputString = -join $scrambledStringArray
    $outputString = ConvertTo-SecureString $outputString
    return $outputString
}

$password = Get-RandomCharacters -length 6 -characters 'abcdefghiklmnoprstuvwxyz'
$password += Get-RandomCharacters -length 4 -characters 'ABCDEFGHKLMNOPRSTUVWXYZ'
$password += Get-RandomCharacters -length 3 -characters '1234567890'
$password += Get-RandomCharacters -length 3 -characters '!"§$%&/()=?}][{@#*+'
# 16 character password - strong as well
 
$password = Edit-String $password # randomizes password string

New-Item -Path .\OutputInput -Name "swashbucklersPassword.txt" -ItemType File -Value $password > $null # creates .txt file with password

Write-Host "Make sure goodUsers.txt has all of the users with all of the administrators first! (separated by lines)"
New-Item -Path .\OutputInput -Name "goodUsers.txt" -ItemType File > $null # creates file for good users to be inputted
Read-Host "Enter a character to continue.."

$UserAccounts = Get-LocalUser
[int]$adminnumber = Read-Host "How many administrator accounts are there supposed to be?"
[String[]]$AdminsAllowed = (Get-Content ".\OutputInput\goodUsers.txt" | Select-Object -first $adminnumber)
[String[]]$UsersAllowed = (Get-Content ".\OutputInput\goodUsers.txt" | Select-Object -skip $adminnumber)
[String[]]$AllowedAccounts = $AdminsAllowed + $UsersAllowed
$badUsers = @()
Compare-Object -ReferenceObject $UserAccounts -DifferenceObject $AllowedAccounts -PassThru | Where-Object { $_.SideIndicator -eq '=>' } | ForEach-Object  { $badUsers += $_.InputObject }


ForEach ($user in $AdminsAllowed) {
    Write-Host "Adding $user [Admin account] to the Administrator group and configuring their settings."
    Add-LocalGroupMember -Group "Administrators" -Member $user
    Set-LocalUser -Name $user -Password $password -UserMayChangePassword $True -AccountNeverExpires $False -UserMayChangePassword $True # sets password, account can expire, user can change password
    Enable-LocalUser -Name $user
}

ForEach ($user in $UsersAllowed) {
    Write-Host "Removing $user [User account] from the Administrator group and configuring their settings."
    Add-LocalGroupMember -Group "User" -Member $user
    Remove-LocalGroupMember -Group "Administrators" -Member $user  # Removes user from the Administrator group
    Set-LocalUser -Name $user -Password $password -UserMayChangePassword $True -AccountNeverExpires $False -PasswordNeverExpires $False -UserMayChangePassword $True # sets password, account can expire, user can change password
    Enable-LocalUser -Name $user
}
ForEach ($user in $badUsers) {
    Write-Host "Disabling $user [Bad user]."
    Disable-LocalUser -Name $user
}
Write-Host "Disabling the Administrator and Guest account."
Disable-LocalUser -Name "Administrator"
Disable-LocalUser -Name "Guest"
# Disables admin and guest accounts

$newuser = 'y'
while ($newuser -eq 'y') {
    $newuser = Read-Host "Do you need to make a new user? (y/n)"
    if ($newuser -eq 'y') {
        $newusername = Read-Host "What is the user's name? (exactly)"
        New-LocalUser -Name $newusername -Password $password -AccountNeverExpires $False -PasswordNeverExpires $False
    }
}

$newgroup = 'y'
while ($newgroup -eq 'y') {
    $newgroup = Read-Host "Do you need to make a new group? (y/n)"
    $groupName = Read-Host "What is the group name? (exactly)"
    New-LocalGroup -Name $groupName
    $addUser = 'y'
    while ($addUser -eq 'y') {
        $addUser = Read-Host "Do you want to add a user to the group? (y/n)"
        if ($addUser -eq 'y') {
            $user = Read-Host "What is the name of the user you want to add? (exactly)"
            Add-LocalGroupMember -Group $groupName -Member $user
        }
    }
}
Clear-Host
Write-Host "Users have been audited."
Write-Host "The password is $password. It has been written in Password.txt"


