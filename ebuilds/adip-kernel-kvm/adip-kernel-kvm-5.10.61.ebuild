# Copyright 2011-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="installer for precompiled linux kernel configured for KVM virtual machines"
HOMEPAGE="https://github.com/adippl/gentoo-kernel-config"
SRC_URI="https://github.com/adippl/gentoo-kernel-config/raw/master/linux-5.10.61-gentoo-kvm.tar.xz"

#inherit git-r3
#EGIT_REPO_URI="https://github.com/adippl/lpmd"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64"
IUSE="grub-update libvirt-local libvirt-ceph"

DEPEND="
	"
RDEPEND="${DEPEND}"
BDEPEND=""

S="${WORKDIR}"

src_install() {
	cp -r "${S}/boot/" "${D}/boot/"
	dodir /lib/
	cp -r "${S}/lib/modules/" "${D}/lib/modules/"
	unlink "${D}/lib/modules/${PVR}-gentoo-x270/build"
	unlink "${D}/lib/modules/${PVR}-gentoo-x270/source"

	if use libvirt-local ; then
		dodir /var/lib/libvirt/images/
		cp "${S}/boot/vmlinuz-x86_64-${PVR}-gentoo-kvm" "${D}/var/lib/libvirt/images/vmlinuz"
		cp "${S}/boot/initramfs-x86_64-${PVR}-gentoo-kvm.img" "${D}/var/lib/libvirt/images/initramfs"
		cp "${S}/boot/vmlinuz-x86_64-${PVR}-gentoo-kvm" "${D}/var/lib/libvirt/images/vmlinuz-kvm"
		cp "${S}/boot/initramfs-x86_64-${PVR}-gentoo-kvm.img" "${D}/var/lib/libvirt/images/initramfs-kvm"
		rm -rf "${D}/boot" "${D}/lib"
	fi
	if use libvirt-ceph ; then
		local LC_PATH="/var/lib/libvirt/images/cephfs-libvirt/kernel/"
		dodir "${LC_PATH}"
		cp "${S}/boot/vmlinuz-x86_64-${PVR}-gentoo-kvm" "${D}${LC_PATH}/gk-lx"
		cp "${S}/boot/initramfs-x86_64-${PVR}-gentoo-kvm.img" "${D}${LC_PATH}/gk-ifs"

		cp "${S}/boot/vmlinuz-x86_64-${PVR}-gentoo-kvm" "${D}${LC_PATH}/vmlinuz-kvm"
		cp "${S}/boot/initramfs-x86_64-${PVR}-gentoo-kvm.img" "${D}${LC_PATH}/initramfs-kvm"
		rm -rf "${D}/boot" "${D}/lib"
	fi
}

#pkg_preinst(){
#	mount /boot
#	}
pkg_postinst(){
	if use grub-update ;then
		mount /boot ||ewarn "couldn't mount boot"
		elog "updating grub config after kernel update"
		grub-mkconfig -o /boot/grub/grub.cfg
		umount /boot
	fi

	umount /boot
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
