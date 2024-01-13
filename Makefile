disk.img:
	qemu-img create -f raw disk.img 200M
	mkfs.fat -n 'MIKAN OS' -s 2 -f 2 -R 32 -F 32 disk.img

.PHONY: update-disk
update-disk: disk.img
	sudo mount -o loop disk.img mnt
	sudo mkdir -p mnt/EFI/BOOT
	sudo cp ${TARGET} mnt/EFI/BOOT/BOOTX64.EFI

.PHONY: clean
clean:
	sudo umount mnt
	rm disk.img

.PHONY: qemu-up
qemu-up:
	qemu-system-x86_64 \
		-drive if=pflash,file=${HOME}/osbook/devenv/OVMF_CODE.fd \
		-drive if=pflash,file=${HOME}/osbook/devenv/OVMF_VARS.fd \
		-hda disk.img
