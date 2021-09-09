DOWNLOAD_DIRECTORY := ${HOME}/Downloads/
LINUX_ISO_TORRENT_URL := https://mirrors.kernel.org/archlinux/iso/$(shell date +%Y.%m).01/archlinux-$(shell date +%Y.%m).01-x86_64.iso.torrent

build: out/main.img

out:
	mkdir out

out/linux.iso: out
	aria2c --dir="${DOWNLOAD_DIRECTORY}" --seed-time=0 --check-integrity=true --continue=true "${LINUX_ISO_TORRENT_URL}"
	[ ! -s $@ ] || unlink $@
	ln -s "${DOWNLOAD_DIRECTORY}/$(basename $(notdir ${LINUX_ISO_TORRENT_URL}))" $@
	touch $@

out/bootstrapper:
	cd bootstrapper && go build -o ${PWD}/$@ .

out/meta-data:
	touch $@

out/user-data:
	./init-user-data.sh

out/cloud-init.iso: out/meta-data out/user-data
	xorriso -as genisoimage -output $@ -volid CIDATA -joliet -rock $^

out/main.img: out/bootstrapper out/linux.iso out/cloud-init.iso
	qemu-img create -f qcow2 $@ 15G
	./out/bootstrapper || (rm -f "$@" && exit 1)
	@# ./bootstrap.sh || (rm -f "$@" && exit 1)

clean:
	[ ! -d out ] || rm -rf out