DOWNLOAD_DIRECTORY := ${HOME}/Downloads/
LINUX_ISO_TORRENT_URL := https://mirrors.kernel.org/archlinux/iso/$(shell date +%Y.%m).01/archlinux-$(shell date +%Y.%m).01-x86_64.iso.torrent

out:
	mkdir out

out/linux.iso: out
	aria2c --dir="${DOWNLOAD_DIRECTORY}" --check-integrity=true --seed-time=0 "${LINUX_ISO_TORRENT_URL}"
	[ ! -s out/linux.iso ] || unlink out/linux.iso
	ln -s "${DOWNLOAD_DIRECTORY}/$(basename $(notdir ${LINUX_ISO_TORRENT_URL}))" out/linux.iso

out/main.img: out/linux.iso
	qemu-img create -f qcow2 $@ 15G
	./bootstrap.sh || (rm -f "$@" && exit 1)
	# ./bootstrap.expect || (rm -f "$@" && exit 1)

clean:
	[ ! -d out ] || rm -rf out