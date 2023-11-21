# hold packages we don't want to update
echo "raspberrypi-kernel hold" | sudo dpkg --set-selections

sudo apt-get install -y libevdev-dev liblo-dev libudev-dev libcairo2-dev liblua5.3-dev libavahi-compat-libdnssd-dev libasound2-dev libncurses5-dev libncursesw5-dev libsndfile1-dev libboost-dev libnanomsg-dev
sudo apt install --no-install-recommends -y ladspalist 
sudo apt install --no-install-recommends network-manager dnsmasq-base midisport-firmware samba

cd /home/we

git clone https://github.com/monome/libmonome.git
cd /home/we/libmonome
./waf configure
./waf
sudo ./waf install

cd /home/we
git clone https://github.com/supercollider/supercollider.git
cd /home/we/supercollider
git submodule update --init --recursive
cmake     -DCMAKE_BUILD_TYPE=Release     -DNATIVE=1     -DSSE=0     -DSSE2=0     -DENABLE_TESTSUITE=0     -DCMAKE_SKIP_RPATH=1     -DLIBSCSYNTH=0     -DSUPERNOVA=0     -DSC_IDE=0     -DSC_ED=0     -DSC_EL=0     -DSC_VIM=1     -DNO_X11=ON -DSC_QT=OFF 

cd /home/we/norns-image
sudo cp --remove-destination config/norns-crone.service /etc/systemd/system/norns-crone.service
#sudo rm /etc/systemd/system/norns-supernova.service
#sudo cp --remove-destination config/norns-supernova.service /etc/systemd/system/norns-supernova.service
sudo cp --remove-destination config/norns-sclang.service /etc/systemd/system/norns-sclang.service
#sudo cp --remove-destination config/norns-jack.service /etc/systemd/system/norns-jack.service
sudo cp --remove-destination config/norns-maiden.service /etc/systemd/system/norns-maiden.service
sudo cp --remove-destination config/norns-maiden.socket /etc/systemd/system/norns-maiden.socket
sudo cp --remove-destination config/norns-matron.service /etc/systemd/system/norns-matron.service
sudo cp --remove-destination config/norns-watcher.service /etc/systemd/system/norns-watcher.service
sudo cp --remove-destination config/norns.target /etc/systemd/system/norns.target
sudo cp --remove-destination config/55-maiden-systemctl.pkla /etc/polkit-1/localauthority/50-local.d/55-maiden-systemctl.pkla
sudo systemctl enable norns.target


# motd
sudo cp config/motd /etc/motd


# bashrc
sudo cp config/bashrc /home/we/.bashrc

samba
(echo "sleep"; echo "sleep") | sudo smbpasswd -s -a we
sudo cp config/smb.conf /etc/samba/
sudo /etc/init.d/samba restart


# Wifi
# Use the upstream rtl8192cu driver instead of the problematic realtek 8192cu driver
sudo rm -f /etc/modprobe.d/blacklist-rtl8192cu.conf
sudo cp config/blacklist-8192cu.conf /etc/modprobe.d/
# NetworkManager config
sudo cp config/interfaces /etc/network/interfaces
sudo cp config/network-manager/100-disable-wifi-mac-randomization.conf /etc/NetworkManager/conf.d/
sudo cp config/network-manager/101-logging.conf /etc/NetworkManager/conf.d/
sudo cp config/network-manager/200-disable-nmcli-auth.conf /etc/NetworkManager/conf.d/
sudo systemctl disable pppd-dns.service


# limit log sizes
sudo cp config/journald.conf /etc/systemd/
sudo cp config/logrotate.conf /etc/
sudo cp config/rsyslog.conf /etc/
sudo cp config/rsyslog /etc/rsyslog.d/

# Plymouth
# Get rid of our old masked plymouth units
sudo systemctl unmask plymouth-read-write.service
sudo systemctl unmask plymouth-start.service
sudo systemctl unmask plymouth-quit.service
sudo systemctl unmask plymouth-quit-wait.service
sudo apt purge plymouth

# Apt timers
sudo systemctl mask apt-daily.timer
sudo systemctl mask apt-daily-upgrade.timer


# disable swap
sudo apt purge dphys-swapfile
sudo swapoff -a
sudo rm /var/swap

# speed up boot
sudo apt purge exim4-* nfs-common triggerhappy

# uninstall packages we don't need
sudo apt purge libraspberrypi-doc modemmanager

# cleanup
sudo apt --purge -y autoremove
