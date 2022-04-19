use Modern::Perl;

return {
    bug_number => "21978",
    description => "Add middle_name to borrowers table",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};
        if( !column_exists( 'borrowers', 'middle_name' ) ) {
            $dbh->do(q{
                ALTER TABLE borrowers
                ADD COLUMN middle_name longtext NULL DEFAULT NULL
                COMMENT "patron/borrower's middle name"
                AFTER firstname
            });
            say $out "Added middle name column to borrowers table";
        }
        if( !column_exists( 'deletedborrowers', 'middle_name' ) ) {
            $dbh->do(q{
                ALTER TABLE deletedborrowers
                ADD COLUMN middle_name longtext NULL DEFAULT NULL
                COMMENT "patron/borrower's middle name"
                AFTER firstname
            });
            say $out "Added middle name column to deletedborrowers table";
        }
        if( !column_exists( 'borrower_modifications', 'middle_name' ) ) {
            $dbh->do(q{
                ALTER TABLE borrower_modifications
                ADD COLUMN middle_name longtext NULL DEFAULT NULL
                COMMENT "patron/borrower's middle name"
                AFTER firstname
            });
            say $out "Added middle name column to borrower_modifications table";
        }
        my @default_patron_search_fields = split(',',C4::Context->preference('DefaultPatronSearchFields'));
        unless( grep /middle_name/, @default_patron_search_fields ){
            if( grep /firstname/, @default_patron_search_fields ){
                push @default_patron_search_fields,'middle_name';
                C4::Context->set_preference('DefaultPatronSearchFields', join(',',@default_patron_search_fields) );
                say $out "Added middle name to DefaultPatronSearchFields";
            } else {
                say $out "Please add 'middlename' to DefaultPatronSearchFields if you want it searched by default";
            }
        }
    },
}
