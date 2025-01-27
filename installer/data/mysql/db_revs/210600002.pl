use Modern::Perl;

return {
    bug_number  => "28490",
    description => "Bring back accidentally deleted relationship columns",
    up          => sub {
        my ($args) = @_;
        my $dbh = $args->{dbh};

        if ( !column_exists( 'borrower_modifications', 'relationship' ) ) {
            $dbh->do(
                q{
              ALTER TABLE borrower_modifications ADD COLUMN `relationship` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL AFTER `borrowernotes`
          }
            );
        }

        if ( !column_exists( 'borrowers', 'relationship' ) ) {
            $dbh->do(
                q{
              ALTER TABLE borrowers ADD COLUMN `relationship` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'used for children to include the relationship to their guarantor' AFTER `borrowernotes`
          }
            );
        }

        if ( !column_exists( 'deletedborrowers', 'relationship' ) ) {
            $dbh->do(
                q{
              ALTER TABLE deletedborrowers ADD COLUMN `relationship` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'used for children to include the relationship to their guarantor' AFTER `borrowernotes`
          }
            );
        }
    },
    }
