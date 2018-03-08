#!/bin/bash

# export cross compile envs if arm specified as a parameter
if [ x"$1" == "x" ]; then
    echo "Usage: $0 <arm|default>"
    echo "      default means host platform"
    exit 0
else
    case $1 in
        "arm")
            export ARCH=arm
            export CROSS_COMPILE=arm-linux-gnueabihf-
            ;;
        "default")
            echo $(uname -m)
            ARCH=$(uname -m)
            ;;
    esac
fi

function GetPKGArch()
{
	if [ $(uname -m) == "x86_64" ];then
		echo "amd64"
	else
		echo "i386"
	fi
}

function DirCheck()
{
	if [ ! -d $1 ];then
		mkdir -p $1
	fi
}

function fileCheck()
{
    if [ -e $1 ]; then
        rm -rf $1
    fi
}

# copy with parents path, only can do this in kernel source dir
function copy_fullpath()
{
    find $1 -name "*.h" -exec cp --parents {} $2 \;
    find $1 -name "*.conf" -exec cp --parents {} $2 \;
    find $1 -name "Makefile*" -exec cp --parents {} $2 \;
    find $1 -name "Kbuild*" -exec cp --parents {} $2 \;
    find $1 -name "Kconfig*" -exec cp --parents {} $2 \;
    # find $1 -type f -executable -exec cp --parents {} $2 \;
}
# copy essensial header files to dest dir
# eg: headers_prepare /usr/src/linux-headers-$VERSION
function headers_prepare()
{
    # copy to build headers deb
    # cp -r ./include ${HDR_DIR}/usr/src/linux-headers-$VERSION
    # cp ./.kernelvariables $1 
    make scripts
    # make scripts will produce include/config/auto.conf
    # which is needed by the build process of any external module
    cp ./.config $1
    cp ./Module.symvers $1
    cp --parents ./arch/Kconfig  $1

    cp ./Makefile $1
    #cp ./Kbuild $1
    cp ./Kconfig $1

    # copy dir in include to $1
    # copy_fullpath src dst
    dirs=(block certs crypto drivers firmware fs include \
        init ipc kernel lib mm net samples security sound \
        tools usr virt)
    # dirs=(include)
    for dir in ${dirs[@]};
    do
        # copy executables/makefile/kbuild/kconfig/.h
        echo "copy_full path $dir $1"
        copy_fullpath $dir $1/
    done

    # for arch dir, only copy targed arch dir for cross compile
    #if [ "x$ARCH" == "xx86_64" ]; then
    #    HDR_ARCH=.  # copy other architectures' headers for
    #                # cross compile
    #else
    #    HDR_ARCH=$ARCH
    #fi
    #copy_fullpath ./arch/${HDR_ARCH} $1/
    copy_fullpath ./arch/ $1/

    cp -r scripts $1/
}


RELEASE_FILE=include/config/kernel.release
if [ -e $RELEASE_FILE ]; then
    VERSION=$(cat include/config/kernel.release)
else
    echo "make prepare and then make, this will build the release file needed "
    exit 0
fi
INSTALL_PATH=./linux-image-$VERSION/boot/
INSTALL_MOD_PATH=./linux-modules-$VERSION/lib/
HDR_PATH=./linux-headers-$VERSION/usr/src/linux-headers-$VERSION
IMG_DIR=./linux-image-$VERSION
MOD_DIR=./linux-modules-$VERSION
HDR_DIR=./linux-headers-$VERSION



if [ "x$ARCH" == "x" ];then
	PKG_ARCH=$( GetPKGArch )
    ARCH_ALIA=${ARCH}
    UPDATE_GRUB="update-grub"
    KERNEL_DEPS=""
    MAKE_UINITRD=""
fi
if [ "x$ARCH" == "xarm" ];then
    ARCH_ALIA=${ARCH}hf
    UPDATE_GRUB=""
    KERNEL_DEPS="u-boot-tools"
    MAKE_UINITRD="genuinitrd"
fi


echo $ARCH


DirCheck ${IMG_DIR}/boot
DirCheck ${IMG_DIR}/DEBIAN
DirCheck ${HDR_DIR}/usr/src/linux-headers-$VERSION/
DirCheck ${HDR_DIR}/DEBIAN

