#!/bin/bash
set -e 
KVERS=$(ls -l /usr/src/linux|awk '{print $10}')
VERSN=$(echo $KVERS|cut -d'-' -f 2-)
LVERS=genkernel
genkernel all	--kerncache=kerncache/$KVERS-$LVERS.tar \
		--kernel-localversion="-$LVERS" \
		--kernel-filename='vmlinuz-%%ARCH%%-%%KV%%' \
		--initramfs-filename='initramfs-%%ARCH%%-%%KV%%.img' \
		--no-install \
		$2 $3
cp kerncache/$KVERS-$LVERS.tar $KVERS-$LVERS.tar
tar -rf $KVERS-$LVERS.tar /var/tmp/genkernel/initramfs-x86_64-$VERSN-$LVERS --transform 's/var\/tmp\/genkernel/boot/' --transform 's/$/.img/'
tar -rf $KVERS-$LVERS.tar /var/tmp/genkernel/kernel-x86_64-$VERSN-$LVERS --transform 's/var\/tmp\/genkernel/boot/'  --transform 's/kernel/vmlinuz/'
pv $KVERS-$LVERS.tar | xz -z > $KVERS-$LVERS.tar.xz
rm $KVERS-$LVERS.tar || echo '\n\nBULD FAILED\n\n' 
