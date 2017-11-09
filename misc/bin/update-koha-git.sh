#!/bin/bash

# update-koha-git.sh - Written by Johanna Räisä
# Copyright (C)2017 Koha-Suomi Oy

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.

#########################################
# Updates Koha code from Github repository
# Restarts plack-server
# Updates database if asked
# Updates translations
#########################################

KOHAPATH=__KOHA_PATH__
GITBRANCH=$1
PLACK=/etc/init.d/koha-plack-daemon
UPDATEDATABASE=$2
KOHACONF=__KOHA_CONF_DIR__/koha-conf.xml

### Should be run as koha user ###

if [ $GITBRANCH ]; then
	echo "Yay, found git branch: $GITBRANCH!"
	cd $KOHAPATH
	git checkout $GITBRANCH
	git fetch origin $GITBRANCH
	git reset --hard origin/$GITBRANCH
	echo "Restarting plack server"
	sudo $PLACK restart

else
	echo "Git branch is not defined, skipping!"
fi

if [ "$UPDATEDATABASE" = "update" ]; then
	echo "Updating database!"
	cd $KOHAPATH/installer/data/mysql/
	perl updatedatabase.pl
else
	echo "Skipping database update!"
fi

echo "Running translation scripts"
host=$(sed -n 's/[ \t]<hostname>\(.*\)<\/hostname>/\1/p' $KOHACONF)
userarea=$(sed -n '/<\/socket>/,/<\/user>$/p' $KOHACONF)
user=$(sed -n 's/[ \t]<user>\(.*\)<\/user>/\1/p' <<< "$userarea")
pass=$(sed -n 's/[ \t]<pass>\(.*\)<\/pass>/\1/p' $KOHACONF)
database=$(sed -n 's/[ \t]<database>\(.*\)<\/database>/\1/p' $KOHACONF)

cd $KOHAPATH/misc/translator/
for lang in $(mysql --host $host -u$user -p$pass $database -NBe "select value from systempreferences where variable = 'language';"); do 
IFS=',' read -ra ADDR <<< "$lang"
for i in "${ADDR[@]}"; do
    if ! [ "$i" = "en" ]; then
		echo "Updating translation $i!"
		perl translate update $i
		perl translate install $i
	fi
done; 
sleep .01 ; done