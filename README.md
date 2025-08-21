# Proxmox PCI Device Reset for VMs #

![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg)![GitHub commit activity](https://img.shields.io/github/commit-activity/t/meabert/Proxmox-VM-GPU-PCI-Release-Hookscript)![GitHub Issues or Pull Requests](https://img.shields.io/github/issues/meabert/Proxmox-VM-GPU-PCI-Release-Hookscript)

> [!TIP]
> Does your GPU or HBA keep disappearing when you reboot a VM in Proxmox?
> Will the device not comeback unless you `reboot` the host?
>
> This script might be able to help!

## Scope of this repo ##

Eliminate the need for reboots when PCI devices go missing on VM host
platforms - this generally occurs after an unexpected update or when
an unplanned restart is triggered.

- [x] Create shell script
- [x] Integrate with Proxmox hookscript logic
- [x] Basic testing
- [ ] Extensive testing (more device types)
- [ ] Environment testing (cluster, HA)
- [ ] Expand script to process unlimited devices

> [!WARNING]
> The cases below are not exhaustive, these are simply provided for issue
> context - any experienced operator should be able to connect other symptoms
> to these cases using Root Cause Analysis (RCA)

### Case Symptoms ###

**Local LLM** 

If an LLM is either extremely slow or has stopped responding completely 
validate GPU presence with the manuafacturer monitoring tool `nvidia-smi`,
`intel_gpu_top` or `amdgpu_top` if the device cannot be found or the command
gives errors there's a good chance the device was not properly returned to the
host. This is an ideal candidate for hook testing.

**TrueNAS** 

If some or all ZFS disks show disconnected (In the red - don't panic and don't
export any dataset!) Check if the HBA is visible with the manufacturer 
monitoring tool - these are already included with TrueNAS - change directories
to `cd /usr/local/sbin` or you can run them by executing `sudo` then the 
command. Depending on your card manufacturer some of the utilities include 
LSI -`sas3flash`, `sas2flash`, `sas2ircu`, `sas3ircu`, Broadcomm - `storcli`,
`storcli2` if the device cannot be found or the command is returning errors on
all or even some of the drives theres a good chance the device was not properly
returned to the host. This is an ideal candidate for hook testing.

### Impacted devices ###

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

Export the PCI/GPU device ID ```export GPU_ID="0000:67:00.0``` and pay close attention as some
devices have a sub-device ID such as the audio channel of a GPU ```AUDIO_ID="0000:67:00.1```
if you do not have a secondary don't export `$AUDIO_ID`.

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
