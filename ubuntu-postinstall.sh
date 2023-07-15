 echo "Ubuntu post install script"
 echo "author: artem@nazarow.ru, 2023"
 
 
# ---------- KEYS  -----------

echo "INSTALL KEYS (NEED AWAIT LONG TIME)? [Y/N]?"
echo "Confirm [Y,n]"
read input
if [[ $input == "Y" || $input == "y" ]]; then
	sudo apt-key update             
	sudo apt-key list | \
 	grep "expired: " | \
 	sed -ne 's|pub .*/\([^ ]*\) .*|\1|gp' | \
 	xargs -n1 sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys
else
        echo "skipped keys update"
fi 

# ---------- MIRRORS CHANGE -----------

echo "change mirrors ? [Y/N]?"
echo "Confirm [Y,n]"
read input
if [[ $input == "Y" || $input == "y" ]]; then
	# Update the mirror list
	sudo apt update
	# Install the netselect tool
	wget http://ftp.us.debian.org/debian/pool/main/n/netselect/netselect_0.3.ds1-29_amd64.deb
	# Run netselect-apt to find the fastest mirror
	sudo dpkg -i netselect_0.3.ds1-29_amd64.deb
	 
	# Run netselect to find the fastest mirror
	mirror=$(sudo netselect -s 20 -t 40 $(wget -qO - mirrors.ubuntu.com/mirrors.txt) | awk 'NR==2{print $2}')

	# Update the sources.list file with the fastest mirror
	sudo sed -i "s|http://archive.ubuntu.com/ubuntu/|$mirror|g" /etc/apt/sources.list

# Update the package list
sudo apt-get update
	# Update the package lists
	sudo apt update                              
else
        echo "skipped mirrors setup"
fi 


# ---------- MAKE TOOLS  -----------

echo "INSTALL MAKE TOOLS (RECOMMENDED)? [Y/N]?"
echo "Confirm [Y,n]"
read input
if [[ $input == "Y" || $input == "y" ]]; then
	sudo apt-get install autoconf gcc automake build-essential git llvm clang lld
else
        echo "skipped make tools install"
fi


# ---------- SYSTEM TOOLS  -----------

echo "INSTALL SYSTEM TOOLS? [Y/N]?"
echo "Confirm [Y,n]"
read input
if [[ $input == "Y" || $input == "y" ]]; then
	sudo apt install gvfs
	sudo apt install ccache
	sudo add-apt-repository ppa:danielrichter2007/grub-customizer
	sudo apt update
	sudo apt install grub-customizer
	sudo apt install mc
else
        echo "skipped SYSTEM TOOLS install"
fi
 

# -------------NETWORK -------------

echo "INSTALL NETWORKING TOOLS (RECOMMENDED)? [Y/N]?"
echo "Confirm [Y,n]"
read input
if [[ $input == "Y" || $input == "y" ]]; then
		sudo apt install wpa_supplicant
		sudo apt install isc-dhcp-server
		sudo systemctl mask NetworkManager-wait-online.service		
else
        echo "skipped networking install"
fi

# ---------- proc frequency ----------
cd ~
echo "INSTALL PROC FREQ TOOLS (RECOMMENDED)? [Y/N]?"
echo "Confirm [Y,n]"
read input
if [[ $input == "Y" || $input == "y" ]]; then

		sudo apt-get update                     
		sudo apt-get install cpupower-gui
		sudo apt-get install linux-tools-common linux-tools-generic linux-tools-`uname -r`
		wget https://github.com/vagnum08/cpupower-gui/releases/latest/download/cpupower-gui_1.0.0-1_all.deb
		sudo apt install ./cpupower-gui_1.0.0-1_all.deb		
else
        echo "skipped PROC FREQ install"
fi
cd -


# ---------- proc frequency ----------
cd ~
echo "INSTALL AUTO FREQ TOOLS ? [Y/N]?"
echo "Confirm [Y,n]"
read input
if [[ $input == "Y" || $input == "y" ]]; then
		sudo apt-get install git
		git clone https://github.com/AdnanHodzic/auto-cpufreq.git
		cd auto-cpufreq   
		sudo ./auto-cpufreq-installer                                      
		 cd -
