#!/bin/sh

if [ -z "$1" ] || [ -z "$2" ]; then
	echo "usage: $0 version dist"
	exit 1
fi

svn add packages/"$2"/*"$1"*
svn commit -m "Release $2 apt-packages for version $1"

scp packages/"$2"/*"$1"*.deb root@apt.atomia.com:
ssh root@apt.atomia.com 'cd /var/packages/ubuntu-'"$2"' && reprepro includedeb '"$2"' /root/libatomia-bindings-coreapi-perl_*'"$1"'*.deb'
