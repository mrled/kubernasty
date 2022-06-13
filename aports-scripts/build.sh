#!/bin/sh
set -eu

kubernastydir="$HOME"/kubernasty
aportsdir="$HOME"/aports
workdir="$HOME"/tmp/mkimage-workdir

# Kubernasty mkimage and genapkovl scripts expect this to be present
export KNTYDIR="$kubernastydir/overlay"

cp mkimg.kubernasty.sh genapkovl-kubernasty.sh "$aportsdir"/scripts/

sudo rm -rf /tmp/mkimage*
sudo rm -rf "$workdir"/apkovl*
sudo rm -rf "$workdir"/apkroot*

#sudo apk update

starttime=$(date)

cd "$aportsdir"/scripts
./mkimage.sh \
    --tag knty000 \
    --outdir ~/isos \
    --arch x86_64 \
    --repository http://mirrors.edge.kernel.org/alpine/v3.16/main \
    --repository http://mirrors.edge.kernel.org/alpine/v3.16/community \
    --workdir "$workdir" \
    --profile kubernasty

endtime=$(date)

echo "Started: $starttime"
echo "Ended:   $endtime"

echo "ISO directory: ~/isos:"
ls -alF ~/isos/
