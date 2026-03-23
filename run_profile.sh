#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
DEFAULT_INVENTORY="${SCRIPT_DIR}/inventory.ini"

usage() {
  cat <<'EOF'
Usage: ./run_profile.sh <profile> [ansible-playbook options]

Profiles:
  minimal
  desktop
  ml

Examples:
  ./run_profile.sh minimal -i inventory.ini -K
  ./run_profile.sh desktop -i inventory.ini -K
  ./run_profile.sh ml -i inventory.ini -K
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" || $# -eq 0 ]]; then
  usage
  exit 0
fi

PROFILE="$1"
shift

PROFILE_FILE="${SCRIPT_DIR}/group_vars/profiles/${PROFILE}.yml"
HAS_INVENTORY_ARG=false

if [[ ! -f "$PROFILE_FILE" ]]; then
  echo "Error: unknown profile '${PROFILE}'." >&2
  usage >&2
  exit 1
fi

if ! command -v ansible-playbook >/dev/null 2>&1; then
  echo "Error: ansible-playbook not found." >&2
  exit 1
fi

for arg in "$@"; do
  case "$arg" in
    -i|--inventory|--inventory=*)
      HAS_INVENTORY_ARG=true
      ;;
  esac
done

if [[ "$HAS_INVENTORY_ARG" == false && ! -f "$DEFAULT_INVENTORY" ]]; then
  echo "Error: ${DEFAULT_INVENTORY} not found." >&2
  echo "Copy inventory/example.ini to inventory.ini or pass -i <inventory>." >&2
  exit 1
fi

set -x
if [[ "$HAS_INVENTORY_ARG" == true ]]; then
  ansible-playbook "${SCRIPT_DIR}/site.yml" -e "@${PROFILE_FILE}" "$@"
else
  ansible-playbook -i "$DEFAULT_INVENTORY" "${SCRIPT_DIR}/site.yml" -e "@${PROFILE_FILE}" "$@"
fi
set +x
