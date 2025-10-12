#!/bin/bash -e
################################################################################
##  File:  install-mssql-tools.sh
##  Desc:  Install MS SQL Server client tools (https://docs.microsoft.com/en-us/sql/linux/sql-server-linux-setup-tools?view=sql-server-2017)
################################################################################
# Source the helpers for use with the script
source $HELPER_SCRIPTS/install.sh

if [[ "$ARCH" == "ppc64le" || "$ARCH" == "s390x" ]]; then 
    # Placeholder for ARCH-specific logic
    echo "No actions defined for $ARCH architecture."
else
    export ACCEPT_EULA=Y

    update_dpkgs
    install_dpkgs mssql-tools unixodbc-dev
    apt-get -f install
    ln -s /opt/mssql-tools/bin/* /usr/local/bin/
fi


