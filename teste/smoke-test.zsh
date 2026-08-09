#!/usr/bin/env zsh
#
# Non-interactive smoke test run inside the Podman containers (see run.sh).
# Sources the plugin exactly like a real shell would and checks that:
#   - it sources without errors
#   - the expected functions are defined
#   - the distro handler that "wins" matches $EXPECTED_HANDLER
#
# No package manager is actually invoked here, so this is safe to run
# repeatedly and needs no extra network access beyond what building the
# image already used.
#
# Env vars (set by run.sh):
#   PIPE_PLUGIN        path to the plugin checkout
#   EXPECTED_HANDLER   handler name expected to win on this distro (optional)

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

if (( failures > 0 )); then
	print -P "%F{red}${failures} check(s) failed%f"
	exit 1
fi

print -P "%F{green}all checks passed%f"
exit 0
