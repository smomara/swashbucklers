#!/bin/bash

# cyberpatriot bash script for ubuntu 14
# swashbucklers

# checks for sudo
if [ $EUID -ne 0 ]
then
	clear
	echo "This script must be run with root permissions"
	echo "Enter 'sudo !!' to run this script again with root permissions"
	exit 1
fi

# checks completed forensics
clear
echo "Have you completed the forensics questions? yes or no"
read -r forensics
if [ "$forensics" == "no" ]
then
	echo "This script must be run AFTER the completion of the forensics questions"
	echo "Complete the forensics questions and run this script again"
	exit 1
fi

# displays menu
function menu(){                
	echo "Swashbucklers"
	echo "Choose a task"
	echo "1) Updates"
	echo "2) Users and Groups"
	echo "3) User Policy"
	echo "4) Network"
	echo "5) Scans"
	echo "6) Exit"
	echo "Choose an option: 1-6"
}

# configures apt and installs updates
function updates(){
	# automatic and secure updates
	echo ""
	echo "Configuring apt..."
	apt-get install unattended-upgrades -y
	dpkg-reconfigure unattended-upgrades
	echo "deb http://us.archive.ubuntu.com/ubuntu/ xenial main restricted multiverse universe" > /etc/apt/sources.list
	echo "deb http://us.archive.ubuntu.com/ubuntu/ xenial-updates main restricted multiverse universe" >> /etc/apt/sources.list
	echo "deb http://security.ubuntu.com/ubuntu/ xenial-security main restricted multiverse universe" >> /etc/apt/sources.list
	touch /etc/apt/apt.conf.d/10periodic
	if [[ $(grep 'APT::Periodic::Update-Package-Lists' /etc/apt/apt.conf.d/10periodic) ]]
	then
		sed -i 's/APT::Periodic::Update-Package-Lists/APT::Periodic::Update-Package-Lists "1";/g' /etc/apt/apt.conf.d/10periodic
	else
		echo -e "APT::Periodic::Update-Package-Lists \"1\";" >> /etc/apt/apt.conf.d/10periodic
	fi
	if [[ $(grep 'APT::Periodic::Download-Upgradeable-Packages' /etc/apt/apt.conf.d/10periodic) ]]
	then
		sed -i 's/APT::Periodic::Download-Upgradeable-Packages/APT::Periodic::Download-Upgradeable-Packages "1";/g' /etc/apt/apt.conf.d/10periodic	
	else
		echo -e "APT::Periodic::Download-Upgradeable-Packages \"1\";" >> /etc/apt/apt.conf.d/10periodic
	fi
	if [[ $(grep 'APT::Periodic::Unattended-Upgrade' /etc/apt/apt.conf.d/10periodic) ]]
	then
		sed -i 's/APT::Periodic::Unattended-Upgrade/APT::Periodic::Unattended-Upgrade "1";/g' /etc/apt/apt.conf.d/10periodic
	else
		echo -e "APT::Periodic::Unattended-Upgrade \"1\";" >> /etc/apt/apt.conf.d/10periodic
	fi
	touch /etc/apt/apt.conf.d/20auto-upgrades
	if [[ $(grep 'APT::Periodic::Update-Package-Lists' /etc/apt/apt.conf.d/20auto-upgrades) ]]
	then
		sed -i 's/APT::Periodic::Update-Package-Lists/APT::Periodic::Update-Package-Lists "1";/g' /etc/apt/apt.conf.d/10periodic
	else
		echo -e "APT::Periodic::Update-Package-Lists \"1\";" >> /etc/apt/apt.conf.d/20auto-upgrades
	fi
	if [[ $(grep 'APT::Periodic::Download-Upgradeable-Packages' /etc/apt/apt.conf.d/20-auto-upgrades) ]]
	then
		sed -i 's/APT::Periodic::Download-Upgradeable-Packages/APT::Periodic::Download-Upgradeable-Packages "1";/g' /etc/apt/apt.conf.d/20-auto-upgrades
	else
		echo -e "APT::Periodic::Download-Upgradeable-Packages \"1\";" >> /etc/apt/apt.conf.d/20auto-upgrades
	fi
	if [[ $(grep 'APT::Periodic::Unattended-Upgrade' /etc/apt/apt.conf.d/20auto-upgrades) ]]
	then
		sed -i 's/APT::Periodic::Unattended-Upgrade/APT::Periodic::Unattended-Upgrade "1";/g' /etc/apt/apt.conf.d/20-auto-upgrades
	else
		echo -e "APT::Periodic::Unattended-Upgrade \"1\";" >> /etc/apt/apt.conf.d/20auto-upgrades
	fi

	# checks /etc/apt/sources.list
	echo ""
	echo "Check the sources file for malicious code..."
	echo ""
	echo "/etc/apt/sources.list"
	echo ""
	cat /etc/apt/sources.list
	echo ""
	read -n 1 -s -r -p "Press any key to continue"
	echo ""

	# checks /etc/apt/sources.list.d
	echo ""
	echo "Check the sources directory for malicious files..."
	echo ""
	echo "/etc/apt/sources.list.d"
	echo ""
	find /etc/apt/sources.list.d | paste -s -d' ' | cut -d',' -f2-
	echo ""
	read -n 1 -s -r -p "Press any key to continue"
	echo ""

	# install updates
	echo ""
	echo "Installing updates (grab some snacks, this is going to take a while)..."
	apt-get update 
	apt-get dist-upgrade -y 
	apt-get autoremove -y 

	echo ""
	echo "Exiting updates..."
	sleep 1
}

