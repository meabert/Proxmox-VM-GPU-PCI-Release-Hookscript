# Proxmox-VM-GPU-PCI-Release-Hookscript #

![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg)

In certain situations PCI/GPU devices are not properly removed from a VM when
shutdown or restarted. Previous where a host system reboot was used, this
hookscript aims to resolve this problem with no host reboot and instead
integrates a hookscript during VM restarts and power cycles.

## Install / Setup Instructions ##

Clone the repo:

```bash
git clone https://github.com/meabert/Proxmox-VM-GPU-PCI-Release-Hookscript pci-release-hook
cd pci-release-hook
```

Export the VM ID of the target to a variable - replace 111 with
the actual ID ```export ID=111```


Add the hookscript to the config of your desired VM (this is located
under e.g. /etc/pve/qemu-server/${ID}.conf):

```bash
echo "hookscript: local:snippets/pci-release-hook.sh" \
>> "/etc/pve/qemu-server/${ID}.conf"

```
Make the script executable:

```chmod +x pci-release-hook.sh```

Move the script to a valid snippet directory for simplicity.

```bash
cp pci-release-hook.sh /var/lib/vz/snippets/pci-release-hook.sh
```
/etc/pve/local

hookscript: local:/etc/pve/hooks/pci-release-hook.sh
