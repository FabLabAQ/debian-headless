# Debian automatic PXE installation

## Disclaimer:
#### The provided files are intended to be used in a didactic environment. Beware that this installer will install unconditionally, it will destroy all of your data on local hard-disk. We don't take any responsibility, use at your own risk. Don't use for a production environment, and buy a subscription for Proxmox if you use it for business.

### Description:
Automatically install Debian 10 and Proxmox.

- `chainload.kpxe` is an iPXE bootloader whose purpose is chainloading the customizable `chain.ipxe` script from `tftp://192.168.4.1/chain.ipxe` which is our tftp server, to change it you may need to recompile iPXE,  [see the official documentation here](https://ipxe.org/embed)
- `chain.ipxe` loads the Linux kernel and initial ramdisk, plus some boot parameters, such as the `preseed.cfg` file and the hostname based on client's MAC address.
- `preseed.cfg` is configured for a fully automated install, after which Proxmox gets installed, the server then is shut down instead of being rebooted to prevent installing again if you forget to disable PXE boot.

### Prerequisites:
DHCP and tftp server up and running. For example, on OpenWRT follow these steps:

- Assuming there is already external storage mounted under `/mnt/usb` and there is a directory `tftp` inside
- Go to **Network** menu and then to **DHCP and DNS** submenu
- Open **TFTP Settings** tab
- Check **Enable TFTP server**
- Write `/mnt/usb/tftp/` in **TFTP server root**
- Write `chainload.kpxe` in **Network boot image**

Also, you have to provide your ssh public key to ssh in after reboot. This could be optional though, since there will be the Proxmox control panel available.

### Install procedure:

Copy the files (or just clone the whole repo) `chainload.kpxe chain.ipxe build/initrd.gz linux` to the TFTP directory on the server/router. Assuming you have ssh root access to the router:

	git clone https://github.com/FabLabAQ/debian-headless.git
	cd debian-headless
	scp chainload.kpxe chain.ipxe build/initrd.gz linux id_rsa.pub root@openwrt:/mnt/usb/tftp/


Start the servers, making sure to enable booting from PXE just for this time (it may be necessary enabling option ROM in the BIOS).
Once booted and reached the installer, they become available via ssh for debugging only, since the installer will proceed automatically. To discover active machines, supposing that your network is `192.168.4.0/24`, do:

	nmap 192.168.4.* -p 22 --open

For example, if your host is `192.168.4.135` do:

	ssh installer@192.168.4.135
	
It will open the installation console, to switch between the tabs use `Ctrl A` followed by `Ctrl N` (next) or `Ctrl P` (previous). Even if the installer seems to be waiting for the user input, he's doing his work, you can see the log in the fourth tab.

### Post-install:
Change the temporary password and build the cluster