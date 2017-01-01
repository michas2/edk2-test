#!/bin/bash -eux
brctl addbr br0
ifconfig br0 up 192.168.77.1
dnsmasq -zi br0 -C /dev/null -p0 --dhcp-range=192.168.77.50,192.168.77.150,12h --enable-tftp --tftp-root=$PWD  --pxe-service=x86-64_EFI,grub1,grub.efi --pxe-service=x86-64_EFI,grub2,grub.efi -8 $PWD/dnsmasq.log

sleep 10
qemu-system-x86_64 -nographic -bios Build/OvmfX64/DEBUG_GCC49/FV/OVMF.fd -net bridge -net nic
cat dnsmasq.log
ls -l
gcc --version
