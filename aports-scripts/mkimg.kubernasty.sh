kntydir="$HOME/aports/scripts/overlay.kubernasty"

if test -z "$KNTYDIR"; then
	echo "Missing environment variable \$KNTYDIR"
	exit 1
fi

kntyworld="$KNTYDIR"/apk-world
kntyapks="$(cat "$kntyworld")"

profile_kubernasty() {
	profile_standard
	title="KuberNASTY"
	desc="The nastiest k3s host in the 'verse"
	arch="x86_64"
	kernel_flavors="lts"
	# kernel_addons=""
	boot_addons="intel-ucode"
	initrd_ucode="/boot/intel-ucode.img"

	# These are .apk files that will exist in the resulting iso image
	# This doesn't install them in the image, just adds the package file to /apks
	apks="$apks $kntyapks"
	local _k _a
	for _k in $kernel_flavors; do
		apks="$apks linux-$_k"
		for _a in $kernel_addons; do
			apks="$apks $_a-$_k"
		done
	done
	apks="$apks linux-firmware"

	apkovl="genapkovl-kubernasty.sh"

	# This hostname gets set at boot
	# We override it in a local.d script later
	hostname="kubernasty-bootstrap"
}
