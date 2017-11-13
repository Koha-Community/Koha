$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    # you can use $dbh here like:
    # $dbh->do( "ALTER TABLE biblio ADD COLUMN badtaste int" );

    my $now = DateTime->now(time_zone => C4::Context->tz);
    my $oneYearAgo = $now->clone()->subtract(years => 1);
    my $twoYearsAgo = $now->clone()->subtract(years => 2);

    C4::BatchOverlay::RuleManager::alterAllRules({
        default => {
            candidateCriteria => {
                lowlyCatalogued => 'always',
                monthsPast => 'Date-of-acquisition 2',
                publicationDates => [$now->year, $oneYearAgo->year, $twoYearsAgo->year],
            }
        }
    });


    # Always end with this (adjust the bug info)
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (KD-671-1 - TäTi - Batch Overlay 'candidateCriteria'-feature)\n";
}