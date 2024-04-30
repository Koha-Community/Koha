use Modern::Perl;

return {
    bug_number  => "35626",
    description => "Add statuses to catalog concerns",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};
        unless ( column_exists( 'tickets', 'status' ) ) {
            $dbh->do(
                q{
                ALTER TABLE tickets ADD COLUMN status varchar(80) DEFAULT NULL COMMENT 'current status of the ticket' AFTER body
            }
            );

            say $out "Added column 'tickets.status'";
        }
        unless ( column_exists( 'ticket_updates', 'status' ) ) {
            $dbh->do(
                q{
                ALTER TABLE ticket_updates ADD COLUMN status varchar(80) DEFAULT NULL COMMENT 'status of ticket at this update' AFTER message
            }
            );

            say $out "Added column 'ticket_updates.status'";
        }
        $dbh->do(
            q{
            INSERT IGNORE INTO authorised_value_categories( category_name, is_system ) VALUES ('TICKET_STATUS', 1);
        }
        );
        say $out "Added TICKET_STATUS authorised value category";
    },
};