DirCheck ${MOD_DIR}/lib
DirCheck ${MOD_DIR}/DEBIAN
rm -rf ${INSTALL_PATH}/*
rm -rf ${INSTALL_MOD_PATH}/*

fileCheck ./${IMG_DIR}/DEBIAN/control
cat >./${IMG_DIR}/DEBIAN/control<<EOF
Package: linux-image-$VERSION
Version: $VERSION
Architecture: $ARCH_ALIA
Depends: $KERNEL_DEPS
Maintainer: huangyu<diwang90@gmail.com>
Description: linux kernel
EOF


fileCheck ./${IMG_DIR}/DEBIAN/postinst
cat >./${IMG_DIR}/DEBIAN/postinst<<EOF
#!/bin/bash
function genuinitrd()
{
    cp /boot/initrd.img-$VERSION /tmp
    cd /tmp
    mkimage -A arm -T ramdisk -C none -n uInitrd -d initrd.img-$VERSION uinitrd
    cp uinitrd /boot/initrd.img-$VERSION
}
if [ -e /boot/initrd.img-$VERSION ];then
	rm /boot/initrd.img-$VERSION
    update-initramfs -k $VERSION -c
fi
EOF

chmod 0555 ./${IMG_DIR}/DEBIAN/postinst

fileCheck ./${IMG_DIR}/DEBIAN/postrm
cat >./${IMG_DIR}/DEBIAN/postrm<<EOF
#!/bin/bash
${UPDATE_GRUB}
EOF

chmod 0555 ./${IMG_DIR}/DEBIAN/postrm


fileCheck ./${MOD_DIR}/DEBIAN/control
cat >./${MOD_DIR}/DEBIAN/control<<EOF
Package: linux-modules-$VERSION
Version: $VERSION
Architecture: $ARCH_ALIA
Depends: linux-image-$VERSION
Maintainer: huangyu<diwang90@gmail.com>
Description: linux kernel modules
EOF


fileCheck ./${MOD_DIR}/DEBIAN/postinst
cat >./${MOD_DIR}/DEBIAN/postinst<<EOF
#!/bin/bash
function genuinitrd()
{
    cp /boot/initrd.img-$VERSION /tmp
    cd /tmp
    mkimage -A arm -T ramdisk -C none -n uInitrd -d initrd.img-$VERSION uinitrd
    cp uinitrd /boot/initrd.img-$VERSION
}
if [ -e /boot/initrd.img-$VERSION ];then
	rm /boot/initrd.img-$VERSION
fi
update-initramfs -k $VERSION -c
${MAKE_UINITRD}
${UPDATE_GRUB}
EOF

fileCheck ./${HDR_DIR}/DEBIAN/control
cat >./${HDR_DIR}/DEBIAN/control<<EOF
Package: linux-headers-$VERSION
Version: $VERSION
Architecture: $ARCH_ALIA
Depends: linux-image-$VERSION, linux-modules-$VERSION
Maintainer: huangyu<diwang90@gmail.com>
Description: linux kernel headers
EOF

fileCheck ./${HDR_DIR}/DEBIAN/postinst
cat >./${HDR_DIR}/DEBIAN/postinst<<EOF
#!/bin/bash
if [ -e /lib/modules/$VERSION ];then
    ln -sf /usr/src/linux-headers-$VERSION /lib/modules/$VERSION/build
    ln -sf /usr/src/linux-headers-$VERSION /lib/modules/$VERSION/source
fi
EOF

chmod 0555 ./${MOD_DIR}/DEBIAN/postinst
chmod 0555 ./${HDR_DIR}/DEBIAN/postinst

INSTALL_PATH=./${IMG_DIR}/boot/ make install
INSTALL_MOD_PATH=./${MOD_DIR}/ make modules_install

# headers file prepare
headers_prepare ${HDR_PATH}

#find ./scripts -type f -executable -exec cp --parents {} ${KBUILD_PATH} \;  
# copy to build kbuild

# delete firmware, get them from official repo
if [ -e ${MOD_DIR}/lib/firmware ]; then
    rm -r ${MOD_DIR}/lib/firmware
fi
# delete symlink to this compile dir
rm  ${MOD_DIR}/lib/modules/$VERSION/build
rm  ${MOD_DIR}/lib/modules/$VERSION/source

# for arm kernel, using zImage and uInitrd
if [ "x$ARCH" == "xarm" ];then
    cp arch/arm/boot/zImage ${INSTALL_PATH}/vmlinuz-$VERSION
fi


sudo chown -r root:root ${IMG_DIR} ${MOD_DIR} ${HDR_DIR}
dpkg -b ${IMG_DIR}
dpkg -b ${MOD_DIR}
dpkg -b ${HDR_DIR}
