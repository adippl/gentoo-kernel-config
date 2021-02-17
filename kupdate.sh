#!/bin/sh
repodir="https://github.com/adippl/gentoo-kernel-config/raw/master"
NVERS=$(wget $repodir/VERS -O -)
#NVERS=$(cat VERS)
unameCut="$(uname -r|rev|cut -d'-' -f2-|rev)"

if [ -z "$TYPE" ] ; then
	echo "TYPE variable missing in env, exit 1"
	exit 1
fi

if [ -f /etc/kern.v-$TYPE ] ; then
	if [ "$(cat /etc/kern.v-$TYPE)" == "$NVERS" ] ; then
		echo kernel seem to be up to date
		if [ "$FORCE" != "true" ] ; then
			exit 0
			fi
		fi
	fi

echo fetching new kernel
mkdir -p /tmp/k/
if ! test -f /tmp/k/linux-$NVERS-$TYPE.tar.xz ; then
	wget $repodir/linux-$NVERS-$TYPE.tar.xz -O /tmp/k/linux-$NVERS-$TYPE.tar.xz
	fi

case $TYPE in
	"x270")
		case $IMODE in
			"*")
			echo installing x270 kernel...
			mount /boot/
			mount /boot/efi/
			cp /boot/efi/vmlinuz /boot/efi/vmlinuz.old
			cp /boot/efi/initrd /boot/efi/initrd.old
			tar xJf /tmp/k/linux-$NVERS-$TYPE.tar.xz -C /tmp/k/ --exclude=System.map-* --exclude=kerncache.config --exclude=kernel-*
			cp /tmp/k/config-*-$NVERS-$TYPE /usr/src/config
			cp /tmp/k/config-*-$NVERS-$TYPE /usr/src/linux/.config
			cp /tmp/k/boot/{vmlinuz,initramfs}-* /boot/
			cp -r /tmp/k/lib/ /
			cp /tmp/k/boot/vmlinuz-* /boot/efi/vmlinuz
			cp /tmp/k/boot/initramfs-* /boot/efi/initrd
			umount /boot/efi/
			umount /boot/
			rm -rf /tmp/k/
			echo $NVERS > /etc/kern.v-$TYPE
			;;
		esac
		;;

	"kvm")
		case $IMODE in
			"libvirt")
				mkdir -p /tmp/k
				tar xJf /tmp/k/linux-$NVERS-$TYPE.tar.xz -C /tmp/k/ --exclude=System.map-* --exclude=kerncache.config  --exclude=config-* --exclude=kernel-*
				if [ -z "$KVMPATH" ] ; then
					cp /tmp/k/boot/vmlinuz-*	/var/lib/libvirt/images/vmlinuz
					cp /tmp/k/boot/initramfs-*	/var/lib/libvirt/images/initramfs
					echo $NVERS > /etc/kern.v-$TYPE
				else
					cp /tmp/k/boot/vmlinuz-*	$KVMPATH/gk-lx
					cp /tmp/k/boot/initramfs-*	$KVMPATH/gk-ifs
					echo $NVERS > /etc/kern.v-$TYPE
					fi
				rm -rf /tmp/k/
				;;
			"VM")
				tar xJf /tmp/k/linux-$NVERS-$TYPE.tar.xz -C / --exclude=System.map-* --exclude=kerncache.config  --exclude=config-* --exclude=kernel-*
				if [ "$GRUB" = "1" ] ; then
					mv /boot/initramfs-x86_64-$NVERS-$TYPE /boot/initramfs-x86_64-$NVERS-$TYPE.img
					grub-mkconfig -o /boot/grub/grub.cfg
					fi

				;;
			*)
				echo "WRONG IMODE exit 1"
				exit 1
				;;
		esac
		;;
	"nfsboot")
		echo UNFINISHED
		;;

	*)
		echo TYPE has wrong value, aboring install
		exit 1
		;;

esac
	
