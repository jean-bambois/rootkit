#!/bin/bash

EXIT_CODE=1
DEBUG_OPTS=
INITRAMFS=initramfs.cpio.gz

# Parsing the options (if any)
while [ "$1" != "" ]; do
    case $1 in
        -d | --debug )
	    DEBUG_OPTS='-S -gdb tcp::1234'
            echo "Start debugger with:"
            echo "#> gdb --silent vmlinux"
            echo "(gdb)> target remote :1234"
            ;;
	-h | --help )
	    EXIT_CODE=0
	    ;&
        * )
            echo "usage: $(basename $0) [-d|--debug] [-h|--help]"
	    echo ""
	    echo "-d, --debug	Start the kernel for remote debug"
	    echo "-h, --help	Display this help"
	    exit $EXIT_CODE
    esac
    shift
done

# Create the mount point if needed
mkdir -p mnt/

# Running QEMU
qemu-system-x86_64 \
    -m 1G \
    -no-reboot \
    -nographic \
    -enable-kvm \
    -kernel bzImage \
    -initrd initramfs.cpio.gz \
    -fsdev local,id=exp1,path=mnt,security_model=mapped \
    -device virtio-9p-pci,fsdev=exp1,mount_tag=mountpoint \
    -append 'console=ttyS0 loglevel=3 oops=panic panic=1' \
    $DEBUG_OPTS
