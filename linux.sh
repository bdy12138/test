wget https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh
METHOD=script bash install.sh
source ~/.bashrc
nvm install 16
wget https://raw.githubusercontent.com/cuckoosandbox/cuckoo/master/cuckoo/data/agent/agent.py
# linux还需要安装systemtap监听api，https://cuckoo.sh/docs/installation/guest/linux.html
sudo apt-get install python systemtap gcc patch linux-headers-$(uname -r)
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C8CAB6595FDFF622
codename=$(lsb_release -cs)
sudo tee /etc/apt/sources.list.d/ddebs.list << EOF
  deb http://ddebs.ubuntu.com/ ${codename}          main restricted universe multiverse
  deb http://ddebs.ubuntu.com/ ${codename}-updates  main restricted universe multiverse
  deb http://ddebs.ubuntu.com/ ${codename}-proposed main restricted universe multiverse
EOF
sudo apt-get update
sudo apt-get install linux-image-$(uname -r)-dbgsym
wget https://raw.githubusercontent.com/cuckoosandbox/cuckoo/master/stuff/systemtap/expand_execve_envp.patch
wget https://raw.githubusercontent.com/cuckoosandbox/cuckoo/master/stuff/systemtap/escape_delimiters.patch
sudo patch /usr/share/systemtap/tapset/linux/sysc_execve.stp < expand_execve_envp.patch
sudo patch /usr/share/systemtap/tapset/uconversions.stp < escape_delimiters.patch
wget https://raw.githubusercontent.com/cuckoosandbox/cuckoo/master/stuff/systemtap/strace.stp
sudo stap -p4 -r $(uname -r) strace.stp -m stap_ -v
mkdir /root/.cuckoo
sudo mv stap_.ko /root/.cuckoo/
# 设置默认网关
sudo echo "DNS=8.8.8.8" >> /etc/systemd/resolved.conf
sudo tee /etc/netplan/00-installer-config.yaml << EOF
network:
  version: 2
  ethernets:
    enp0s3:
      dhcp4: no
      dhcp6: no
      optional: true
    enp0s8:
      dhcp4: no
      addresses:
        - 192.168.56.112/24
      routes:
        - to: 0.0.0.0/0
          via: 192.168.56.1
EOF
sudo netplan apply
ip link set enp0s3 down
# 关掉防火墙和NTP
sudo ufw disable
sudo timedatectl set-ntp off
