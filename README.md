# Proxmox-VM-GPU-PCI-Release-Hookscript
In certain situations PCI/GPU devices are not properly removed from a VM when shutdown or restarted. Previous where a host system reboot was used, this hookscript aims to resolve this problem with no host reboot and instead integrates a hookscript during VM restarts and power cycles.

![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg)
