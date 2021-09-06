DOWNLOAD_DIRECTORY := "${HOME}/Downloads/"
LINUX_ISO_TORRENT_URL := https://mirrors.kernel.org/archlinux/iso/$(shell date +%Y.%m).01/archlinux-$(shell date +%Y.%m).01-x86_64.iso.torrent

out:
	mkdir out

out/linux.iso:
	aria2c --dir="${DOWNLOAD_DIRECTORY}" --check-integrity=true --seed-time=0 "${LINUX_ISO_TORRENT_URL}"
	ln -s "${DOWNLOAD_DIRECTORY}/$(basename $(notdir ${LINUX_ISO_TORRENT_URL}))" out/linux.iso
	# qemu-img convert out/linux.iso out/linux.img

out/linux-kernel: out/linux.iso
	./extract-iso-kernel.sh

out/main.img: out/linux-kernel
	qemu-img create -f qcow2 $@ 15G
	./bootstrap.exp || (rm -f "$@" && exit 1)
