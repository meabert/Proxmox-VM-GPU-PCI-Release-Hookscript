#!/bin/bash
# A general-purpose hookscript for releasing and rescanning PCI devices.
# Drop this in /etc/pve/hooks/.

log() {
    echo "[PCI-HOOK] $1"
}

# The VM ID is the first argument, the hook phase is the second.
VMID=$1
HOOK_PHASE=$2

# The PCI IDs to be managed are passed as additional arguments from the VM config.
# For example, in /etc/pve/qemu-server/VMID.conf, you would add:
# hookscript: local:pbx-hook.sh -pciid 0000:42:00.0 -pciid 0000:42:00.1
# The '-pciid' is a custom flag.
declare -a PCI_DEVICES=()
while [[ "$#" -gt 0 ]]; do
    case "$1" in
        -pciid)
            PCI_DEVICES+=("$2")
            shift
            ;;
        *)
            ;;
    esac
    shift
done

# Check if any PCI devices were provided.
if [ ${#PCI_DEVICES[@]} -eq 0 ]; then
    log "No PCI IDs provided. Exiting."
    exit 0
fi

# Function to remove a device from the PCI bus.
remove_device() {
    local DEV=$1
    if [[ -e "/sys/bus/pci/devices/${DEV}/remove" ]]; then
        echo 1 >"/sys/bus/pci/devices/${DEV}/remove"
        log "Removed ${DEV} from PCI bus."
    else
        log "Device ${DEV} not found for removal."
    fi
}

# Function to rescan the entire PCI bus.
rescan_bus() {
    log "Rescanning PCI bus..."
    echo 1 > "/sys/bus/pci/rescan"
    log "PCI bus rescan complete."
}

# Main case statement to handle hook phases.
case "$HOOK_PHASE" in
    pre-stop)
        log "VM $VMID is stopping. Releasing PCI devices..."
        for dev in "${PCI_DEVICES[@]}"; do
            remove_device "$dev"
        done
        ;;
    post-stop)
        log "VM $VMID has stopped. Rescanning PCI bus..."
        rescan_bus
        ;;
    *)
        log "Hook triggered for VM $VMID with phase '$HOOK_PHASE'. No action taken."
        ;;
esac
