use Modern::Perl;

return {
    bug_number  => "24239",
    description => "Let the ILL module set ad hoc hard due dates",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        unless ( column_exists( 'illrequests', 'due_date' ) ) {
            $dbh->do(
                q{
                ALTER TABLE `illrequests`
                    ADD COLUMN `due_date` datetime DEFAULT NULL COMMENT 'Custom date due specified by backend, leave NULL for default date_due calculation'
                    AFTER `biblio_id`
            }
            );

            say $out "Added column 'illrequests.due_date'";
        }
    },
};
