use Modern::Perl;

return {
    bug_number  => "34438",
    description => "Add lang to to the borrower_modifications table",
    up          => sub {
        my ($args) = @_;
        my $dbh = $args->{dbh};
        if ( !column_exists( 'borrower_modifications', 'lang' ) ) {
            $dbh->do(
                "ALTER TABLE `borrower_modifications` ADD COLUMN `lang` VARCHAR(25) DEFAULT NULL AFTER `primary_contact_method`"
            );
        }
    },
    }
