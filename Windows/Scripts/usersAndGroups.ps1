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
    return $outputString 
}

$password = Get-RandomCharacters -length 5 -characters 'abcdefghiklmnoprstuvwxyz'
$password += Get-RandomCharacters -length 4 -characters 'ABCDEFGHKLMNOPRSTUVWXYZ'
$password += Get-RandomCharacters -length 2 -characters '1234567890'
$password += Get-RandomCharacters -length 3 -characters '!"§$%&/()=?}][{@#*+'
# 14 character password - strong as well
 
$password = Edit-String $password # randomizes password string

New-Item -Path . -Name "Password.txt" -ItemType "file" -Value $password # creates .txt file with password

Clear-Host

$UserAccounts = Get-LocalUser
Write-Host "Make sure GoodUsers.txt has all of the users with all of the administrators first! (separated by lines)"
$mainuser = Read-Host "What is the main user's name? (exactly)"
$adminnumber = Read-Host "How many administrator accounts are there?"
[String[]]$AdminsAllowed = (Get-Content "C:\Users\$mainuser\Desktop\CPResources\GoodUsers.txt" | Select-Object -first $adminnumber)
[String[]]$UsersAllowed = (Get-Content "C:\Users\$mainuser\Desktop\CPResources\GoodUsers.txt" | Select-Object -skip $adminnumber)
[String[]]$AllowedAccounts = $AdminsAllowed + $UsersAllowed
$BadUsers = Compare-Object -ReferenceObject $UserAccounts -DifferenceObject $AllowedAccounts -PassThru
ForEach ($user in $AdminsAllowed) {
    Add-LocalGroupMember -Group "Administrators" -Member $user
    Set-LocalUser -Name $user -Password $password -UserMayChangePassword $True -AccountNeverExpires $False -UserMayChangePassword $True # sets password, account can expire, user can change password
    Enable-LocalUser -Name $user
    Unlock-ADAccount -Identity $user
}
ForEach ($user in $UsersAllowed) {
    Add-LocalGroupMember -Group "Administrators" -Member $user
    Set-LocalUser -Name $user -Password $password -UserMayChangePassword $True -AccountNeverExpires $False -PasswordNeverExpires $False -UserMayChangePassword $True # sets password, account can expire, user can change password
    Enable-LocalUser -Name $user
    Unlock-ADAccount -Identity $user
}
ForEach ($user in $BadUsers) {
    Disable-LocalUser -Name $user
}
Disable-LocalUser -Name "Administrator"
Disable-LocalUser -Name "Guest"
#disables admin and guest accounts
$newuser = Read-Host "Do you need to make a new user? (y/n)"
if ($newuser -eq 'y') {
    $newusername = Read-Host "What is the user's name? (exactly)"
    New-LocalUser -Name $newusername -Password $password -AccountNeverExpires $False -PasswordNeverExpires $False
}
$newgroup = Read-Host "Do you need to make a new group? (y/n)"
if ($newgroup -eq 'y') {
    $groupname = Read-Host "What is the group name? (exactly)"
    New-LocalGroup -Name $groupname
  [String[]]$groupusers = Read-Host "Which users need to be in the group? (exact names then a space)"
  ForEach ($user in $groupusers) {
      Add-LocalGroupMember -Member $user -Group $groupname
  }
}
Clear-Host
Write-Host "Users have been audited."
Write-Host "The password is $password. It has been written in Password.txt"


