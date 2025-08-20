# Proxmox PCI Device Reset for VMs #

![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg)![GitHub commit activity](https://img.shields.io/github/commit-activity/t/meabert/Proxmox-VM-GPU-PCI-Release-Hookscript)![GitHub Issues or Pull Requests](https://img.shields.io/github/issues/meabert/Proxmox-VM-GPU-PCI-Release-Hookscript)

> [!NOTE]
> Does your GPU or HBA keep disappearing when you reboot a VM?
> Will the device not comeback unless you restart the host?
>
> This script might be able to help!

**Scope of this repo:**

Eliminate the need for reboots when PCI devices go missing on VM host
platforms - this generally occurs after an unexpected update or when
an unplanned restart is triggered.

**Symptoms:**

**Sample Use Cases:**

Local LLM - if an LLM is either extremely slow or has stopped responding
completely validate GPU presence with the manuafacturer monitoring tool
nvidia-smi, intel_gpu_top or amdgpu_top.

TrueNAS - after a reboot the HBA disappears and all or some ZFS disks
are in the red. (Don't panic and don't export any dataset!)

**Impacted devices:**

Host Bus Adapters (HBA), Graphics Processing Units (GPU), Network Cards (NIC)
AI Accelerators, Small Form-factor Pluggable (SFP) or any other PCI device.

> [!CAUTION]
> The methods used here should be transferrable to something else assuming KVM
> is the backend. I cannot speak for Bhyve or Xen based hypervisors however
> all solutions presented here have been tested on Proxmox 9 and Proxmox 8.

## Install / Setup Instructions ##

Clone the repo:

```bash
git clone https://github.com/meabert/Proxmox-VM-GPU-PCI-Release-Hookscript pci-release-hook
cd pci-release-hook
```
Find your device with the lspci command: ```lspci -nnk```

GPU_ID="0000:67:00.0"
AUDIO_ID="0000:67:00.1"


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
Run some tests on the VM, shut down, restart and validate the
device shows up afterwards. This script will essentially clear
out this device and release it back to the host. No hard reboot
should be necessary.
