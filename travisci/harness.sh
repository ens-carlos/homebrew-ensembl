#!/bin/bash

set -euo pipefail


# Enable Ctrl+C if run interactively
test -t 1 && USE_TTY="-t"

git fetch origin master
COMMIT_RANGE=${TRAVIS_COMMIT_RANGE:-origin/master..$TRAVIS_BRANCH}
echo "Testing changed files in $COMMIT_RANGE"

# Test each changed file independently
for filename in $(git diff --name-only "$COMMIT_RANGE" | grep '\.rb$')
do
    # Notes:
    # - Mount the whole tap to use the new version of each formula
    # - Don't upgrade the formulae already installed as this image is expected to be updated regularly
    docker run ${USE_TTY:-} -i \
               -v "$PWD:/home/linuxbrew/.linuxbrew/Homebrew/Library/Taps/ensembl/homebrew-ensembl" \
               --env HOMEBREW_NO_AUTO_UPDATE=1 \
               muffato/ensembl-basic-dependencies-linuxbrew \
               brew install --build-from-source "ensembl/ensembl/$(basename "${filename%.rb}")"
               #/bin/bash
done

