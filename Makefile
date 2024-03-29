disk.img:
	qemu-img create -f raw disk.img 200M
	mkfs.fat -n 'MIKAN OS' -s 2 -f 2 -R 32 -F 32 disk.img

.PHONY: update-disk
update-disk: disk.img
	sudo mount -o loop disk.img mnt
	sudo mkdir -p mnt/EFI/BOOT
	sudo cp ${TARGET} mnt/EFI/BOOT/BOOTX64.EFI
	sudo cp kernel/kernel.elf mnt/kernel.elf

.PHONY: clean
clean:
	sudo umount mnt
	rm -f disk.img
	rm -f kernel/*.o

.PHONY: qemu-up
qemu-up:
	qemu-system-x86_64 \
		-drive if=pflash,file=${HOME}/osbook/devenv/OVMF_CODE.fd \
		-drive if=pflash,file=${HOME}/osbook/devenv/OVMF_VARS.fd \
		-hda disk.img \
		-monitor stdio

kernel/kernel.elf: kernel/main.o
	ld.lld ${LDFLAGS} --entry KernelMain -z norelro --image-base 0x100000 --static \
		-T kernel/linker.ld \
		-o kernel/kernel.elf kernel/main.o
	# ld.lld --entry KernelMain -z norelro --image-base 0x100000 --static \
	# 	-o kernel/kernel.elf kernel/main.o

kernel/main.o:
	clang++ ${CPPFLAGS} -O2 -Wall -g --target=x86_64-elf -ffreestanding -mno-red-zone \
		-fno-exceptions -fno-rtti -std=c++17 -o kernel/main.o -c kernel/main.cpp
	#clang++ ${CPPFLAGS} -O2 -Wall -g --target=x86_64-elf -ffreestanding -mno-red-zone \
	#	-fno-exceptions -fno-rtti -std=c++17 -o kernel/main.o -c kernel/main.cpp
