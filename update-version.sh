#!/bin/sh

if [ -z "$1" ] || [ -z "$2" ]; then
	echo "usage: $0 version message"
	echo "current version: "`head -n 1 debian/changelog | cut -d "(" -f 2 | cut -d ")" -f 1`
	exit 1
fi

version_to_number() {
	major=`echo "$1" | cut -d . -f 1`
	minor=`echo "$1" | cut -d . -f 2`
	patch=`echo "$1" | cut -d . -f 3`

	expr "$major" "*" 1000 + "$minor" "*" 100 + "$patch"
}

version="$1"
message="$2"

version_num=`version_to_number "$version"`
current_version=`head -n 1 debian/changelog | cut -d "(" -f 2 | cut -d ")" -f 1`
current_version_num=`version_to_number "$current_version"`

if [ -z "$version_num" ] || [ -z "$current_version_num" ]; then
	echo "error: calculating version number for $version or $current_version"
	exit 1
fi

if [ ! "$version_num" -gt "$current_version_num" ]; then
	echo "error: current version $current_version is not lower than $version"
	exit 1
fi

# Update *.spec
find . -name "*.spec" -type f | grep -v dependencies/ | while read f; do
	version_subs="%%s/^Version: .*/Version: $version/"
	goto_changelog="/^%%changelog/+1i"
	change_header="* $(date +"%a %b %d %Y") Jimmy Bergman <jimmy@atomia.com> - ${version}-1"
	ed_script=`printf "$version_subs\n$goto_changelog\n$change_header\n- $message\n.\nw\nq\n"`
	echo "$ed_script" | ed "$f"
done

# Update */Makefile.PL
find . -name "Makefile.PL" | grep -v dependencies/ | while read f; do
	version_subs="%%s/'VERSION' => '.*',/'VERSION' => '$version',/"
	ed_script=`printf "$version_subs\nw\nq\n"`
	echo "$ed_script" | ed "$f"
done

# Update */changelog
find . -name "changelog" | grep -v dependencies/ | while read f; do
	date=`date +"%a, %-d %b %Y %T %z"`
	package=`grep " lucid; " "$f" | head -n 1 | cut -d " " -f 1`
	changelog=`printf "%s (%s) lucid; urgency=low\n\n  * %s\n\n -- Jimmy Bergman <jimmy@sigint.se>  %s" "$package" "$version" "$message" "$date"`
	ed_script=`printf "1i\n%s\n\n.\nw\nq\n" "$changelog"`
	echo "$ed_script" | ed "$f"
done
