#!/bin/sh

if [ -z "$1" ] || [ ! -d "packages/$1" ]; then
	echo "usage: $0 dist"
	exit 1
fi

dpkg-buildpackage -rfakeroot -tc -us -uc
mv ../libatomia-bindings-coreapi-perl*deb packages/"$1"
rm ../libatomia-bindings-coreapi-perl_*
