#!/bin/bash

# Store the full command to wrap
wrapped_cmd=("$@")
wrapped_pid=""

# SIGTERM handler
on_sigterm() {
  echo "[sigwrap] Received SIGTERM. Sending SIGKILL to child ($wrapped_pid)..."
  if [[ -n "$wrapped_pid" ]]; then
    kill -9 "$wrapped_pid" 2>/dev/null
  fi
  exit 1
}

# Trap SIGTERM in the wrapper
trap on_sigterm SIGTERM

# Run the actual command in the background
"${wrapped_cmd[@]}" &
wrapped_pid=$!

# Forward SIGINT too (optional)
trap "kill -INT $wrapped_pid 2>/dev/null" SIGINT

# Wait for the command to finish
wait $wrapped_pid
exit_code=$?

# Exit with child’s exit code if not terminated by signal
exit $exit_code

