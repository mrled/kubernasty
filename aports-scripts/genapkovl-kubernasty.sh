#!/bin/sh -e

if test -z "$KNTYDIR"; then
	echo "Missing environment variable \$KNTYDIR"
	exit 1
fi

# mkimage.sh will call this with a HOSTNAME of "alpine",
# and that's what the hostname will be when the image first boots.
# We later set it in a local.d script.
HOSTNAME="$1"
if [ -z "$HOSTNAME" ]; then
	echo "usage: $0 hostname"
	exit 1
fi

cleanup() {
	rm -rf "$tmp"
}

makefile() {
	OWNER="$1"
	PERMS="$2"
	FILENAME="$3"
	cat > "$FILENAME"
	chown "$OWNER" "$FILENAME"
	chmod "$PERMS" "$FILENAME"
}

rc_add() {
	mkdir -p "$tmp"/etc/runlevels/"$2"
	ln -sf /etc/init.d/"$1" "$tmp"/etc/runlevels/"$2"/"$1"
}

tmp="$(mktemp -d)"
trap cleanup EXIT

mkdir -p "$tmp"/etc
makefile root:root 0644 "$tmp"/etc/hostname <<EOF
$HOSTNAME
EOF

install -o root -g root -m 0755 -d "$tmp"/etc/network
install -o root -g root -m 0755 "$KNTYDIR"/network-interfaces "$tmp"/etc/network/interfaces

mkdir -p "$tmp"/etc/apk

# Cannot set the repositories this way ?
# makefile root:root 0644 "$tmp"/etc/apk/repositories <<EOF
# /media/cdrom/apks
# http://mirrors.edge.kernel.org/alpine/v3.16/main
# http://mirrors.edge.kernel.org/alpine/v3.16/community
# EOF

install -o root -g root -m 0755 -d "$tmp"/etc/apk
install -o root -g root -m 0644 "$KNTYDIR"/apk-world "$tmp"/etc/apk/world

install -o root -g root -m 0644 "$KNTYDIR"/issue "$tmp"/etc/issue
install -o root -g root -m 0644 "$KNTYDIR"/motd "$tmp"/etc/motd

install -o root -g root -m 0700 -d "$tmp"/etc/kubernasty

install -o root -g root -m 0600 "$KNTYDIR"/etc-kubernasty/postboot.secrets "$tmp"/etc/kubernasty/postboot.secrets

# I don't configure this here bc it doesn't seem to work
# I saw that this project did this: <https://github.com/mayarid/penyu/blob/master/genapkovl-penyu.sh>
# But it's abandoned so I'm not even sure if that is correct
# cat > /tmp/installer.conf <<'_EOF_'
# _EOF_
# # Do I want to '-a' there? just added this and haven't tested the result yet.
# # Should this be inside of a chroot? It is modifying my build host system when I do this.
# sudo /sbin/setup-alpine -a -e -q -f /tmp/installer.conf
# NO. Instead lets read setup-alpine, call the parts I care about in kubernasty-postboot.start, and ignroe the rest.

install -o root -g root -m 0755 -d "$tmp"/etc/local.d
install -o root -g root -m 0755 "$KNTYDIR"/local.d_kubernasty-postboot.start "$tmp"/etc/local.d/kubernasty-postboot.start


# Add a publicly readable directory for any kubernasty stuff that we might need.
install -o root -g root -m 0755 -d "$tmp"/knty
# Add a secret directory that is only readable by root.
# Mount inside of that, so that no matter what filesystem permissions in the knty-secret mount are,
# no user except root will be able to read the files there.
install -o root -g root -m 0700 -d "$tmp"/knty/secret "$tmp"/knty/secret/mount



rc_add devfs sysinit
rc_add dmesg sysinit
rc_add mdev sysinit
rc_add hwdrivers sysinit
rc_add modloop sysinit

rc_add hwclock boot
rc_add modules boot
rc_add sysctl boot
rc_add hostname boot
rc_add bootmisc boot
rc_add syslog boot

rc_add local default
rc_add sshd default

# TODO: automate cluster bootstrap and then enable this
# rc_add k3s default

rc_add mount-ro shutdown
rc_add killprocs shutdown
rc_add savecache shutdown

echo "About to create apkovl"
echo "PWD: $(pwd)"
echo "Tmp dir: $tmp"
echo "Tmp dir contents: $(ls -alF "$tmp")"

tar -c -C "$tmp" . | gzip -9n > $HOSTNAME.apkovl.tar.gz
