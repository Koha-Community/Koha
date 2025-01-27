use Modern::Perl;

return {
    bug_number  => "11879",
    description => "Add a new field to patron record: main contact method",
    up          => sub {
        my ($args) = @_;
        my $dbh = $args->{dbh};

        if ( !column_exists( 'borrowers', 'primary_contact_method' ) ) {
            $dbh->do(
                "ALTER TABLE `borrowers` ADD COLUMN `primary_contact_method` VARCHAR(45) DEFAULT NULL AFTER `autorenew_checkouts`"
            );
        }

        if ( !column_exists( 'deletedborrowers', 'primary_contact_method' ) ) {
            $dbh->do(
                "ALTER TABLE `deletedborrowers` ADD COLUMN `primary_contact_method` VARCHAR(45) DEFAULT NULL AFTER `autorenew_checkouts`"
            );
        }

        if ( !column_exists( 'borrower_modifications', 'primary_contact_method' ) ) {
            $dbh->do(
                "ALTER TABLE `borrower_modifications` ADD COLUMN `primary_contact_method` VARCHAR(45) DEFAULT NULL AFTER `gdpr_proc_consent`"
            );
        }
    },
    }
