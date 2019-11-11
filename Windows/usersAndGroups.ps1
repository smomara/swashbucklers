param(
        [Parameter()]
        [string]$OldPath
    )
Push-Location $OldPath

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
    $outputString = ConvertTo-SecureString $outputString -AsPlainText -Force
    return $outputString
}

function Confirm-Group([string]$user, [string]$group) {
    $inGroup = $false
    $members = Get-LocalGroupMember -Group $group | Select-Object Name | ForEach-Object { $_.Name.split("\")[-1]  }
    ForEach ($member in $members) {
        if ($member -match $user) {
            $inGroup = $true
        }
    }
    return $inGroup
}

$password = Get-RandomCharacters -length 6 -characters 'abcdefghiklmnoprstuvwxyz'
$password += Get-RandomCharacters -length 4 -characters 'ABCDEFGHKLMNOPRSTUVWXYZ'
$password += Get-RandomCharacters -length 3 -characters '1234567890'
$password += Get-RandomCharacters -length 3 -characters '!"$%&/()=?}][{@#*+'
# 16 character password - strong as well

$plaintextPassword = $password
$password = Edit-String $password # randomizes password string

if (Test-Path .\OutputInput\swashbucklersPassword.txt) {
    Remove-item .\OutputInput\swashbucklersPassword.txt
}
New-Item -Path .\OutputInput -ItemType File -Name "swashbucklersPassword.txt" > $null
Add-Content -Path .\OutputInput\swashbucklersPassword.txt -Value $plaintextPassword

if (Test-Path .\OutputInput\goodUsers.txt) {
    Remove-item .\OutputInput\goodUsers.txt
}
New-Item -Path .\OutputInput -Name "goodUsers.txt" -ItemType File > $null # creates file for good users to be inputted

Write-Host "Make sure goodUsers.txt has all of the users with all of the administrators first! (separated by lines)"
Invoke-Item -Path .\OutputInput\goodUsers.txt

Read-Host "Enter a character to continue.."

$UserAccounts = Get-LocalUser
[int]$adminnumber = Read-Host "How many administrator accounts are there supposed to be?"
[String[]]$AdminsAllowed = (Get-Content ".\OutputInput\goodUsers.txt" | Select-Object -first $adminnumber)
[String[]]$UsersAllowed = (Get-Content ".\OutputInput\goodUsers.txt" | Select-Object -skip $adminnumber)
[String[]]$AllowedAccounts = $AdminsAllowed + $UsersAllowed
$badUsers = Compare-Object -ReferenceObject $UserAccounts -DifferenceObject $AllowedAccounts -PassThru

Clear-Host
Write-Host "`r`n`r`n----Admin Configuration----`r`n`r`n"
ForEach ($user in $AdminsAllowed) {
    Write-Host "Adding $user [Admin account] to the Administrator group and configuring their settings."
    if ( !(Confirm-Group $user "Administrators") ) {  # If the user is not in the administrator group, add them to it
        Add-LocalGroupMember -Group "Administrators" -Member $user
    }
    Set-LocalUser -Name $user -Password $password -UserMayChangePassword $true -PasswordNeverExpires $false # sets password, account can expire, user can change password
    Enable-LocalUser -Name $user
}

Write-Host "`r`n`r`n----User Configuration----`r`n`r`n"
ForEach ($user in $UsersAllowed) {
    Write-Host "Removing $user [User account] from the Administrator group and configuring their settings."
    if ( -not (Confirm-Group $user "Users") ) {
        Add-LocalGroupMember -Group "Users" -Member $user
    }
    if (Confirm-Group $user "Administrators") {
        Remove-LocalGroupMember -Group "Administrators" -Member $user  # Removes user from the Administrator group
    }
    Set-LocalUser -Name $user -Password $password -UserMayChangePassword $true -PasswordNeverExpires $false  # sets password, account can expire, user can change password
    Enable-LocalUser -Name $user
}

Write-Host "`r`n`r`n----Bad Guy Configuration----`r`n`r`n"
ForEach ($user in $badUsers) {
    Write-Host "Removing and disabling $user [Bad account]."
    if (Confirm-Group $user "Administrators") {
        if ( !($user -match "Administrator") ) {  # Prevents the admin account from being removed
            Remove-LocalGroupMember -Group "Administrators" -Member $user  # Removes user from the Administrator group
        }
    }
    Disable-LocalUser -Name $user
}
Write-Host "`r`nDisabling the Administrator and Guest account."
Disable-LocalUser -Name "Administrator"
Disable-LocalUser -Name "Guest"
# Disables admin and guest accounts


Read-Host "Enter a character to continue.."
Clear-Host

$newuser = 'y'
while ($newuser -eq 'y') {
    $newuser = Read-Host "Do you need to make a new user? (y/n)"
    if ($newuser -eq 'y') {
        $newusername = Read-Host "What is the user's name? (exactly)"
        New-LocalUser -Name $newusername -Password $password
        Write-Host "User $newusername created. Welcome $newusername."
    }
}

Clear-Host
$newgroup = 'y'
while ($newgroup -eq 'y') {
    $newgroup = Read-Host "Do you need to make a new group? (y/n)"
    if ($newgroup -eq 'y') {
        $groupName = Read-Host "What is the group name? (exactly)"
        New-LocalGroup -Name $groupName > $null
        Write-Host "Group $groupName created."
        $addUser = 'y'
        while ($addUser -eq 'y') {
            $addUser = Read-Host "Do you want to add a user to the group? (y/n)"
            if ($addUser -eq 'y') {
                $user = Read-Host "What is the name of the user you want to add? (exactly)"
                Add-LocalGroupMember -Group $groupName -Member $user
                Write-Host "$user added to $groupName."
            }
        }
    }
}
Clear-Host
Write-Host "Users have been audited."
Write-Host "The password is $plaintextPassword. It has been written in swashbucklersPassword.txt"
Read-Host "Press any character to exit the script"
