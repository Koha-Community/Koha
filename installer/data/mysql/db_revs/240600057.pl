use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "22421",
    description => "Add issue constraints to accountlines",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Add old_issue_id field
        unless ( column_exists( 'accountlines', 'old_issue_id' ) ) {
            $dbh->do(
                q{
            ALTER TABLE accountlines
            ADD COLUMN old_issue_id int(11) DEFAULT NULL AFTER issue_id
            }
            );
            say_success( $out, "Added column 'accountlines.old_issue_id'" );
        }

        unless ( foreign_key_exists( 'accountlines', 'accountlines_ibfk_old_issues' ) ) {

            $dbh->do(
                q{
            ALTER TABLE accountlines
            ADD CONSTRAINT `accountlines_ibfk_old_issues`
              FOREIGN KEY (`old_issue_id`)
              REFERENCES `old_issues` (`issue_id`)
              ON DELETE SET NULL
              ON UPDATE CASCADE
            }
            );
            say_success( $out, "Added constraint 'accountlines.old_issues'" );
        }

        # Add constraint for issue_id
        unless ( foreign_key_exists( 'accountlines', 'accountlines_ibfk_issues' ) ) {

            $dbh->do(
                q{
            UPDATE
                accountlines a
                LEFT JOIN old_issues o ON (a.issue_id = o.issue_id)
            SET
                a.old_issue_id = o.issue_id,
                a.issue_id = NULL
            WHERE
                o.issue_id IS NOT NULL
            }
            );
            say_success( $out, "Updated 'accountlines.old_issue_id' from 'old_issues'" );

            $dbh->do(
                q{
            UPDATE
                accountlines a
                LEFT JOIN issues i ON (a.issue_id = i.issue_id)
            SET
                a.issue_id = NULL
            WHERE
                i.issue_id IS NULL
            }
            );
            say_success( $out, "Fixed 'accountlines.issue_id' where missing from issues" );

            $dbh->do(
                q{
            ALTER TABLE accountlines
            ADD CONSTRAINT `accountlines_ibfk_issues`
                FOREIGN KEY (`issue_id`)
                REFERENCES `issues` (`issue_id`)
                ON DELETE SET NULL
                ON UPDATE CASCADE
            }
            );
            say_success( $out, "Added constraint 'accountlines.issues'" );
        }

        say_success( $out, "Added old_issue_id to accountlines and set up appropriate constraints)" );
    }
};
