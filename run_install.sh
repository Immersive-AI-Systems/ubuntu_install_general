#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
DEFAULT_INVENTORY="${SCRIPT_DIR}/inventory.ini"
HAS_INVENTORY_ARG=false

usage() {
  cat <<'EOF'
Usage: ./run_install.sh [ansible-playbook options]

Examples:
  ./run_install.sh -i inventory.ini -K
  ./run_install.sh -i inventory.ini -K -e install_anaconda=true
  ./run_install.sh -i inventory.ini -K -e install_docker=true
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
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
  echo "Run ./init_remote_host.sh to create inventory.ini, or pass -i <inventory>." >&2
  exit 1
fi

set -x
if [[ "$HAS_INVENTORY_ARG" == true ]]; then
  ansible-playbook "${SCRIPT_DIR}/site.yml" "$@"
else
  ansible-playbook -i "$DEFAULT_INVENTORY" "${SCRIPT_DIR}/site.yml" "$@"
fi
set +x