# manages users and groups
function usersAndGroups(){
	# removes users and changes roles
	i=1
	for userwid in $(cut -d: -f1,3 /etc/passwd | grep -E ':[ 0-9 ]{4}$|:0')
	do
		echo ""
		user=$( echo "$userwid" | cut -d: -f1 )
		if [ "$user" == "root" ]
		then
			echo "${userwid}"
		else
			if [[ $(grep sudo /etc/group | grep $user) ]]
			then
				admin="yes"
				echo "${userwid} is an administrator"
			else
				admin="no"
				echo "${userwid} is a standard user"
			fi
			echo "Do you need to modify ${user}? yes or no"
			read -r mod
			if [ "$mod" == "yes" ]
			then
				echo "Do you need to remove ${user}? yes or no"
				read -r remove
				if [ "$remove" == "yes" ]
				then
					echo "Removing ${user}..."
					userdel "$user"
				else
					echo "Do you need to change ${user}'s role? yes or no"
					read -r role
					if [ "$role" == "yes" ]
					then
						if [ "$admin" == "yes" ]
						then
							echo "Making ${user} a standard user..."
							deluser "$user" sudo &> /dev/null
							unset "$mod"
							unset "$role"
						else
							echo "Making ${user} an administrator..."
							usermod -a -G sudo "$user" &> /dev/null
							unset "$mod"
							unset "$role"
						fi
					fi
				fi
			fi
		fi
		i=$((i+1))
	done

	# adds users
	while :
	do
		echo ""
		echo "Do you need to add any users? yes or no"
		read -r add
		if [ $add == "yes" ]
		then
			echo "What is the username of the user you need to add?"
			read -r user
			echo "Adding ${user}..."
			useradd "$user"
		else
			break
		fi
	done

	# changes all passwords
	echo ""
	echo "Changing passwords..."
	awk -F: '{print $1}' /etc/passwd | sed 's/$/:P@55w0rd_RBR!/' | chpasswd &> /dev/null

	# lock out root
	echo ""
	echo "Locking out root..."
	passwd -l root &> /dev/null

	# locks or unlocks users
	while :
	do
		echo ""
		locked=$(grep :! /etc/shadow | cut -d: -f1 | paste -s -d ',')
		echo "The current locked users are ${locked}"
		echo "Do you need to change the lock status of any users? yes or no"
		read -r change
		if [ "$change" == "yes" ]
		then
			echo "What is the username of the user you need to change?"
			read -r user
			echo "Do you need to unlock ${user}? yes or no"
			read -r unlock
			if [ "$unlock" == "yes" ]
			then
				echo "Unlocking ${user}..."
				passwd -u "$user" &> /dev/null
				unset "$unlock"
				unset "$change"
				unset "$user"
			else
				echo "Locking ${user}..."
				passwd -l "$user" &> /dev/null
				unset "$unlock"
				unset "$change"
				unset "$user"
			fi
		else
			break
		fi
	done

	# disables guest user
	echo ""
	echo "Disabling guest user..."
	if [[ $(grep 'allow-guest' /etc/lightdm/lightdm.conf) ]]
	then
		sed -i 's/allow-guest/allow-guest=false/g' /etc/lightdm/lightdm.conf
	else
		echo "allow-guest=false" >> /etc/lightdm/lightdm.conf
	fi

	# disables autologin
	echo ""
	echo "Disabling autologin..."
	sed -i 's/autologin-user//g' /etc/lightdm/lightdm.conf
	
	# ensures root in g 0
	echo ""
	echo "Changing root's main group to 0..."
	usermod -g 0 root
	
	# changes home perms
	echo ""
	echo "Changing home directory permissions..."
	chmod 750 /home/* &> /dev/null

	# checks lightdm
	echo ""
	echo "Check lightdm.conf for autologin or other vulnerabilities..."
	echo ""
	echo "/etc/lightdm/lightdm.conf"
	echo ""
	cat /etc/lightdm/lightdm.conf
	echo ""
	read -n 1 -s -r -p "Press any key to continue"
	echo ""

	# checks sudoers
	echo ""
	echo "Check sudoers for !authenticate or other vulnerabilities..."
	echo ""
	echo "/etc/sudoers"
	echo ""
	cat /etc/sudoers
	echo ""
	read -n 1 -s -r -p "Press any key to continue"
	echo ""

	# checks sudoers.d
	echo ""
	echo "Check sudoers.d for any insecure files..."
	echo ""
	echo "/etc/sudoers.d"
	echo ""
	find /etc/sudoers.d | paste -s -d ',' | cut -d, -f2-
	echo ""
	read -n 1 -s -r -p "Press any key to continue"
	echo ""

	# checks home dir
	echo ""
	echo "Check home directory for file violations..."
	echo""
	find /home/ -iname *.mp4
	find /home/ -iname *.mp3
	find /home/ -iname *.ogg
	find /home/ -iname *.jpg
	find /home/ -iname *.jpeg
	find /home/ -iname *.xls
	find /home/ -iname *.pdf
	find /home/ -iname *.txt
	find /home/ -iname *.docx
	find /home/ -iname *.7z
	find /home/ -iname *.zip
	find /home/ -iname *.exe
	find /home/ -iname *.avi
	find /home/ -iname *.mov
	find /home/ -iname *.wmv
	find /home/ -iname *.mpg
	find /home/ -iname *.mpeg
	find /home/ -iname *.xlsx
	echo ""
	read -n 1 -s -r -p "Press any key to continue"
	echo ""

	echo ""
	echo "Exiting users and groups..."
	sleep 1
}

# configures user policy
function userPolicy(){
	# password aging
	echo ""
	echo "Enabling password aging..."
	sed -i 's/^PASS_MAX_DAYS/PASS_MAX_DAYS 90/g' /etc/login.defs
	sed -i 's/^PASS_MIN_DAYS/PASS_MIN_DAYS 7/g' /etc/login.defs
	sed -i 's/^PASS_WARN_AGE/PASS_WARN_AGE 7/g' /etc/login.defs
	
	# changes default perms to 027
	echo ""
	echo "Changing umask..."
	sed -i 's/^UMASK/UMASK 027/g' /etc/login.defs

	# enables encryption
	echo ""
	echo "Enabling encryption..."
	if [[ $(grep '^ENCRYPT_METHOD' /etc/login.defs) ]]
	then
		sed -i 's/^ENCRYPT_METHOD/ENCRYPT_METHOD SHA512/g' /etc/login.defs
	else
		echo "ENCRYPT_METHOD SHA512" >> /etc/login.defs 
	fi
	sed -i '/ROUNDS/ s/^/# /' /etc/login.defs

	# installs cracklib
	echo ""
	echo "Installing cracklib..."
	apt-get install libpam-cracklib -y &> /dev/null

	# configures common-password
	echo ""
	echo "Enforcing password complexity and history..."
	if [[ $(grep -v '^#' /etc/pam.d/common-password | grep 'pam_cracklib.so' /etc/pam.d/common-password) ]]
	then
		sed -i 's/^password.*pam_cracklib.so/password requisite pam_cracklib.so retry=3 minlen=8 ucredit=-1 lcredit=-1 dcredit=-1 ocredit=-1/g' /etc/pam.d/common-password
	else
		echo "password requisite pam_cracklib.so retry=3 minlen=8 ucredit=-1 lcredit=-1 dcredit=-1 ocredit=-1" >> /etc/pam.d/common-password
	fi
	if [[ $(grep -v '^#' /etc/pam.d/common-password | grep 'pam_pwhistory.so') ]]
	then
		sed -i 's/^password.*pam_pwhistory.so/password required pam_pwhistory.so remember=24 use_authtok/g' /etc/pam.d/common-password
	else
		echo "password required pam_pwhistory.so remember=24 use_authtok" >> /etc/pam.d/common-password
	fi
	if [[ $(grep -v '^#' /etc/pam.d/common-password | grep 'pam_unix.so') ]]
	then
		sed -i 's/^password.*pam_unix.so/password [success=1 default=ignore] pam_unix.so sha512/g' /etc/pam.d/common-password
	else
		echo "password [success=1 default=ignore] pam_unix.so sha512" >> /etc/pam.d/common-password
	fi

	# configures common-auth
	echo ""
	echo "Enforcing a lockout policy..."
	echo ""
	echo "Open a root shell in case of any errors"
	echo ""
	read -n 1 -s -r -p "Press any key to continue"
	echo ""
	echo "auth required pam_tally2.so onerr=fail audit silent deny=5 unlock_time=900" >> /etc/pam.d/common-auth

	# configures su
	echo ""
	echo "Enforcing su policy..."
	echo "auth required pam_wheel.so" >> /etc/pam.d/su
	
	# fixes perms
	echo ""
	echo "Fixing permissions..."
	chown root:root /etc/passwd &> /dev/null
	chmod 644 /etc/passwd &> /dev/null
	chown root:shadow /etc/shadow &> /dev/null
	chmod o-rwx,g-wx /etc/shadow &> /dev/null
	chown root:root /etc/group &> /dev/null
	chmod 644 /etc/group &> /dev/null
	chown root:shadow /etc/gshadow &> /dev/null
	chmod o-rwx,g-rw /etc/gshadow &> /dev/null
	chown root:root /etc/passwd~ &> /dev/null
	chmod 600 /etc/passwd~ &> /dev/null
	chown root:root /etc/shadow~ &> /dev/null
	chmod 600 /etc/shadow~ &> /dev/null
	chown root:root /etc/group~ &> /dev/null
	chmod 600 /etc/group~ &> /dev/null
	chown root:root /etc/gshadow~ &> /dev/null
	chmod 600 /etc/gshadow~ &> /dev/null
	
	echo ""
	echo "Exiting user policy..."
	sleep 1

}

# configures network services
function network(){
	# configures firewall
	echo ""
	echo "Configuring firewall..."
	apt-get install ufw -y &> /dev/null
	ufw enable &> /dev/null
	ufw default deny incoming &> /dev/null
	ufw default allow outgoing &> /dev/null
	ufw logging on &> /dev/null
	service ufw restart &> /dev/null

	# displays open ports
	echo ""
	echo "Displaying open ports..."
	echo ""
	echo "lsof -i"
	echo ""
	lsof -i
	echo ""
	read -n 1 -s -r -p "Press any key to continue"
	echo ""

	# displays services
	echo ""
	echo "Displaying services..."
	echo ""
	echo "service --status-all"
	echo ""
	service --status-all
	echo ""
	read -n 1 -s -r -p "Press any key to continue"
	echo ""

	# checks hosts files
	echo ""
	echo "Check hosts for malicious code..."
	sleep 1
	echo ""
	echo "/etc/hosts"
	echo ""
	cat /etc/hosts
	echo ""
	read -n 1 -s -r -p "Press any key to continue"
	echo ""

	# checks dns file
	echo ""
	echo "Check DNS file for malicious code..."
	sleep 1
	echo ""
	echo "/etc/resolv.conf"
	echo ""
	cat /etc/resolv.conf
	echo ""
	read -n 1 -s -r -p "Press any key to continue"
	echo ""

	# configures sysctl
	echo "Check sysctl directory for malicious or unnecessary configurations..."
	sleep 1
	echo ""
	echo "/etc/sysctl.d/"
	echo ""
	find /etc/sudoers.d | paste -s -d ',' | cut -d, -f2-
	echo ""
	read -n 1 -s -r -p "Press any key to continue"
	echo ""
	echo "Configuring sysctl..."

		# disabling ipv6
		if [[ $(grep '^net.ipv6.conf.all.disable_ipv6' /etc/sysctl.conf) ]]
		then
			sed -i 's/net.ipv6.conf.all.disable_ipv6/net.ipv6.conf.all.disable_1pv6 = 1/g' /etc/sysctl.conf
		else
			echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf 
		fi
		if [[ $(grep '^net.ipv6.conf.default.disable_ipv6' /etc/sysctl.conf) ]]
		then
			sed -i 's/net.ipv6.conf.default.disable_ipv6/net.ipv6.conf.default.disable_1pv6 = 1/g' /etc/sysctl.conf
		else
			echo "net.ipv6.conf.adefault.disable_ipv6 = 1" >> /etc/sysctl.conf 
		fi
		if [[ $(grep '^net.ipv6.conf.lo.disable_ipv6' /etc/sysctl.conf) ]]
		then
			sed -i 's/net.ipv6.conf.lo.disable_ipv6/net.ipv6.conf.lo.disable_1pv6 = 1/g' /etc/sysctl.conf
		else
			echo "net.ipv6.conf.lo.disable_ipv6 = 1" >> /etc/sysctl.conf 
		fi

		# configuring ipv4
		if [[ $(grep '^net.ipv4.ip_forward' /etc/sysctl.conf) ]]
		then
			sed -i 's/net.ipv4.ip_forward/net.ipv4.ip_forward = 0/g' /etc/sysctl.conf
		else
			echo "net.ipv4.ip_forward = 0" >> /etc/sysctl.conf 
		fi
		if [[ $(grep '^net.ipv4.conf.default.accept_source_route' /etc/sysctl.conf) ]]
		then
			sed -i 's/net.ipv4.conf.default.accept_source_route/net.ipv4.conf.default.accept_source_route = 1/g' /etc/sysctl.conf
		else
			echo "net.ipv4.conf.default.accept_source_route = 0" >> /etc/sysctl.conf 
		fi
		if [[ $(grep '^net.ipv4.tcp_syncookies' /etc/sysctl.conf) ]]
		then
			sed -i 's/net.ipv4.tcp_syncookies/net.ipv4.tcp_syncookies = 1/g' /etc/sysctl.conf
		else
			echo "net.ipv4.tcp_syncookies = 1" >> /etc/sysctl.conf 
		fi
		if [[ $(grep '^net.ipv4.conf.all.send_redirects' /etc/sysctl.conf) ]]
		then
			sed -i 's/net.ipv4.conf.all.send_redirects/net.ipv4.conf.all.send_redirects = 0/g' /etc/sysctl.conf
		else
			echo "net.ipv4.conf.all.send_redirects = 0" >> /etc/sysctl.conf 
		fi
		if [[ $(grep '^net.ipv4.conf.default.send_redirects' /etc/sysctl.conf) ]]
		then
			sed -i 's/net.ipv4.conf.default.send_redirects/net.ipv4.conf.default.send_redirects/g' /etc/sysctl.conf
		else
			echo "net.ipv4.conf.default.send_redirects" >> /etc/sysctl.conf 
		fi
		if [[ $(grep '^net.ipv4.conf.all.log_martians' /etc/sysctl.conf) ]]
		then
			sed -i 's/net.ipv4.conf.all.log_martians/net.ipv4.conf.all.log_martians = 1/g' /etc/sysctl.conf
		else
			echo "net.ipv4.conf.all.log_martians = 1" >> /etc/sysctl.conf
		fi
		if [[ $(grep '^net.ipv4.conf.default.secure_redirects' /etc/sysctl.conf) ]]
		then
			sed -i 's/net.ipv4.conf.default.secure_redirects/net.ipv4.conf.default.secure_redirects = 0/g' /etc/sysctl.conf
		else
			echo "net.ipv4.conf.default.secure_redirects = 0" >> /etc/sysctl.conf
		fi
		if [[ $(grep '^net.ipv4.icmp_echo_ignore_broadcasts' /etc/sysctl.conf) ]]
		then
			sed -i 's/net.ipv4.icmp_echo_ignore_broadcasts/net.ipv4.icmp_echo_ignore_broadcasts = 0/g' /etc/sysctl.conf
		else
			echo "net.ipv4.icmp_echo_ignore_broadcasts = 1" >> /etc/sysctl.conf
		fi
		if [[ $(grep '^net.ipv4.conf.all.rp_filter' /etc/sysctl.conf) ]]
		then
			sed -i 's/net.ipv4.conf.all.rp_filter/net.ipv4.conf.all.rp_filter = 1/g' /etc/sysctl.conf
		else
			echo "net.ipv4.conf.all.rp_filter = 1" >> /etc/sysctl.conf
		fi
		if [[ $(grep '^net.ipv4.conf.default.rp_filter' /etc/sysctl.conf) ]]
		then
			sed -i 's/net.ipv4.conf.default.rp_filter/net.ipv4.conf.default.rp_filter = 1/g' /etc/sysctl.conf
		else
			echo "net.ipv4.conf.default.rp_filter = 1" >> /etc/sysctl.conf
		fi
		if [[ $(grep 'kernel.randomize_va_space' /etc/sysctl.conf) ]]
		then
			sed -i 's/kernel.randomize_va_space/kernel.randomize_va_space = 2/g' /etc/sysctl.conf
		else
			echo "kernel.randomize_va_space = 2" >> /etc/sysctl.conf
		fi
	
	# applies changes to sysctl
	sysctl -p

	echo ""
	echo "Exiting network..."
	sleep 1

}

# searches for malicious files and software
function scans(){
	# install and run lynis
	echo ""
	echo "Installing lynis..."
	apt-get install lynis -y
	echo ""
	echo "Executing a lynis scan..."
	echo ""	
	lynis audit system
	echo ""
	read -n 1 -s -r -p "Press any key to continue"
	echo ""

	# checking cron
	echo ""
	echo "Checking root crontab..."
	echo ""
	echo "crontab -l -u root"
	echo ""
	crontab -l -u root
	echo ""
	read -n 1 -s -r -p "Press any key to continue"
	echo ""
	
	# searching for packages
	while :
	do
		echo ""
		echo "Do you want to search for packages? yes or no"
		read -r search
		if [ "${search}" == "yes" ]
		then
			echo "What term do you want to use to search for packages?"
			read -r pattern
			echo "Searching..."
			if [[ $( dpkg-query -W -f'${Package}\t${Description}\n' | grep -i "${pattern}" ) ]]
			then
				dpkg-query -W -f'${Package}\t${Description}\n' | grep -i "${pattern}"
			else
				echo "Your search yielded no results"
				unset "$search"
				unset "$pattern"
			fi
		else
			break
		fi
	done
	
	# checking critical files
	echo ""
	echo "Check profile for malicious code..."
	echo ""
	echo "/etc/profile"
	echo ""
	cat /etc/profile
	echo ""
	read -n 1 -s -r -p "Press any key to continue"
	echo ""
	
	echo ""
	echo "Check profile directory for malicious files..."
	echo ""
	echo "/etc/profile.d/"
	echo ""
	find /etc/profile.d | paste -s -d' ' | cut -d' ' -f2-
	echo ""
	read -n 1 -s -r -p "Press any key to continue"
	echo ""
	
	echo ""
	echo "Check bashrc for malicious code..."
	echo ""
	echo "/etc/bash.bashrc"
	echo ""
	cat /etc/bash.bashrc
	echo ""
	read -n 1 -s -r -p "Press any key to continue"
	echo ""
	
	echo ""
	echo "Check rc.local for malicious code..."
	echo ""
	echo "/etc/rc.local"
	echo ""
	cat /etc/rc.local
	echo ""
	read -n 1 -s -r -p "Press any key to continue"
	echo ""
	
	echo ""
	echo "Check rc directories for malicious files..."
	echo ""
	echo "/etc/rc[0-6].d"
	echo ""
	ls -a /etc/rc[0-6].d/
	echo ""
	read -n 1 -s -r -p "Press any key to continue"
	echo ""
	
	echo ""
	echo "Check root directory for malicious files..."
	echo ""
	echo "/"
	echo ""
	ls -a /
	echo ""
	read -n 1 -s -r -p "Press any key to conitnue"
	echo ""

	echo ""
	echo "Exiting scans..."
	sleep 1
}

echo '
					`.-:/oyhhysyyyyso/-```                                     
                                     `./oyhhhhddhddddhddhhhyyyys:.                                  
                                   `/shhdhhhdddddddmmddhddddhhhyyys+.                               
                                 .+yhddhhdddddddddhhhhhhhhhhdhhhhhhhy:`                             
                                -yddmdyssssyyhhdhysooossssoossyssydddho`                            
                               `+hdmhso++++++ooooo+++++++++/+++///ohmdh/                            
                              `+hhdyo++///+++/////////////////////+ohddy-                           
                              +hhhhs+////++/////////////////////////ohdds`                          
                             .yddhho//+++++ooooooo++++++ooooo+++++//+yddh:                          
                             :hdddho+++oyyhhhhhhyssooossyyhhhhyyso+++yddh:                          
                             :dddds+++sssssyyyyyyyso++oyyyhyyyyysyso+oddh:                          
                             /ddds//+ossyyyyhhyyyso+//+osyyhhhyyysso++ydy.                          
                           `-oddhs+++++++oooooo++++///+++oosssooo+++++sh+`                          
                           `+sshhs++/////////+++++////+++o++////////+oshs/                          
                            :ooyhs+++++++++oosysssssssysssyso+++++++++syy:                          
                            `:oso+++++oooosyyyyhhhhhhhddhysyysssooo++++o+`                          
                             `-+++++ooooosyhhhhhhhyyyyyhhyyyyysssoooo++/.                           
                              `/++++oooooshhhddysssssssyyhdddhysooooo++-                            
                               .-++ooooosyhhyssooooooooosssyyhhsssooooo:                            
                                 :+oooooshhyoooossyyyyyyssssshhyssssosdh.                           
                                 `:oooosyhhhssssyyhhhhhyyysyhddyssssodMMd-                          
                                 `shoosshdddhhyyyyyhhhhhhhhhdmdyyysshNMMMm-                         
                                .hMMd++oydmmmddddddddddddmmmmmdyyyydMMMMMMm:                        
                               /dNMNo``.:oyddmmmmmmmmmmmmmmmdhs+smNMMMMMMMMm+                       
                             .yNMMm/`    `.:/+ossyhhhhyyso+:-.` :mMMMMMMMMMMNs`                     
                           `+mMMMm:         ``````..`````        +MMMMMMMMMMMMd/                    
                          -hNMMMm/`                              .dMMMMMMMMMMMMNy-                  
                        .sNMMMMMy:``       ````           `````..`oNMMMMMMMMMMMMMNy.                
                       .hMMMMMMNo/:.``     `.```      ``...--------smMMMNMMMMMMMMMMm:               
                      .dMMMMMMNh/-.`       ``            ````..----.:hMMNmmNMMMMMMMMm:              
                      oMMNmNMMy-`                               ``.-.-yMMMNNmNMMMMMMMd-             
                     .mMMmNMMy.                                    `...hMMNNNmmMMMMMMMh`            
                    `yMMmNMMy.                                       ` -mNmddNmmMMMMMMMs`           
                    +NMmNMMy.             `                             oNNNNMMmmMMMMMMN:           
                   :NMmmMMh.              `                             .mMMMMMMdNMMMMMMd`          
                  :mMNmMMm-              ``                             `hMMMMMMdNMMMMMMM/          
                 :mMMmNMNo               ``                              oMMMMMMmNMMMMMMMy`         
               `+NMMMdMMm-               ``                              +MMMMMNmMMMMMMMMm.         
               oNMMMNhNMh`               .`                              /MMMMMmNMMMMMMMMN-         
              .mMMMMmymMs`               .`                              /MMMMNmMMMMMMMMMN-         
              -NMMMMMmdNo`               .`                              oMMMNmNMNMMMMMMMm.         
              .dmdyyhmNms`               .`                             `hNNNNNMMNNNmmmNMy          
              `/+/:::/ymNy:`             .`                         .--.:hNMMMMMMMMMMmhmN:          
            ``/+/::::::/yNNh/.           .`                        ./::::+NMMMMMMMMMNNNd+-.         
    `..-----:++//::::::::odMNds-`        ``                        .//::/sNMMMMMMMMMMNh/:::.        
   ./+////++///:::::::::::/yNMMNh/.                              ..-//://ohNMMMMMMMNds//::/.        
  `/+//::::::::::::::::::::/sNMMMMms-`                          .--://///+osyhhhhhyo+//::::-        
  `++//::::::::::::::::::::::sNMMMMMNy-                         .--:+/////+++++++++//::::::::`      
   :+//:::::::::::::::::::::::odMMMMMMd.                        `--/o+//////////////::::::::::-`    
   .+//::::::::::::::::::::::::+hNMMMMd.                        `-oho+//:::///////::::::::::::::-.` 
   .++/:::::::::::::::::::::::::/ymdy+.                        .+dNdo+//:::::::::::::::::::::::::::-
   -++/::::::::::::::::::::::::::/+:`                       `-smMMNho+//::::::::::::::::::::::::::/:
  `++//:::::::::::::::::::::::::::/o+.                   `:odNMMMMNho+//:::::::::::::::::::::::///:`
  /++/::::::::::::::::::::::::::://+shy/-```   `````.-/ohmMMMMMMMMmho+//:::::::::::::::::::////:-`  
 .o++////:::::::::::::::::::::::://+oymMMNmdhhhdddmNNMMMMMMMMMMMMMdyo+//::::::::::::://///+/-.`     
 `/ooo+++++////////::::::::::::::/++syhNMMMMMMMMMMMMMMMMMMMMMMMMMNdyo++/:::::::::////+++/-`         
   `.-:/++oooooooo++++/////:::///+osyhdNMMMMMNNNNNNNNNNNNNNNNMMMMNdhso++/////////++oo/-`            
          `..:/+ossssssooo+++++oosyyhdmm+:---...`````...````.:::++hhysooo++++++ooso/.`              
                 ``.-/+syyyyyyyyyhhdy/.`                          -yhhyssssssssys/`                 
                        `-/osyhhhso:`                              `-+syhhyhys+-`  ' 
echo "May the lord's blessings be upon you for the following six hours"
read -n 1 -s -r -p "Press any key upon completion of your prayers"

while :
do
	clear
	menu
	read -r answer
	case "$answer" in
		1)
			echo ""
			echo "Loading updates..."
			sleep 1
			updates
			;;
		2)
			echo ""
			echo "Loading users and groups..."
			sleep 1
			usersAndGroups
			;;
		3)
			echo ""
			echo "Loading user policy..."
			sleep 1
			userPolicy
			;;
		4)
			echo ""
			echo "Loading network..."
			sleep 1
			network
			;;
		5)
			echo ""
			echo "Loading antivirus..."
			sleep 1
			scans
			;;
		6)
			echo ""
			echo "Exiting..."
			sleep 1
			clear
			exit 0
			clear
			;;
esac
done