else
        echo "skipped AUTO FREQ install"
fi
cd -

# ------------ INSTALL ZEN KERNEL ------


cd ~
echo "INSTALL ZEN KERNEL ? [Y/N]?"
echo "Confirm [Y,n]"
read input
if [[ $input == "Y" || $input == "y" ]]; then

	# Step 1: Prepare your environment
	sudo apt update
	sudo apt install build-essential libncurses-dev bison flex libssl-dev libelf-dev

	# Step 2: Download the sources
	cd /usr/src
	sudo git clone git://git.zen-sources.org/zen/zen.git linux-2.6-zen
	sudo ln -s linux-2.6-zen linux
	cd linux

	# Step 3: Configure the kernel
	sudo make menuconfig

	# Step 4: Build the kernel
	sudo make -j$(nproc)

	# Step 5: Install the kernel
	sudo make modules_install
	sudo make install

	# Step 6: Update ZEN-Sources
	sudo update-initramfs -c -k all
	sudo update-grub

	# Step 7: Removing ZEN-Sources
	cd /usr/src
	sudo rm -rf linux-2.6-zen

	echo "Zen kernel installation completed. Please reboot your system to use the new kernel."


else
        echo "skipped ZEN KERNEL install"
fi


# ------------ INSTALL XAN MOD KERNEL FOR AMD ------


cd ~
echo "INSTALL XANMOD KERNEL ? [Y/N]?"
echo "Confirm [Y,n]"
read input
if [[ $input == "Y" || $input == "y" ]]; then

	
	# Update system packages
	sudo apt update -y && sudo apt upgrade -y

	# Add XanMod repository
	echo 'deb http://deb.xanmod.org releases main' | sudo tee /etc/apt/sources.list.d/xanmod-kernel.list

	# Import GPG keys
	wget -qO - https://dl.xanmod.org/gpg.key | sudo apt-key --keyring /etc/apt/trusted.gpg.d/xanmod-kernel.gpg add -

	# Install XanMod Kernel
	sudo apt update && sudo apt install linux-xanmod -y

	# Reboot system
	# sudo reboot

else
        echo "skipped XANMOD install"
fi

# ------------ INSTALL TKG KERNEL FOR AMD ------


cd ~
echo "INSTALL LINUX TKG KERNEL ? [Y/N]?"
echo "Confirm [Y,n]"
read input
if [[ $input == "Y" || $input == "y" ]]; then

	
	# Install git
	sudo apt install git

	# Clone the Github repository
	git clone https://github.com/Frogging-Family/linux-tkg.git

	# Change directory to the cloned repository
	cd linux-tkg

	# Optional: edit the "customization.cfg" file to enable/disable patches

	# Execute the install script
	./install.sh install

	# Reboot the system
	# sudo reboot

else
        echo "skipped LINUX TKG install"
fi


# ------------ update grub ------


cd ~
echo "Update grub (Y if install kernel) [Y/N]?"
echo "Confirm [Y,n]"
read input
if [[ $input == "Y" || $input == "y" ]]; then

	sudo update-grub 

else
        echo "skipped grub update"
fi


# ---------- VULKAN -----------

echo "INSTALL VULKAN? [Y/N]?"
echo "Confirm [Y,n]"
read input
if [[ $input == "Y" || $input == "y" ]]; then
	       
	# Add Mesa PPA
	sudo add-apt-repository ppa:kisak/kisak-mesa

	# Add Vulkan PPA
	sudo add-apt-repository ppa:oibaf/graphics-drivers

	# Update package list
	sudo apt update

	# Install Mesa and lib32-mesa
	sudo apt install mesa lib32-mesa

	# Install Vulkan packages
	sudo apt install vulkan-radeon lib32-vulkan-radeon vulkan-icd-loader lib32-vulkan-icd-loader

else
        echo "skipped vulkan installation"
fi

# -------------------------- 

# ---------- PORTPROTON -----------

