#!/bin/sh -e
set -xv

. config/versions.sh

# Install nfpm
tar xzf nfpm.tar.gz nfpm
mv nfpm /usr/bin

# Fill the config
envsubst 
envsubst < config/nfpm.yaml > config/nfpm.yaml_tmp
mv config/nfpm.yaml_tmp config/nfpm.yaml

# Package
case "$OS" in 
    alpine)
		PACKAGER=apk
        INSTALL_CMD='apk add --allow-untrusted *.apk'
        ;;
    centos)
		PACKAGER=rpm
        INSTALL_CMD='rpm -Uvh *.rpm'
        ;;
    debian)
		PACKAGER=deb
        INSTALL_CMD='dpkg -i *.deb'
        ;;
    fedora)
		PACKAGER=rpm
        INSTALL_CMD='rpm -Uvh *.rpm'
        ;;
    opensuse)
		PACKAGER=rpm
        INSTALL_CMD='rpm -Uvh *.rpm'
        ;;
    rhel)
		PACKAGER=rpm
        INSTALL_CMD='rpm -Uvh *.rpm'
        ;;
    ubuntu)
		PACKAGER=deb
        INSTALL_CMD='dpkg -i *.deb'
        ;;
    *)
        echo "Sorry, distro not found. Send a PR. :)"
        exit 1
        ;;
esac    

nfpm pkg -f config/nfpm.yaml --packager $PACKAGER /tmp/.font-unix
ls -la /tmp

# Test the package
rm -rf /opt/rakudo-pkg
$INSTALL_CMD
. /etc/profile.d/rakudo-pkg.sh
raku -v
zef --version
