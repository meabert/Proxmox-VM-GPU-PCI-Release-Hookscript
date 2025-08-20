#!/bin/bash
# Hookscript for releasing GPU passthrough devices on VM shutdown/reboot
# Drop this in /etc/pve/hooks/ or /etc/pve/local/ and attach via hookscript:

# Replace with your actual PCI IDs
GPU_ID="0000:42:00.0"
AUDIO_ID="0000:42:00.1"

log() {
	echo "[GPU-HOOK] $1"
}

release_device() {
	local DEV=$1
	if [[ -e "/sys/bus/pci/devices/${DEV}/remove" ]]; then
		echo 1 >"/sys/bus/pci/devices/${DEV}/remove"
		log "Removed ${DEV} from PCI bus"
	else
		log "Device ${DEV} not found for removal"
	fi
}

rescan_device() {
	local DEV=$1
	if [[ -e "/sys/bus/pci/devices/${DEV}/rescan" ]]; then
		echo 1 >"/sys/bus/pci/devices/${DEV}/rescan"
		log "Rescanned ${DEV}"
	else
		log "Device ${DEV} not found for rescan"
	fi
}

case "$2" in
pre-stop)
	log "VM $1 is stopping — releasing GPU..."
	release_device "${GPU_ID}"
	release_device "${AUDIO_ID}"
	;;
post-stop)
	log "VM $1 has stopped — rescanning GPU..."
	rescan_device "${GPU_ID}"
	rescan_device "${AUDIO_ID}"
	;;
*)
	log "Hook triggered for VM $1 with phase '$2' — no action taken."
	;;
esac