echo "INSTALL AMD DRIVERS FOR GAMING AND PORTPROTON? [Y/N]?"
echo "Confirm [Y,n]"
read input
if [[ $input == "Y" || $input == "y" ]]; then
        echo "begin pre installation"
	sudo dpkg --add-architecture i386
	sudo add-apt-repository multiverse
	sudo apt update && sudo apt upgrade
	sudo apt install curl file libc6 libnss3 policykit-1 xz-utils zenity bubblewrap curl icoutils tar libvulkan1 libvulkan1:i386 wget zenity zstd cabextract xdg-utils openssl bc libgl1-mesa-glx libgl1-mesa-glx:i386
        wget -c "https://github.com/Castro-Fidel/PortWINE/raw/master/portwine_install_script/PortProton_1.0" && sh PortProton_1.0 -rus

else
        echo "skipped amd graphics and portproton installation"
fi

# --------------------------


# ---------- DBUS BROKER FOR VIDEO -----------
cd ~
echo "ENABLE DBUS BROKER ? [Y/N]?"
echo "Confirm [Y,n]"
read input
if [[ $input == "Y" || $input == "y" ]]; then


	sudo apt update
	sudo apt install dbus-broker
	sudo systemctl start dbus-broker.service
	sudo systemctl enable dbus-broker.service

else
        echo "skipped dbus broker install"
fi
cd -
# --------------------------



# ---------- CLEAR FONT CACHE -----------

