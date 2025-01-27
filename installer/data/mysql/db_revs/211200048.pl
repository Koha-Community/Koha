use Modern::Perl;

return {
    bug_number  => "30291",
    description => "Renaming recalls table columns",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        if ( TableExists('recalls') and column_exists( 'recalls', 'borrowernumber' ) ) {
            $dbh->do(q{ ALTER TABLE recalls CHANGE COLUMN borrowernumber patron_id int(11) NOT NULL DEFAULT 0 });
            $dbh->do(q{ ALTER TABLE recalls CHANGE COLUMN recalldate created_date datetime DEFAULT NULL });
            $dbh->do(q{ ALTER TABLE recalls CHANGE COLUMN biblionumber biblio_id int(11) NOT NULL DEFAULT 0 });
            $dbh->do(q{ ALTER TABLE recalls CHANGE COLUMN branchcode pickup_library_id varchar(10) DEFAULT NULL });
            $dbh->do(q{ ALTER TABLE recalls CHANGE COLUMN cancellationdate completed_date datetime DEFAULT NULL });
            $dbh->do(q{ ALTER TABLE recalls CHANGE COLUMN recallnotes notes mediumtext });
            $dbh->do(q{ ALTER TABLE recalls CHANGE COLUMN itemnumber item_id int(11) DEFAULT NULL });
            $dbh->do(q{ ALTER TABLE recalls CHANGE COLUMN waitingdate waiting_date datetime DEFAULT NULL });
            $dbh->do(q{ ALTER TABLE recalls CHANGE COLUMN expirationdate expiration_date datetime DEFAULT NULL });
            $dbh->do(q{ ALTER TABLE recalls CHANGE COLUMN old completed TINYINT(1) NOT NULL DEFAULT 0 });
            $dbh->do(q{ ALTER TABLE recalls CHANGE COLUMN item_level_recall item_level TINYINT(1) NOT NULL DEFAULT 0 });
        }
    },
};
