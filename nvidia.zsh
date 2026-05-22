# ============================
# NVIDIA Driver Health Check
# ============================
# Inspects whether the NVIDIA driver is correctly installed:
#   - GPU hardware is detected
#   - User-space driver (nvidia-smi) responds
#   - Required kernel modules are loaded
#   - DKMS status (when applicable)
#   - Secure Boot / UEFI signature of the kernel modules
#   - Current display session
# ============================

function _nvidia_print_header {
	local title=$1
	echo -e "${BLUE}${BOLD}=================================================================="
	echo -e "  $title"
	echo -e "==================================================================${RESET}"
}

function _nvidia_print_section {
	local title=$1
	echo ""
	echo -e "${BLUE}${BOLD}>>> $title${RESET}"
	echo -e "${BLUE}------------------------------------------------------------------${RESET}"
}

function _nvidia_ok   { echo -e "  ${GREEN}[ OK ]${RESET}   $1"; }
function _nvidia_fail { echo -e "  ${RED}[FAIL]${RESET}   $1"; }
function _nvidia_warn { echo -e "  ${YELLOW}[WARN]${RESET}   $1"; }
function _nvidia_info { echo -e "  ${BLUE}[INFO]${RESET}   $1"; }

function _nvidia_print_lines {
	local prefix="         ${BLUE}->${RESET} "
	while IFS= read -r line; do
		[[ -z "$line" ]] && continue
		echo -e "${prefix}${line}"
	done
}

function _nvidia_guard {
	local kernel_name
	kernel_name=$(uname -s 2>/dev/null)
	if [[ "$kernel_name" != "Linux" ]]; then
		echo -e "${RED}${BOLD}nvidia-check aborted: this command only runs on Linux.${RESET}"
		echo -e "${YELLOW}Detected operating system: ${kernel_name:-unknown}${RESET}"
		return 1
	fi

	if ! command -v lspci >/dev/null 2>&1; then
		echo -e "${RED}${BOLD}nvidia-check aborted: 'lspci' is required to detect the GPU.${RESET}"
		echo -e "${YELLOW}Install the 'pciutils' package and try again.${RESET}"
		return 1
	fi

	local gpus
	gpus=$(lspci -nn | grep -Ei 'vga|3d|display')
	if [[ -z "$gpus" ]]; then
		echo -e "${RED}${BOLD}nvidia-check aborted: no GPU was found on the PCI bus.${RESET}"
		return 1
	fi

	if ! echo "$gpus" | grep -qi nvidia; then
		echo -e "${RED}${BOLD}nvidia-check aborted: no NVIDIA GPU detected.${RESET}"
		echo -e "${YELLOW}This command is intended only for systems with an NVIDIA GPU.${RESET}"
		echo -e "${YELLOW}Detected GPU(s):${RESET}"
		while IFS= read -r line; do
			echo -e "  ${BLUE}->${RESET} ${line}"
		done <<< "$gpus"
		return 1
	fi

	return 0
}

