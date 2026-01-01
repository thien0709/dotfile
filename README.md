1. Đổi Driver (Chạy lần lượt)
sudo pacman -Rns nvidia-open-dkms
sudo pacman -S nvidia-dkms nvidia-utils lib32-nvidia-utils linux-headers
2. Cấu hình GRUB
sudo nano /etc/default/grub
Thao tác tay: Thêm nvidia-drm.modeset=1 vào trong dòng GRUB_CMDLINE_LINUX_DEFAULT="...". Lưu file: Ctrl+O -> Enter -> Ctrl+X

Cập nhật cấu hình:
sudo grub-mkconfig -o /boot/grub/grub.cfg
3. Hoàn tất
sudo mkinitcpio -P
reboot
