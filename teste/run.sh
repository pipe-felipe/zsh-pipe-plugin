#!/usr/bin/env bash
#
# Build and run per-distro Podman containers to exercise zsh-pipe-plugin.
# The repo is bind-mounted read-only into every container, so editing a
# .zsh file and re-running does NOT require rebuilding the image (images
# only install OS packages, never copy plugin code).
#
# Usage:
#   teste/run.sh <distro>            interactive zsh shell, plugin auto-loaded,
#                                      REAL package manager on PATH
#   teste/run.sh <distro> test        non-interactive: sources the plugin,
#                                      checks handler selection, then actually
#                                      calls update()/clean() with MOCKED
#                                      package-manager binaries on PATH (see
#                                      mocks/bin/) and asserts what got called
#   teste/run.sh <distro> build       just (re)build the image
#   teste/run.sh all                  `test` every distro, print summary
#
# <distro> is one of: archlinux fedora ubuntu debian suse neon bluefin
#
# `shell` is for manual, real runs: update/clean there hit the real
# network/package manager of that container (expected and safe, the
# container is disposable). `test`/`all` never touch the network - they
# swap in fake pacman/apt/dnf/... binaries so the exact same call graph
# runs, deterministically and in milliseconds.

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

# Primary command each handler's update()/clean() is expected to invoke -
# asserted against the mocked-binary call log by `test`/`all` (see
# mocks/bin/ and smoke-test.zsh).
declare -A EXPECTED_UPDATE_CMD=(
	[archlinux]=pacman
	[fedora]=dnf
	[ubuntu]=apt
	[debian]=apt
	[suse]=zypper
	[neon]=pkcon
	[bluefin]=ujust
)
declare -A EXPECTED_CLEAN_CMD=(
	[archlinux]=pacman
	[fedora]=dnf
	[ubuntu]=apt
	[debian]=apt
	[suse]=zypper
	[neon]=apt
	[bluefin]=ujust
)

# "1" for handlers that manage snap/brew/flatpak themselves and must skip
# the shared extras steps. Nobody does today - `ujust update`/
# `ujust clean-system` only cover Bluefin's immutable base system, so it
# still goes through the shared steps like everyone else - but the
# assertion stays wired up as a regression guard for whenever a handler
# does need to opt out.
declare -A MANAGES_EXTRAS=(
	[archlinux]=""
	[fedora]=""
	[ubuntu]=""
	[debian]=""
	[suse]=""
	[neon]=""
	[bluefin]=""
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
		-v "${SCRIPT_DIR}/mocks/bin:/opt/mock-bin:ro,Z" \
		-e "PIPE_PLUGIN=/opt/zsh-pipe-plugin" \
		-e "EXPECTED_HANDLER=${EXPECTED_HANDLER[$distro]}" \
		-e "EXPECTED_UPDATE_CMD=${EXPECTED_UPDATE_CMD[$distro]}" \
		-e "EXPECTED_CLEAN_CMD=${EXPECTED_CLEAN_CMD[$distro]}" \
		-e "MANAGES_EXTRAS=${MANAGES_EXTRAS[$distro]}" \
		-e "MOCK_BIN=/opt/mock-bin" \
		-e "MOCK_LOG=/tmp/mock-calls.log" \
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
