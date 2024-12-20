#!/bin/bash -e
################################################################################
##  File:  install-heroku.sh
##  Desc:  Install Heroku CLI. Based on instructions found here: https://devcenter.heroku.com/articles/heroku-cli
################################################################################
set -x
if [ "$ARCH" = "ppc64le" ] ; then 
    #
    #
elif [ "$ARCH" = "s390x" ]; then
    #
    #
else
    REPO_URL="https://cli-assets.heroku.com/channels/stable/apt"
    GPG_KEY="/usr/share/keyrings/heroku.gpg"
    REPO_PATH="/etc/apt/sources.list.d/heroku.list"

    # add heroku repository to apt
    curl -fsSL "${REPO_URL}/release.key" | gpg --dearmor -o $GPG_KEY
    echo "deb [trusted=yes] $REPO_URL ./" > $REPO_PATH

    # install heroku
    apt-get update
    apt-get install heroku

    # remove heroku's apt repository
    rm $REPO_PATH
    rm $GPG_KEY
fi
