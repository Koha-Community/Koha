$DBversion = 'XXX';  # will be replaced by the RM
if ( CheckVersion($DBversion) ) {
    print "-    Upgrading (Bug 13707). Adding and recalculating datereceived-column for biblioitems- and items-tables. This may take a while. Sorry :(\n";
    #Check if this upgrade has already been deployed, and skip this.
    my $sth_desc_biblioitems = $dbh->prepare("DESC biblioitems");
    $sth_desc_biblioitems->execute();
    my $desc_biblioitems = $sth_desc_biblioitems->fetchall_hashref('Field');
    if ($desc_biblioitems->{datereceived}) {
        print "-    It looks like this DB change has already been applied. If you want to rebuild datereceived-columns for items and biblioitems, run the following command:\n".
              "-    ALTER TABLE biblioitems DROP column datereceived; ALTER TABLE deletedbiblioitems DROP column datereceived; ALTER TABLE items DROP column datereceived; ALTER TABLE deleteditems DROP column datereceived;\n".
              "-    And rerun this updatedatabase.pl subroutine in a separate Perl-script.\n";
    }
    else {

        #Datereceived is the aqorders.datereceived, so we can copy it from there. For alive and deleted items and biblioitems.
        #If no aqorders.datereceived is present, we use the dateaccessioned.
        #it is important to UPDTE also deleted items/biblioitems due to statistical consistency.

        ###Items UPDATE here                   ###
        $dbh->do("ALTER TABLE items ADD COLUMN datereceived timestamp NULL");
        $dbh->do("ALTER TABLE deleteditems ADD COLUMN datereceived timestamp NULL");
        $dbh->do("UPDATE items i LEFT JOIN aqorders_items ai ON i.itemnumber = ai.itemnumber LEFT JOIN aqorders ao ON ai.ordernumber = ao.ordernumber SET i.datereceived = IF(ai.ordernumber IS NOT NULL, ao.datereceived, i.dateaccessioned);");
        $dbh->do("UPDATE deleteditems i LEFT JOIN aqorders_items ai ON i.itemnumber = ai.itemnumber LEFT JOIN aqorders ao ON ai.ordernumber = ao.ordernumber SET i.datereceived = IF(ai.ordernumber IS NOT NULL, ao.datereceived, i.dateaccessioned);");

        ###Biblioitems UPDATE here              ###
        $dbh->do("ALTER TABLE biblioitems ADD COLUMN datereceived timestamp NULL");
        $dbh->do("ALTER TABLE deletedbiblioitems ADD COLUMN datereceived timestamp NULL");

        #Set the biblioitems.datereceived to the smallest of items vs deleteditems or NULL
        $dbh->do("UPDATE biblioitems bi
                        LEFT JOIN items i ON i.biblionumber = bi.biblionumber LEFT JOIN deleteditems di ON di.biblionumber = bi.biblionumber
                  SET bi.datereceived =
                        IF(IFNULL(i.datereceived,'9999-12-31') < IFNULL(di.datereceived,'9999-12-31'), i.datereceived, di.datereceived);");
        #UPDATE deletedbiblioitems as well.
        $dbh->do("UPDATE biblioitems bi
                        LEFT JOIN items i ON i.biblionumber = bi.biblionumber LEFT JOIN deleteditems di ON di.biblionumber = bi.biblionumber
                  SET bi.datereceived =
                        IF(IFNULL(i.datereceived,'9999-12-31') < IFNULL(di.datereceived,'9999-12-31'), i.datereceived, di.datereceived);");
    }
    print "Upgrade to $DBversion done (Bug 13707 - Add datereceived-column and and search index, for genuinely knowing the real Biblios datereceived.)\n";
    SetVersion ($DBversion);
}
