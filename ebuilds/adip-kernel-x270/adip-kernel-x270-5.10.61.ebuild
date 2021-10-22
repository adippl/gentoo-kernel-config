# Copyright 2011-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="installer for precomiled linux kernel configured for laptops"
HOMEPAGE="https://github.com/adippl/gentoo-kernel-config"
SRC_URI="https://github.com/adippl/gentoo-kernel-config/raw/master/linux-5.10.61-gentoo-x270.tar.xz"

#inherit git-r3
#EGIT_REPO_URI="https://github.com/adippl/lpmd"

LICENSE="GPL-2"
SLOT="5.10.61"
KEYWORDS="amd64"
IUSE="grub-update uefi uefi-test"

DEPEND="
	"
RDEPEND="${DEPEND}"
BDEPEND=""

S="${WORKDIR}"

src_install() {
	cp -r "${S}/boot/" "${D}/boot/"
	dodir /lib/
	cp -r "${S}/lib/modules/" "${D}/lib/modules/"
#	unlink "${D}/lib/modules/${PVR}-gentoo-x270/build"
#	unlink "${D}/lib/modules/${PVR}-gentoo-x270/source"

	dodir /boot/efi
	if use uefi ; then
#		dodir /boot/efi
		cp "${S}/boot/vmlinuz-x86_64-${PVR}-gentoo-x270" "${D}/boot/efi/vmlinuz"
		cp "${S}/boot/initramfs-x86_64-${PVR}-gentoo-x270.img" "${D}/boot/efi/initrd"
	fi
	if use uefi-test ; then
#		dodir /boot/efi
		cp "${S}/boot/vmlinuz-x86_64-${PVR}-gentoo-x270" "${D}/boot/efi/vmlinuz"
		cp "${S}/boot/initramfs-x86_64-${PVR}-gentoo-x270.img" "${D}/boot/efi/initrd"
	fi
}

pkg_preinst(){
#	mount /boot ||ewarn "couldn't mount boot"
#	[ "$?" == "32" ] && /boot already mounted
	mount /boot || ewarn "couldn't umount /boot"
	if use uefi ;then
		mount /boot/efi
		elog "backing up current kernel and initramfs on efi partition"
		cp /boot/efi/vmlinuz /boot/efi/vmlinuz.old
		cp /boot/efi/initrd /boot/efi/initrd.old

	fi
	}
pkg_postinst(){
	if use grub-update ;then
		mount /boot ||ewarn "couldn't mount boot"
		elog "updating grub config after kernel update"
		grub-mkconfig -o /boot/grub/grub.cfg
		umount /boot
	fi
	}

pkg_prerm(){
	mount /boot || ewarn "couldn't umount /boot"
	if test -d /boot/efi ;then
		mount /boot/efi || ewarn "couldn't umount /boot/efi"
	fi
}
pkg_postrm(){
	if test -d /boot/efi ;then
		umount /boot/efi || ewarn "couldn't unmount /boot/efi"
	fi
	if use grub-update ;then
		elog "updating grub config after kernel removal"
		grub-mkconfig -o /boot/grub/grub.cfg
	fi
	umount /boot || ewarn "couldn't unmount /boot"
}
