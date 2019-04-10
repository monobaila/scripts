#!/bin/bash
#
# Check given version of terraform is installed, if not download and
# verify signed hash of binary.

set -e
set -u


#
# Constants
#

VER="0.11.13"
TMPDIR=$(mktemp -d)
BASE_URI="https://releases.hashicorp.com/terraform/${VER}"
CHECKSUM_FILE="terraform_${VER}_SHA256SUMS"
ZIP_FILE="terraform_${VER}_linux_amd64.zip"
FILES="${ZIP_FILE} ${CHECKSUM_FILE} ${CHECKSUM_FILE}.sig"
BIN="/usr/local/bin/terraform"


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
if [[ -f $BIN ]]; then
  INSTALLED_VER=$(terraform -version | awk -Fv '{print $2}' | head -1)
  if [[ $INSTALLED_VER == $VER ]]; then
    echo "... $VER already installed."
    exit 0
  fi
fi

trap "cleanup" SIGTERM SIGINT ERR EXIT

cd "$TMPDIR"

for file in $FILES; do
  wget "${BASE_URI}/${file}"
done

gpg --verify "${CHECKSUM_FILE}.sig"

grep "$(sha256sum ${ZIP_FILE})" ${CHECKSUM_FILE}

unzip "${ZIP_FILE}"

sudo mv terraform "${BIN}"

terraform -version

echo -e "\n$(tput setaf 2)... Successfuly installed terraform ${VER}. SHA256"\
        "on zip file is correct and signature of SHA256 is valid.$(tput sgr0)"
