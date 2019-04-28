#!/bin/bash
#
# Check given version of youtube-dl is installed, if not download and
# verify signed hash of binary.
#
# Prerequisites:
#   You need to manually import and trust the signing key into your gpg keyring, this is not something
#   you want to automate! Careful validation is required.
#

set -e
set -u


#
# Constants
#

VER="2019.04.24"
TMPDIR=$(mktemp -d)
BASE_URI="https://github.com/ytdl-org/youtube-dl/releases/download/${VER}"
BIN_NAME="youtube-dl"
SIG_FILE="youtube-dl.sig"
FILES="${BIN_NAME} ${SIG_FILE}"
BIN_DEST="/usr/bin/${BIN_NAME}"


#
# FUNCTIONS
#

cleanup() {
  [[ -d $TMPDIR ]] && rm -rf "$TMPDIR"
}


#
# MAIN
#

# If we already have a binary check current version.
if [[ -f $BIN_DEST ]]; then
  INSTALLED_VER=$(youtube-dl --version)
  if [[ $INSTALLED_VER == $VER ]]; then
    echo "... ${VER} already installed."
    exit 0
  fi
fi

trap "cleanup" SIGTERM SIGINT ERR EXIT

cd "$TMPDIR"

for file in $FILES; do
  wget "${BASE_URI}/${file}"
done

gpg --verify "${SIG_FILE}"

sudo mv "$BIN_NAME" "$BIN_DEST"
sudo chmod +x ${BIN_DEST}

youtube-dl --version

echo -e "\n$(tput setaf 2)... Successfuly installed ${BIN_NAME} ${VER}."\
        "Signature verfified via gpg.$(tput sgr0)"
