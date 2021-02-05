#!/bin/bash
KVERS=$(ls -l /usr/src/linux|awk '{print $10}')
LVERS=$1
GENK_MODS="$(cat genk.$LVERS)"
rm /boot/*
genkernel all	--kerncache=kerncache/$KVERS-$LVERS.tar \
		--kernel-config=config.$LVERS \
		--kernel-localversion="-$LVERS" \
		--kernel-filename='vmlinuz-%%ARCH%%-%%KV%%' \
		--initramfs-filename='initramfs-%%ARCH%%-%%KV%%.img' \
		$GENK_MODS $2 $3 &&\
cp kerncache/$KVERS-$LVERS.tar $KVERS-$LVERS.tar &&\
tar -rf $KVERS-$LVERS.tar /boot/* &&\
pv $KVERS-$LVERS.tar | xz -z > $KVERS-$LVERS.tar.xz && rm $KVERS-$LVERS.tar || printf '\n\nBULD FAILED\n\n'
