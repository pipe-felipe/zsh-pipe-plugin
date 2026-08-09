#!/usr/bin/env zsh
#
# Non-interactive smoke test run inside the Podman containers (see run.sh).
# Sources the plugin exactly like a real shell would, checks handler
# selection, then actually CALLS `update` and `clean` with the mocked
# package-manager binaries (see mocks/bin/) prepended to PATH - so the full
# call graph runs for real, not just the handler-selection logic. Nothing
# here touches a real network or a real package manager.
#
# Env vars (set by run.sh):
#   PIPE_PLUGIN          path to the plugin checkout
#   EXPECTED_HANDLER     handler name expected to win on this distro
#   EXPECTED_UPDATE_CMD  primary command `update` is expected to invoke
#                        (e.g. pacman, apt, dnf, zypper, pkcon, ujust)
#   EXPECTED_CLEAN_CMD   primary command `clean` is expected to invoke
#   MANAGES_EXTRAS       "1" when this handler is expected to skip the
#                        shared snap/brew/flatpak steps itself, unset/empty
#                        otherwise (currently every handler is empty here)
#   MOCK_BIN             directory of mocked binaries to prepend to PATH
#   MOCK_LOG             file the mocks append "<name> <args>" to

typeset -i failures=0

function pass { print -P "%F{green}[PASS]%f $1" }
function fail { print -P "%F{red}[FAIL]%f $1"; (( failures++ )) }

if [[ -z "${PIPE_PLUGIN:-}" ]]; then
	print -P "%F{red}PIPE_PLUGIN is not set%f"
	exit 1
fi

if source "${PIPE_PLUGIN}/zsh-pipe-plugin.plugin.zsh"; then
	pass "sourced zsh-pipe-plugin.plugin.zsh"
else
	fail "sourcing zsh-pipe-plugin.plugin.zsh"
	exit 1
fi

for fn in update clean dockerps nvidia-check install-zsh-plugin install-favorites update-this aur-update-all; do
	if (( $+functions[$fn] )); then
		pass "function '$fn' is defined"
	else
		fail "function '$fn' is missing"
	fi
done

typeset update_handler clean_handler
update_handler=$(_select_system_update_handler)
clean_handler=$(_select_system_clean_handler)

print -P "%F{blue}detected update handler:%f ${update_handler:-<none>}"
print -P "%F{blue}detected clean handler:%f  ${clean_handler:-<none>}"

if [[ -n "${EXPECTED_HANDLER:-}" ]]; then
	if [[ "$update_handler" == "$EXPECTED_HANDLER" ]]; then
		pass "update handler is '$EXPECTED_HANDLER'"
	else
		fail "update handler is '${update_handler:-<none>}', expected '$EXPECTED_HANDLER'"
	fi

	if [[ "$clean_handler" == "$EXPECTED_HANDLER" ]]; then
		pass "clean handler is '$EXPECTED_HANDLER'"
	else
		fail "clean handler is '${clean_handler:-<none>}', expected '$EXPECTED_HANDLER'"
	fi
fi

# ---- actually run update()/clean() against the mocked binaries ----

if [[ -n "${MOCK_BIN:-}" ]]; then
	export PATH="${MOCK_BIN}:${PATH}"
	: >"${MOCK_LOG:=/tmp/mock-calls.log}"

	print -P "\n%F{blue}--- update() ---%f"
	if update; then
		pass "update() ran to completion"
	else
		fail "update() exited non-zero"
	fi

	print -P "\n%F{blue}--- clean() ---%f"
	if clean; then
		pass "clean() ran to completion"
	else
		fail "clean() exited non-zero"
	fi

	print -P "\n%F{blue}--- mock call log (${MOCK_LOG}) ---%f"
	cat "$MOCK_LOG"
	print ""

	if [[ -n "${EXPECTED_UPDATE_CMD:-}" ]]; then
		if grep -q "^${EXPECTED_UPDATE_CMD} " "$MOCK_LOG"; then
			pass "update() invoked '${EXPECTED_UPDATE_CMD}'"
		else
			fail "update() never invoked '${EXPECTED_UPDATE_CMD}'"
		fi
	fi

	if [[ -n "${EXPECTED_CLEAN_CMD:-}" ]]; then
		if grep -q "^${EXPECTED_CLEAN_CMD} " "$MOCK_LOG"; then
			pass "clean() invoked '${EXPECTED_CLEAN_CMD}'"
		else
			fail "clean() never invoked '${EXPECTED_CLEAN_CMD}'"
		fi
	fi

	if [[ "${MANAGES_EXTRAS:-}" == "1" ]]; then
		if grep -qE '^(snap|brew|flatpak) ' "$MOCK_LOG"; then
			fail "snap/brew/flatpak were called, but this handler claims to manage its own extras"
		else
			pass "snap/brew/flatpak were correctly skipped (handler manages its own extras)"
		fi
	else
		if grep -qE '^(snap|brew|flatpak) ' "$MOCK_LOG"; then
			pass "shared snap/brew/flatpak extras were invoked"
		else
			fail "shared snap/brew/flatpak extras were never invoked"
		fi
	fi
fi

if (( failures > 0 )); then
	print -P "%F{red}${failures} check(s) failed%f"
	exit 1
fi

print -P "%F{green}all checks passed%f"
exit 0
