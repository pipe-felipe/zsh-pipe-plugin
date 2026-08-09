#!/usr/bin/env bash
#
# Build and run per-distro Podman containers to exercise zsh-pipe-plugin.
# The repo is bind-mounted read-only into every container, so editing a
# .zsh file and re-running does NOT require rebuilding the image (images
# only install OS packages, never copy plugin code).
#
# Usage:
#   teste/run.sh <distro>            interactive zsh shell, plugin auto-loaded
#   teste/run.sh <distro> test        non-interactive smoke test (handler
#                                      selection + function checks, no real
#                                      package manager calls)
#   teste/run.sh <distro> build       just (re)build the image
#   teste/run.sh all                  smoke test every distro, print summary
#
# <distro> is one of: archlinux fedora ubuntu debian suse neon bluefin
#
# Real `update`/`clean` can be run manually from inside the interactive
# shell (they will hit the real network/package manager of that container -
# that's expected and safe, the container is disposable).

set -euo pipefail

# Some terminals (e.g. an editor's embedded shell running inside its own
# Flatpak sandbox) leak an LD_LIBRARY_PATH pointing at their bundled libs.
# podman's conmon links against the system glib and crashes with a symbol
# lookup error if an older glib from one of those paths shadows it. podman
# itself doesn't need this variable, so drop it defensively.
unset LD_LIBRARY_PATH

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
IMAGE_PREFIX="zsh-pipe-test"

DISTROS=(archlinux fedora ubuntu debian suse neon bluefin)

declare -A EXPECTED_HANDLER=(
	[archlinux]=archlinux
	[fedora]=fedora
	[ubuntu]=ubuntu
	[debian]=debian
	[suse]=suse
	[neon]=neon
	[bluefin]=bluefin
)

usage() {
	echo "Usage: $0 <$(IFS='|'; echo "${DISTROS[*]}")|all> [shell|test|build]" >&2
	exit 1
}

is_known_distro() {
	local d=$1 known
	for known in "${DISTROS[@]}"; do
		[[ "$d" == "$known" ]] && return 0
	done
	return 1
}

build() {
	local distro=$1
	podman build \
		-f "$SCRIPT_DIR/containers/${distro}.Containerfile" \
		-t "${IMAGE_PREFIX}:${distro}" \
		"$SCRIPT_DIR"
}

run_shell() {
	local distro=$1
	build "$distro"
	echo "==> Interactive zsh on ${distro} (plugin mounted read-only from ${REPO_ROOT})"
	podman run --rm -it \
		-v "${REPO_ROOT}:/opt/zsh-pipe-plugin:ro,Z" \
		"${IMAGE_PREFIX}:${distro}"
}

run_test() {
	local distro=$1
	build "$distro" >/dev/null
	podman run --rm \
		-v "${REPO_ROOT}:/opt/zsh-pipe-plugin:ro,Z" \
		-e "PIPE_PLUGIN=/opt/zsh-pipe-plugin" \
		-e "EXPECTED_HANDLER=${EXPECTED_HANDLER[$distro]}" \
		"${IMAGE_PREFIX}:${distro}" \
		zsh /opt/zsh-pipe-plugin/teste/smoke-test.zsh
}

[[ $# -ge 1 ]] || usage
target=$1
mode=${2:-shell}

if [[ "$target" == "all" ]]; then
	failed=()
	for d in "${DISTROS[@]}"; do
		echo "==================== ${d} ===================="
		if ! run_test "$d"; then
			failed+=("$d")
		fi
		echo
	done
	if (( ${#failed[@]} > 0 )); then
		echo "FAILED: ${failed[*]}" >&2
		exit 1
	fi
	echo "All distros passed."
	exit 0
fi

is_known_distro "$target" || usage

case "$mode" in
	shell) run_shell "$target" ;;
	test) run_test "$target" ;;
	build) build "$target" ;;
	*) usage ;;
esac
