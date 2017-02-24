#!/bin/bash
# installing drivers
tar -C / -xzvf nvidia-*.tar.gz

#Thx to tleyden : https://gist.githubusercontent.com/tleyden/74f593a0beea300de08c/raw/95ed93c5751a989e58153db6f88c35515b7af120/nvidia_devices.sh
# Count the number of NVIDIA controllers found.
NVDEVS=`lspci | grep -i NVIDIA`
N3D=`echo "$NVDEVS" | grep "3D controller" | wc -l`
NVGA=`echo "$NVDEVS" | grep "VGA compatible controller" | wc -l`
N=`expr $N3D + $NVGA - 1`
for i in `seq 0 $N`; do
mknod -m 666 /dev/nvidia$i c 195 $i
done
mknod -m 666 /dev/nvidiactl c 195 255

# Find out the major device number used by the nvidia-uvm driver
D=`grep nvidia-uvm /proc/devices | awk '{print $1}'`
mknod -m 666 /dev/nvidia-uvm c $D 0


sudo rkt run --insecure-options=image --volume nvidia-uvm,source=/dev/nvidia-uvm,kind=host --mount volume=nvidia-uvm,target=/dev/nvidia-uvm --volume nvidia0,source=/dev/nvidia0,kind=host --mount volume=nvidia0,target=/dev/nvidia0 --volume nvidiactl,source=/dev/nvidiactl,kind=host --mount volume=nvidiactl,target=/dev/nvidiactl --volume nvidia,source=/opt/nvidia/bin,kind=host --mount volume=nvidia,target=/opt/bin --volume lib,source=/opt/nvidia/lib,kind=host --mount volume=lib,target=/usr/local/nvidia/lib docker://nvidia/cuda:latest --set-env=LD_PRELOAD=/usr/local/nvidia/lib/libnvidia-ml.so --exec=/opt/bin/nvidia-smi --interactive

