#!/bin/sh
kernel="$(eselect kernel list| awk '$2~/-dist$/{print $2}')"
kv="$(echo $kernel | cut -d- -f2- )"
e_kv="$(echo $kernel | cut -d- -f2- | cut -d- -f1)"
package_name="sys-kernel/gentoo-kernel-bin"
dracut -m "nfs network base" /boot/initramfs-${kv}.img --kver ${kv}
tar -cf $kernel-nfsboot.tar /boot/vmlinuz-$kv /boot/initramfs-$kv.img /boot/config-$kv /boot/System.map-$kv  $(qlist =sys-kernel/gentoo-kernel-bin-$e_kv)
pxz $kernel-nfsboot.tar