function nvidia-check {
	_nvidia_guard || return 1

	local -i errors=0
	local -i warnings=0

	_nvidia_print_header "NVIDIA DRIVER HEALTH CHECK"

	_nvidia_print_section "[1/6] HARDWARE DETECTION (lspci)"
	local gpu_info
	gpu_info=$(lspci -nn | grep -Ei 'vga|3d|display' | grep -i nvidia)
	_nvidia_ok "NVIDIA GPU(s) detected on the PCI bus:"
	echo "$gpu_info" | _nvidia_print_lines

	_nvidia_print_section "[2/6] USER-SPACE DRIVER (nvidia-smi)"
	if command -v nvidia-smi >/dev/null 2>&1; then
		_nvidia_ok "nvidia-smi found at: $(command -v nvidia-smi)"
		local smi_output
		if smi_output=$(nvidia-smi --query-gpu=name,driver_version,vbios_version --format=csv,noheader 2>&1); then
			_nvidia_ok "Driver is responding correctly. GPU(s) details:"
			echo "$smi_output" | _nvidia_print_lines
		else
			_nvidia_fail "nvidia-smi could not query the GPU - driver is installed but not working."
			echo "$smi_output" | _nvidia_print_lines
			_nvidia_info "Common causes: kernel/module version mismatch, modules not loaded, Secure Boot blocking unsigned modules."
			(( errors++ ))
		fi
	else
		_nvidia_fail "nvidia-smi not found - the proprietary driver is most likely NOT installed."
		_nvidia_info "Arch:           sudo pacman -S nvidia        (or nvidia-dkms / nvidia-open-dkms)"
		_nvidia_info "Debian/Ubuntu:  sudo apt install nvidia-driver-<version>"
		_nvidia_info "Fedora:         sudo dnf install akmod-nvidia"
		(( errors++ ))
	fi

	_nvidia_print_section "[3/6] KERNEL MODULES (lsmod)"
	local required_modules=("nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm")
	local loaded_mods
	loaded_mods=$(lsmod 2>/dev/null | awk '{print $1}')
	for mod in "${required_modules[@]}"; do
		if echo "$loaded_mods" | grep -qx "$mod"; then
			_nvidia_ok "Module loaded in the running kernel: ${BOLD}${mod}${RESET}"
		else
			_nvidia_fail "Module NOT loaded: ${BOLD}${mod}${RESET}"
			(( errors++ ))
		fi
	done
	_nvidia_info "Running kernel: ${BOLD}$(uname -r)${RESET}"

	if echo "$loaded_mods" | grep -qx "nouveau"; then
		_nvidia_warn "The open-source 'nouveau' driver is loaded - it usually conflicts with the proprietary NVIDIA driver."
		(( warnings++ ))
	fi

	_nvidia_print_section "[4/6] DKMS STATUS"
	if command -v dkms >/dev/null 2>&1; then
		local dkms_output
		dkms_output=$(dkms status 2>/dev/null | grep -i nvidia)
		if [[ -n "$dkms_output" ]]; then
			_nvidia_ok "NVIDIA modules managed by DKMS:"
			echo "$dkms_output" | _nvidia_print_lines
		else
			_nvidia_info "No NVIDIA modules registered in DKMS (normal when using prebuilt modules, e.g. the regular 'nvidia' package on Arch)."
		fi
	else
		_nvidia_info "dkms not installed - skipping (not every setup uses DKMS)."
	fi

	_nvidia_print_section "[5/6] SECURE BOOT / UEFI MODULE SIGNATURE"
	local sb_state="unknown"
	if command -v mokutil >/dev/null 2>&1; then
		local mok_output
		mok_output=$(mokutil --sb-state 2>&1)
		echo "$mok_output" | _nvidia_print_lines
		if echo "$mok_output" | grep -qi "SecureBoot enabled"; then
			sb_state="enabled"
		elif echo "$mok_output" | grep -qi "SecureBoot disabled"; then
			sb_state="disabled"
		fi
	else
		_nvidia_warn "mokutil not installed - cannot detect Secure Boot state (install 'mokutil')."
		(( warnings++ ))
	fi

	case "$sb_state" in
		disabled)
			_nvidia_info "Secure Boot is ${BOLD}DISABLED${RESET} - kernel modules do NOT need to be signed."
			;;
		enabled)
			_nvidia_info "Secure Boot is ${BOLD}ENABLED${RESET} - kernel modules MUST be signed and trusted by UEFI."

			local kernel_dir="/lib/modules/$(uname -r)"
			local nvidia_ko=""
			if [[ -d "$kernel_dir" ]]; then
				nvidia_ko=$(find "$kernel_dir" -type f \( -name 'nvidia.ko' -o -name 'nvidia.ko.xz' -o -name 'nvidia.ko.zst' \) 2>/dev/null | head -n1)
			fi

			if [[ -n "$nvidia_ko" ]]; then
				_nvidia_info "Inspecting module: ${nvidia_ko}"
				if command -v modinfo >/dev/null 2>&1; then
					local sig_info signer
					sig_info=$(modinfo "$nvidia_ko" 2>/dev/null | grep -E '^(signer|sig_id|sig_key|sig_hashalgo):')
					signer=$(modinfo "$nvidia_ko" 2>/dev/null | awk -F: '/^signer:/{sub(/^ +/, "", $2); print $2}')
					if [[ -n "$sig_info" ]]; then
						_nvidia_ok "nvidia.ko is signed."
						echo "$sig_info" | _nvidia_print_lines
						if [[ -n "$signer" ]]; then
							_nvidia_info "Signer: ${BOLD}${signer}${RESET}"
						fi
					else
						_nvidia_fail "nvidia.ko is NOT signed - it will be REJECTED by the kernel with Secure Boot on."
						_nvidia_info "Sign it locally (kmodsign / sign-file) and enroll the key with 'mokutil --import <cert.der>'."
						(( errors++ ))
					fi
				else
					_nvidia_warn "modinfo not available - cannot verify module signature."
					(( warnings++ ))
				fi
			else
				_nvidia_warn "Could not locate nvidia.ko under ${kernel_dir} - module may not be installed for this kernel."
				(( warnings++ ))
			fi

			if command -v mokutil >/dev/null 2>&1; then
				echo ""
				_nvidia_info "Enrolled MOK keys (trusted by UEFI for module signing):"
				local mok_keys
				mok_keys=$(mokutil --list-enrolled 2>/dev/null | grep -E 'Subject:|Issuer:|SHA1 Fingerprint')
				if [[ -n "$mok_keys" ]]; then
					echo "$mok_keys" | _nvidia_print_lines
				else
					_nvidia_warn "No MOK keys enrolled - locally-signed NVIDIA modules will NOT be trusted by UEFI."
					(( warnings++ ))
				fi
			fi
			;;
		*)
			_nvidia_warn "Could not determine Secure Boot state (mokutil missing or no UEFI variables exposed)."
			(( warnings++ ))
			;;
	esac

	_nvidia_print_section "[6/6] DISPLAY SESSION"
	if [[ -n "$XDG_SESSION_TYPE" ]]; then
		_nvidia_info "Current session type: ${BOLD}${XDG_SESSION_TYPE}${RESET}"
	else
		_nvidia_info "XDG_SESSION_TYPE not set (TTY/SSH session, no graphical session)."
	fi
	if [[ -n "$XDG_CURRENT_DESKTOP" ]]; then
		_nvidia_info "Current desktop:      ${BOLD}${XDG_CURRENT_DESKTOP}${RESET}"
	fi

	echo ""
	_nvidia_print_header "SUMMARY"
	if (( errors == 0 && warnings == 0 )); then
		echo -e "  ${GREEN}${BOLD}All checks passed - NVIDIA driver looks healthy.${RESET}"
	elif (( errors == 0 )); then
		echo -e "  ${YELLOW}${BOLD}NVIDIA driver works, but ${warnings} warning(s) were reported.${RESET}"
		echo -e "  ${YELLOW}Review the [WARN] entries above.${RESET}"
	else
		echo -e "  ${RED}${BOLD}${errors} error(s) and ${warnings} warning(s) detected.${RESET}"
		echo -e "  ${YELLOW}Review the [FAIL] / [WARN] entries above to fix the installation.${RESET}"
	fi
	echo ""

	return $errors
}
