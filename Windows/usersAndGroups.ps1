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

function Find-Groups([String[]]$userList, [String]$type) {
    foreach ($user in $userList) {
        $listOfGroups = @()
        foreach ($group in (Get-LocalGroup)) {
            $inGroup = Get-LocalGroupMember -Name $group | Select-Object Name | ForEach-Object { $_.Name.split("\")[-1] }
            foreach ($groupmember in $inGroup) {
                if ($groupmember -eq $user) {
                    $listOfGroups += $group
                }
            }
        }
        Write-Host "User $user [$type] is in the following groups:"($listOfGroups -join ", ")
        if ($type -eq "Bad" -and -not ($user -eq "Administrator" -or $user -eq "DefaultAccount" -or $user -eq "Guest" -or $user -eq "WDAGUtilityAccount") -and $listOfGroups.length -ge 1) {
            foreach ($group in $listOfGroups) {
                Remove-LocalGroupMember -Group $group -Member $user 
            }
            Write-Host "`t$user has been removed from all groups as they are bad"
        }
    }
}

# $password = Get-RandomCharacters -length 6 -characters 'abcdefghiklmnoprstuvwxyz'
# $password += Get-RandomCharacters -length 4 -characters 'ABCDEFGHKLMNOPRSTUVWXYZ'
# $password += Get-RandomCharacters -length 3 -characters '1234567890'
# $password += Get-RandomCharacters -length 3 -characters '!"$%&/()=?}][{@#*+'
# # 16 character password - strong as well

# $plaintextPassword = $password
# $password = Edit-String $password # randomizes password string

# Set password
# $password = ConvertTo-SecureString "IWon’t4getThis1_" -AsPlainText -Force
$password = "IWon’t4getThis1_"

if (Test-Path .\OutputInput\swashbucklersPassword.txt) {
    Remove-item .\OutputInput\swashbucklersPassword.txt
}
New-Item -Path .\OutputInput -ItemType File -Name "swashbucklersPassword.txt" > $null
Add-Content -Path .\OutputInput\swashbucklersPassword.txt -Value "IWon't4getThis1_"

if (Test-Path .\OutputInput\goodUsers.txt) {
    Remove-item .\OutputInput\goodUsers.txt
}
New-Item -Path .\OutputInput -Name "goodUsers.txt" -ItemType File > $null # creates file for good users to be inputted

Write-Host "Make sure goodUsers.txt has all of the users with all of the administrators first! (separated by lines)"
Invoke-Item -Path .\OutputInput\goodUsers.txt

Read-Host "Press enter to continue.."

$UserAccounts = Get-LocalUser
[int]$adminnumber = Read-Host "How many administrator accounts are there supposed to be?"
[String[]]$AdminsAllowed = (Get-Content ".\OutputInput\goodUsers.txt" | Select-Object -first $adminnumber)
[String[]]$UsersAllowed = (Get-Content ".\OutputInput\goodUsers.txt" | Select-Object -skip $adminnumber)
[String[]]$AllowedAccounts = $AdminsAllowed + $UsersAllowed
$badUsers = Compare-Object -ReferenceObject $UserAccounts -DifferenceObject $AllowedAccounts -PassThru

Clear-Host
Write-Host "----Admin Configuration----`r`n`r`n"
ForEach ($user in $AdminsAllowed) {
    Write-Host "Adding $user [Admin] to the Administrator group and configuring their settings."
    if ( !(Confirm-Group $user "Administrators") ) {  # If the user is not in the administrator group, add them to it
        Add-LocalGroupMember -Group "Administrators" -Member $user
    }
    net user $user /passwordchg:yes /passwordreq:yes /active:yes /logonpasswordchg:no > $null
    Set-LocalUser -Name $user -PasswordNeverExpires $false # password expires
    Enable-LocalUser -Name $user
}

Write-Host "`r`n`r`n----User Configuration----`r`n`r`n"
ForEach ($user in $UsersAllowed) {
    Write-Host "Removing $user [User] from the Administrator group and configuring their settings."
    if ( -not (Confirm-Group $user "Users") ) {
        Add-LocalGroupMember -Group "Users" -Member $user
    }
    if (Confirm-Group $user "Administrators") {
        Remove-LocalGroupMember -Group "Administrators" -Member $user  # Removes user from the Administrator group
    }
    net user $user /passwordchg:yes /passwordreq:yes /active:yes /logonpasswordchg:no > $null
    Set-LocalUser -Name $user -PasswordNeverExpires $false # password expires
    Enable-LocalUser -Name $user
}

Write-Host "`r`n`r`n----Bad Guy Configuration----`r`n`r`n"
ForEach ($user in $badUsers) {
    Write-Host "Removing and disabling $user [Bad]."
    if (Confirm-Group $user "Administrators") {
        if ( !($user -match "Administrator") ) {  # Prevents the admin account from being removed
            Remove-LocalGroupMember -Group "Administrators" -Member $user  # Removes user from the Administrator group
        }
    }
    net user $user /passwordchg:yes /passwordreq:yes /active:no /logonpasswordchg:no > $null
    Set-LocalUser -Name $user -PasswordNeverExpires $false # password expires
    Disable-LocalUser -Name $user
}

Write-Host "`r`nDisabling the Administrator and Guest account."
Disable-LocalUser -Name "Administrator"
Disable-LocalUser -Name "Guest"

Write-Host "`r`nPlease set the password for all accounts now. Sorry for the inconvience."
Invoke-Item -Path .\OutputInput\swashbucklersPassword.txt
Start-Process lusrmgr.msc
# Disables admin and guest accounts

Read-Host "Press enter to continue.."
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
# Checks all groups each user is in
Write-Host "----Listing all group members----`r`n`r`n"

Find-Groups $AdminsAllowed "Admin"
Write-Host "`r`n------`r`n"
Find-Groups $UsersAllowed "User"
Write-Host "`r`n------`r`n"
Find-Groups $badUsers "Bad"

Read-Host "`r`n------`r`n`r`nPress enter to continue"

Clear-Host
Write-Host "Users have been audited."
Write-Host "The password is 'IWon’t4getThis1_'. It has been written in swashbucklersPassword.txt"
Read-Host "Press enter to exit the script"
