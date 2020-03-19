#include config.txt

BUILD_DIR = build

install-depends:
	sudo apt install cpio pssh pscp sshpass

initrd: clean unpack preseed

unpack:
	mkdir ${BUILD_DIR}
	cp initrd.gz ${BUILD_DIR}/
	chmod -R +w ${BUILD_DIR}
	gunzip ${BUILD_DIR}/initrd.gz

preseed:
	echo preseed.cfg | cpio -H newc -o -A -F ${BUILD_DIR}/initrd
	echo proxmox-ve-release-6.x.gpg | cpio -H newc -o -A -F ${BUILD_DIR}/initrd
	echo id_rsa.pub | cpio -H newc -o -A -F ${BUILD_DIR}/initrd
	gzip ${BUILD_DIR}/initrd

clean:
	rm -rf ${BUILD_DIR}

SEARCH_NET ?= 192.168.0.*
SEARCH_PORT ?= 8006
get_ip := nmap $(SEARCH_NET) -p $(SEARCH_PORT) --open -oG - | awk '/$(SEARCH_PORT)\/open.*/{print $$2}'

passwd:
	@read -sp "New password:" NEW_PASSWORD; \
	parallel-ssh -O StrictHostKeyChecking=no -H "$$(${get_ip})" -l root "echo root:$$NEW_PASSWORD | chpasswd"

START_IP ?= 10
END_IP ?= 19

reorder-ip:
	START_IP=${START_IP}; \
	IP_LIST="$$(${get_ip})"; \
	for i in {$(START_IP)..$(END_IP)}; do \
		ssh -o StrictHostKeyChecking=no root@$${IP_LIST[""$$(($$i-$$START_IP))""]} "sed 's/192.168.4.*/192.168.4.$$i/' /etc/hosts"; \
	done

#cluster:
	
# EOF
