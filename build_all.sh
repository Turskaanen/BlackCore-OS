#!/bin/bash
set -e

DISTRO_CODENAME=noble
MIRROR=http://archive.ubuntu.com/ubuntu
ROOTFS=rootfs
ISO_DIR=iso
ISO_NAME=blackcore-os-v2.iso

echo "[*] Installing dependencies..."
sudo apt update
sudo apt install -y debootstrap squashfs-tools xorriso grub-pc-bin grub-efi-amd64-bin

echo "[*] Cleaning old build..."
sudo rm -rf "$ROOTFS" "$ISO_DIR" "$ISO_NAME"
sudo mkdir -p "$ROOTFS" "$ISO_DIR/boot/grub"

echo "[*] Creating rootfs..."
sudo debootstrap --arch=amd64 "$DISTRO_CODENAME" "$ROOTFS" "$MIRROR"

echo "[*] Adding Ubuntu repositories..."
sudo bash -c "cat > $ROOTFS/etc/apt/sources.list" <<EOF
deb $MIRROR $DISTRO_CODENAME main universe multiverse restricted
deb $MIRROR $DISTRO_CODENAME-updates main universe multiverse restricted
deb $MIRROR $DISTRO_CODENAME-security main universe multiverse restricted
EOF

echo "[*] Installing packages..."
sudo chroot "$ROOTFS" /bin/bash -c "
apt update
apt install -y bash zsh nano vim git python3 curl wget net-tools iproute2 iputils-ping openssh-server sudo htop tmux screen lsb-release ca-certificates gnupg unzip zip tar xz-utils build-essential pkg-config make gcc g++ cmake gdb strace tcpdump whois ufw rsync jq netcat-openbsd socat openssl parted fdisk dosfstools e2fsprogs systemd-sysv locales
"

echo "[*] Setting root password..."
sudo chroot "$ROOTFS" /bin/bash -c "echo 'root:root' | chpasswd"

echo "[*] Enabling SSH..."
sudo chroot "$ROOTFS" /bin/bash -c "systemctl enable ssh || true"

echo "[*] Adding BlackCore branding..."
sudo bash -c "cat > $ROOTFS/etc/os-release" <<EOF
NAME=\"BlackCore OS\"
VERSION=\"2.0\"
ID=blackcore
PRETTY_NAME=\"BlackCore OS 2.0 (CLI)\"
EOF

sudo bash -c "cat > $ROOTFS/etc/issue" <<EOF
BlackCore OS v2.0 (CLI)
Secure by default · Hack by choice
EOF

sudo bash -c "cat > $ROOTFS/etc/motd" <<EOF
Welcome to BlackCore OS v2.0
EOF

echo "[*] Copying BlackCore tools..."
sudo mkdir -p "$ROOTFS/opt/blackcore"
sudo cp -r blackcore-tools/* "$ROOTFS/opt/blackcore/" 2>/dev/null || true

echo "[*] Creating squashfs..."
sudo mksquashfs "$ROOTFS" "$ISO_DIR/filesystem.squashfs" -comp xz -e boot

echo "[*] Copying kernel and initrd..."
sudo cp "$ROOTFS"/boot/vmlinuz-* "$ISO_DIR/vmlinuz"
sudo cp "$ROOTFS"/boot/initrd.img-* "$ISO_DIR/initrd"

echo "[*] Creating GRUB config..."
sudo bash -c "cat > $ISO_DIR/boot/grub/grub.cfg" <<EOF
set timeout=5
set default=0

menuentry \"BlackCore OS v2.0\" {
    linux /vmlinuz boot=live
    initrd /initrd
}
EOF

echo "[*] Building ISO..."
sudo xorriso -as mkisofs \
  -iso-level 3 \
  -o "$ISO_NAME" \
  -full-iso9660-filenames \
  -volid \"BLACKCORE_OS\" \
  "$ISO_DIR"

echo
echo "[+] BlackCore OS v2.0 ISO ready!"
echo "[+] File: $ISO_NAME"
