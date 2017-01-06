#!/bin/sh

set -e

ACME_SH_PATH="/root/.acme.sh/acme.sh"
HOME_PATH="/acme"

# if command starts with an option, prepend acme.sh --home /path/to/home
if [ "${1:0:1}" = '-' ]; then
	set -- "$ACME_SH_PATH" --home "$HOME_PATH" "$@"
fi

echo "Executing $@..."
exec "$@"