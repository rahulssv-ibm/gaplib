#!/bin/bash -e
################################################################################
##  File:  install-mssql-tools.sh
##  Desc:  Install MS SQL Server client tools (https://docs.microsoft.com/en-us/sql/linux/sql-server-linux-setup-tools?view=sql-server-2017)
################################################################################
set -x
if [ "$ARCH" = "ppc64le" ] ; then 
    #
    #
elif [ "$ARCH" = "s390x" ]; then
    #
    #
else
    export ACCEPT_EULA=Y

    apt-get update
    apt-get install mssql-tools unixodbc-dev
    apt-get -f install
    ln -s /opt/mssql-tools/bin/* /usr/local/bin/
fi