echo "CLEAR FONT CACHE? [Y/N]?"
echo "Confirm [Y,n]"
read input
if [[ $input == "Y" || $input == "y" ]]; then
        echo "clear font cache"
        sudo rm -rf /var/cache/fontconfig/*
	sudo fc-cache -f -v

else
        echo "skipped clearing font cache"
fi

# --------------------------


# ---------- remove prev google  -----------

echo "REMOVE PREVIOUS GOOGLE CHROME INSTALLATION? [Y/N]?"
echo "Confirm [Y,n]"
read input
if [[ $input == "Y" || $input == "y" ]]; then
        echo "clear prev. google chrome installation"
        cd ~/.config
	rm -rf google-chrome
else
        echo "skipped clearing google chrome"
fi

# --------------------------




# ---------- SECURITY  -----------

echo "INSTALL SECURITY TOOLS (APPARMOR, FIREJAIL)? [Y/N]?"
echo "Confirm [Y,n]"
read input
if [[ $input == "Y" || $input == "y" ]]; then
	echo "begin install security"
	# Install AppArmor
	sudo apt install apparmor apparmor-utils -y

	# Add AppArmor parameters to kernel parameters
	sudo sed -i 's/quiet splash/apparmor=1 security=apparmor quiet splash/g' /etc/default/grub
	sudo update-grub

	# Install Firejail
	sudo apt install firejail -y

	# Install Firetools (optional)
	sudo apt install firetools -y  
        
else
        echo "skipped security install"
fi

# --------------------------



# ---------- BLUETOOTH TOOLS  -----------

echo "INSTALL BLUETOOTH TOOLS? [Y/N]?"
echo "Confirm [Y,n]"
read input
if [[ $input == "Y" || $input == "y" ]]; then
        echo "begin install bluetooth"
        sudo apt install bluez

	sudo apt install bluez-utils
	
	sudo apt install blueman

else
        echo "skipped bluetooth install"
fi

# --------------------------



# ---------- SOUND  -----------

echo "INSTALL SOUND TOOLS(PULSEAUDIO)? [Y/N]?"
echo "Confirm [Y,n]"
read input
if [[ $input == "Y" || $input == "y" ]]; then
        echo "begin install sound"
		# Install PulseAudio
		sudo apt install pulseaudio

		# Install pulseaudio-bluetooth
		sudo apt install pulseaudio-bluetooth

		# Install jack2 and jack2-dbus
		sudo apt install jack2 jack2-dbus

		# Install pulseaudio-alsa and pulseaudio-jack
		sudo apt install pulseaudio-alsa pulseaudio-jack

		# Install pavucontrol
		sudo apt install pavucontrol
		pulseaudio -k
		pulseaudio -D
		sudo chown $USER:$USER ~/.config/pulse
else
        echo "skipped sound install"
fi

# --------------------------


# ---------- PIPEWIRE SOUND  -----------

echo "INSTALL PIPEWIRE SOUND ? [Y/N]?"
echo "Confirm [Y,n]"
read input
if [[ $input == "Y" || $input == "y" ]]; then
        echo "begin pipewire sound"
	# Install client libraries
	sudo apt install pipewire-audio-client-libraries libspa-0.2-bluetooth libspa-0.2-jack

	# Install pipewire-alsa
	sudo apt install pipewire-alsa

	# Install pipewire-jack
	sudo apt install pipewire-jack

	# Install pavucontrol
	sudo apt install pavucontrol

	# Disable pipewire-pulse.service and pipewire-pulse.socket
	sudo systemctl --global --now disable pipewire-pulse.service pipewire-pulse.socket

	# Copy configuration files
	sudo cp /usr/share/doc/pipewire/examples/alsa.conf.d/99-pipewire-default.conf /etc/alsa/conf.d/

	# Check if PipeWire is running
	pactl info

else
        echo "skipped pipewire sound install"
fi

# --------------------------

# ---------- ALSA SOUND  -----------

echo "INSTALL ALSA SOUND ? [Y/N]?"
echo "Confirm [Y,n]"
read input
if [[ $input == "Y" || $input == "y" ]]; then
        echo "begin ALSA sound"
	# Update the apt database
	sudo apt-get update

	# Install alsa-tools
	sudo apt-get install alsa-tools

	# OR

	# Install alsa-base
	sudo apt install alsa-base

	# OR

	# Install aptitude
	sudo apt-get install aptitude

	# Update the apt database using aptitude
	sudo aptitude update

	# Install alsa-base using aptitude
	sudo aptitude install alsa-base
else
        echo "skipped ALSA sound install"
fi

# --------------------------





# ---------- AUDIO PLAYER  -----------

echo "INSTALL AUDIO PLAYERS? [Y/N]?"
echo "Confirm [Y,n]"
read input
if [[ $input == "Y" || $input == "y" ]]; then
	echo "begin install audio players"
	# Install python-pip
	sudo apt-get update
	sudo apt-get install -y python-pip

	# Install httpx library
	pip install httpx

	# Install foobnix
	sudo apt-get install -y foobnix

	# Install clementine
	sudo apt-get install -y clementine

else
        echo "skipped audio players install"
fi

# --------------------------



# ---------- INTERNET TOOLS  -----------

echo "INSTALL INTERNET TOOLS? [Y/N]?"
echo "Confirm [Y,n]"
read input
if [[ $input == "Y" || $input == "y" ]]; then
        echo "begin install insternet tools"
	# Install qBittorrent
	sudo apt-get install qbittorrent -y

	# Add uGet PPA and install uGet
	sudo add-apt-repository ppa:uget-team/ppa -y
	sudo apt-get update
	sudo apt-get install uget -y

	# Install uGet Integrator
	sudo apt-get install uget-integrator -y

	# Install FileZilla
	sudo apt-get install filezilla -y

	# Install PuTTY
	sudo apt-get install putty -y

else
        echo "skipped internet tools install"
fi

# --------------------------
 

# ---------- SCREENCAST TOOLS  -----------

echo "INSTALL SCREENCAST TOOLS? [Y/N]?"
echo "Confirm [Y,n]"
read input
if [[ $input == "Y" || $input == "y" ]]; then
        echo "begin install SCREENCAST tools"
	# Add Vokoscreen repository
	sudo add-apt-repository -y ppa:ubuntuhandbook1/apps

	# Add OBS Studio repository
	sudo add-apt-repository -y ppa:obsproject/obs-studio

	# Update package list
	sudo apt update

	# Install Vokoscreen
	sudo apt install -y vokoscreen

	# Install OBS Studio
	sudo apt install -y obs-studio
else
        echo "skipped SCREENCAST tools install"
fi

# --------------------------




# ---------- DEVELOPER TOOLS  -----------

echo "INSTALL DEVELOPER TOOLS? [Y/N]?"
echo "Confirm [Y,n]"
read input
if [[ $input == "Y" || $input == "y" ]]; then
        echo "begin install developer tools"
	 # Download the latest deb file for NetBeans
	wget $(curl -s https://netbeans.apache.org/download/nb15/ | grep -o -m 1 'https://.*\.deb')

	# Install the Debian package
	sudo dpkg -i apache-netbeans_*.deb

	# If there are any missing dependencies, run:
	sudo apt-get install -f
	
	
	# Download OSS Code
	wget https://az764295.vo.msecnd.net/stable/2b9aebd5354a3629c3aba0a5f5df49f43d6689f8/code_1.57.1-1623937018_amd64.deb

	# Install OSS Code
	sudo dpkg -i code_1.57.1-1623937018_amd64.deb

	# If there are any missing dependencies, run:
	sudo apt-get install -f
	
	
	sudo add-apt-repository ppa:notepadqq-team/notepadqq
	sudo apt-get update
	sudo apt-get install notepadqq
	
	sudo add-apt-repository ppa:ubuntu-lazarus/ppa
	sudo apt-get update
	sudo apt-get install lazarus-q
	
	sudo add-apt-repository ppa:beineri/opt-qt-5.15.2-focal
	sudo apt-get update
	sudo apt-get install qt515creator
	
	sudo add-apt-repository multiverse && sudo apt-get update
	sudo apt-get install virtualbox
	sudo apt-get install dkms
	
	
	
else
        echo "skipped developer tools install"
fi

# --------------------------

 # ---------- FLATPAK SYSTEM  -----------

echo "INSTALL FLATPAK? [Y/N]?"
echo "Confirm [Y,n]"
read input
if [[ $input == "Y" || $input == "y" ]]; then
        echo "begin install developer tools"
		sudo add-apt-repository ppa:flatpak/stable
		sudo apt update
		sudo apt install flatpak 
		
		flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
		flatpak update
		flatpak remote-add --if-not-exists kdeapps --from https://distribute.kde.org/kdeapps.flatpakrepo
		flatpak update
else
        echo "skipped flatpak install"
fi

# --------------------------



 
# ---------- FLATPAK SOFT  -----------

echo "INSTALL SOFT FROM FLATPAK? [Y/N]?"
echo "Confirm [Y,n]"
read input
if [[ $input == "Y" || $input == "y" ]]; then
		flatpak install fsearch
		flatpak install --user netbeans
else
        echo "skipped flatpak soft install"
fi
# --------------------------


 ------------------------
 

# ---------- SNAP -----------

echo "INSTALL PAMAC (GUI FOR PACMAN)? [Y/N]?"
echo "Confirm [Y,n]"
read input
if [[ $input == "Y" || $input == "y" ]]; then
		
		sudo apt install snapd
		sudo systemctl start snapd.socket
		sudo systemctl enable snapd.socket
		snap install core
		snap install snap-store


else
        echo "skipped snap install"
fi
# --------------------------
 

# ---------- VIDEO  -----------

echo "INSTALL VIDEO PLAYER ? [Y/N]?"
echo "Confirm [Y,n]"
read input
if [[ $input == "Y" || $input == "y" ]]; then
		
		sudo add-apt-repository ppa:savoury1/vlc3
		sudo apt update
		sudo apt-get install vlc

else
        echo "skipped video player install"
fi
# --------------------------
 


# ---------- PASSWORD TOOL  -----------

echo "INSTALL PASSWORD TOOL ? [Y/N]?"
echo "Confirm [Y,n]"
read input
if [[ $input == "Y" || $input == "y" ]]; then
		

		sudo apt install keepassxc

else
        echo "skipped password tool install"
fi
# --------------------------

 






 
# ---------- WINE  -----------

echo "INSTALL WINE ? [Y/N]?"
echo "Confirm [Y,n]"
read input
if [[ $input == "Y" || $input == "y" ]]; then
		

		echo "Installing wine"
		
		sudo pacman -Sy cabextract
		
		sudo apt -y install wine

		wget https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks
		chmod +x winetricks
		
		

		wineboot -u
		wget https://dl.winehq.org/wine/wine-mono/7.0.0/wine-mono-7.0.0-x86.tar.xz
tar xvf wine-mono-7.0.0-x86.tar.xz

	wget https://dl.winehq.org/wine/wine-gecko/2.47.1/wine-gecko-2.47.1-x86.msi
	wine msiexec /i wine-gecko-2.47.1-x86.msi
		./winetricks

		chown $USER:$USER -R /home/artem/.wine

		export WINEARCH=win32
		export WINEDEBUG=-all
		 WINEPREFIX=/home/artem/.wine

		./wt-install-all.sh

else
        echo "skipped wine install"
fi
# --------------------------


# ---------- DE ---------


echo "INSTALL DE additional software ? [Y/N]?"
echo "Confirm [Y,n]"
read input
if [[ $input == "Y" || $input == "y" ]]; then

		sudo apt-get install -y ffmpegthumbs

else
        echo "skipped DE addons install"
fi



# ---------- MESSENGERS -----------

echo "INSTALL MESSENGERS? [Y/N]?"
echo "Confirm [Y,n]"
read input
if [[ $input == "Y" || $input == "y" ]]; then
        echo "begin install MESSENGERS"
	 # Install Telegram-Desktop
	sudo add-apt-repository ppa:atareao/telegram
	sudo apt-get update
	sudo apt-get install telegram-desktop

	# Install Viber
	wget https://download.cdn.viber.com/cdn/desktop/Linux/viber.deb
	sudo dpkg -i viber.deb
	sudo apt-get install -f

	# Install WhatsApp for Linux
	wget https://github.com/adiwajshing/Baileys/releases/download/4.5.0/whatsapp-web-linux.zip
	unzip whatsapp-web-linux.zip
	cd whatsapp-web-linux
	./WhatsAppWeb-linux-x64

	# Install Element Desktop
	sudo apt install -y wget apt-transport-https
	wget -qO - https://app.element.io/packages/ubuntu/keys.gpg | sudo apt-key add -
	echo 'deb [signed-by=/usr/share/keyrings/app.element.io-archive-keyring.gpg] https://app.element.io/packages/ubuntu/ focal main' | sudo tee /etc/apt/sources.list.d/app.element.io.list
	sudo apt update
	sudo apt install element-desktop

	# Install Discord
	wget -O discord.deb "https://discordapp.com/api/download?platform=linux&format=deb"
	sudo dpkg -i discord.deb
	sudo apt-get install -f

else
        echo "skipped MESSENGERS install"
fi

# --------------------------


# OPTIMIZATIONS


# ---------- ANANICY  -----------
cd ~
echo "INSTALL ANANICY ? [Y/N]?"
echo "Confirm [Y,n]"
read input
if [[ $input == "Y" || $input == "y" ]]; then
		

	echo "Installing ananicy"
	git clone https://github.com/Nefelim4ag/Ananicy.git ./Ananicy/package.sh debian
	sudo dpkg -i ./Ananicy/ananicy-*.deb
	sudo apt install schedtool                              
	sudo systemctl enable --now ananicy  

else
        echo "skipped ananicy install"
fi
cd -


# ----------- RNG ---------------



cd ~
echo "ENABLE RNG (CHOOSE N IF INSTALL ANANICY) ? [Y/N]?"
echo "Confirm [Y,n]"
read input
if [[ $input == "Y" || $input == "y" ]]; then
		

		echo "Installing RNG"
		sudo apt-get install rng-tools                         
		sudo systemctl enable --now rngd                   



else
        echo "skipped RNG install"
fi
cd -


# ---------- HAVEGED  -----------
cd ~
echo "INSTALL HAVEGED ? [Y/N]?"
echo "Confirm [Y,n]"
read input
if [[ $input == "Y" || $input == "y" ]]; then

		sudo apt-get install haveged                          
		sudo systemctl enable haveged   

else
        echo "skipped wine install"
fi
cd -
# --------------------------


# ---------- TRIM FOR SSD -----------
cd ~
echo "ENABLE TRIM FOR SSD ? [Y/N]?"
echo "Confirm [Y,n]"
read input
if [[ $input == "Y" || $input == "y" ]]; then

	# Check if SSD supports TRIM
	sudo hdparm -I /dev/sda | grep "TRIM supported"

	# Install fstrim
	sudo apt install util-linux

	# Enable fstrim.timer service
	sudo systemctl enable fstrim.timer

	# Verify timer is enabled
	sudo systemctl list-timers --all

	sudo systemctl enable fstrim.timer                 
	sudo fstrim -v /                                    
	sudo fstrim -va  / 

else
        echo "skipped trim switching"
fi
cd -
# --------------------------
