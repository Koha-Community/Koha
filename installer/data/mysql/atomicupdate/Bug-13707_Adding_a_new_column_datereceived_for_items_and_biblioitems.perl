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

    require C4::Biblio;
    #Check if it is safe to do the upgrade by looking if the default mappings have alredy been taken.
    my $sth3 = $dbh->prepare("SELECT 1 FROM marc_subfield_structure WHERE (tagfield = '942' AND tagsubfield = '1') OR (tagfield = '952' AND tagsubfield = 'R')");
    $sth3->execute();
    my $mappingUsed = $sth3->fetchall_arrayref();
    $sth3->finish();
    if (@$mappingUsed > 0) {
        print "Upgrade to $DBversion failed (Bug 13707 - Adding a new column datereceived for items and biblioitems. New sortable Zebra index! ). The default \"Koha to MARC mappings\" for biblioitems.datereceived are already taken. You must manually map biblioitems.datereceived to a MARC framework to enable searching by datereceived. You can see the subroutine inside this upgrade clause on how to do that.\n";
    }
    else {
        my $doTheDirtyDeed = sub {
            print "Upgrading Bug 13707, mapping biblioitems.datereceived to MARC 954\$1 and mapping items.datereceived to 952\$R. Then putting biblioitems.datereceived to all MARC Records. This will take several hours.\n";

            my $sth = $dbh->prepare("SELECT frameworkcode FROM biblio_framework");
            $sth->execute();
            my $frameworks = $sth->fetchall_arrayref();
            $sth->finish();
            push @$frameworks, ['']; #Add the Default framework

            ###Add the default "Koha to MARC mappings"            ###
            foreach my $fwAry (@$frameworks) {
                my $framework = $fwAry->[0];
                $dbh->do("INSERT INTO marc_subfield_structure VALUES ('952','R','Date received','Date received','0','0','items.datereceived','10','','','','0','0','$framework',NULL,'','','9999');");
                $dbh->do("INSERT INTO marc_subfield_structure VALUES ('942','1','First date received','First date received','0','0','biblioitems.datereceived','9','','','','0','0','$framework',NULL,'','','9999');");
            }
            my ( $datereceivedFieldCode, $datereceivedSubfieldCode ) =
                    C4::Biblio::GetMarcFromKohaField( "biblioitems.datereceived", '' );
            ###Add the biblioitems.datereceived to all MARC Records to the mapped location.          ###
            #Fetch all biblios
            my $sth2 = $dbh->prepare(" SELECT b.biblionumber, datereceived, frameworkcode FROM biblioitems bi LEFT JOIN biblio b ON b.biblionumber = bi.biblionumber WHERE datereceived IS NOT NULL; ");
            $sth2->execute();
            my $biblios = $sth2->fetchall_arrayref({});
            $sth2->finish();
            foreach my $b (@$biblios) {
                #UPSERT the datereceived
                my $record = C4::Biblio::GetMarcBiblio(  $b->{biblionumber}  );
                my @existingFields = $record->field($datereceivedFieldCode);
                if ($existingFields[0]) {
                    $existingFields[0]->update($datereceivedSubfieldCode => $b->{datereceived});
                }
                else {
                    my $newField = MARC::Field->new($datereceivedFieldCode, '', '', $datereceivedSubfieldCode => $b->{datereceived});
                    $record->insert_fields_ordered($newField);
                }
                C4::Biblio::ModBiblio($record, $b->{biblionumber}, $b->{frameworkcode});
            }

            print "Upgrade to $DBversion done (Bug 13707 - Adding a new column datereceived for items and biblioitems. New sortable Zebra index! )\n";
            print "-    All MARC records have now been updated, but Zebra needs to be fully reindexed.\n";
        };
        &$doTheDirtyDeed();
    }

    SetVersion ($DBversion);
}