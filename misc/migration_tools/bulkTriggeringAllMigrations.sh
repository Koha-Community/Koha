iam=${whoami}
if [ "$iam" != "koha" ]; then
        echo "You must be koha to run this script!"
        echo "Go play with your daddy!"
        exit 1
fi

perl bulkPatronImport.pl -file ~/kohamigration/patrons.migrateme > ~/kohamigration/patrons.log 2>&1


perl bulkmarcimport.pl -d -commit 1000 -file ~/kohamigration/biblios.migrateme -m MARCXML  -g 001 > ~/kohamigration/biblios.log 2>&1
perl bulkItemImport.pl ~/kohamigration/items.migrateme > ~/kohamigration/items.log 2>&1

perl bulkmarcimport.pl -d -commit 1000 -file ~/kohamigration/serialmothers.migrateme -m MARCXML  -g 001 > ~/kohamigration/serialmothers.log 2>&1
perl bulkmarcimport.pl -d -commit 1000 -file ~/kohamigration/serials.migrateme -m MARCXML  -g 001 > ~/kohamigration/serials.log 2>&1
perl bulkItemImport.pl ~/kohamigration/serialItems.migrateme > ~/kohamigration/serialItems.log 2>&1


perl bulkCheckoutImport.pl -file ~/kohamigration/checkouts.migrateme > ~/kohamigration/checkouts.log 2>&1
perl bulkFinesImport.pl -file ~/kohamigration/fines.migrateme > ~/kohamigration/fines.log 2>&1
perl bulkHoldsImport.pl ~/kohamigration/holds.migrateme > ~/kohamigration/holds.log 2&>1

#cronjob this to kohazebra ~/kohaclone/misc/migration_tools/rebuild_zebra.pl -b -a -r > /tmp/rebuild_zebra
#automatically cronjobbed ~/kohaclone/misc/cronjobs/fines.pl 2&> /tmp/fines
