use Modern::Perl;

return {
    bug_number  => "28813",
    description => "Update delivery_note to failure_code in message_queue",
    up          => sub {
        my ($args) = @_;
        my $dbh = $args->{dbh};

        if ( column_exists( 'message_queue', 'delivery_note' ) ) {
            $dbh->do(
                q{
                ALTER TABLE message_queue CHANGE COLUMN delivery_note failure_code MEDIUMTEXT
            }
            );
        }

        if ( !column_exists( 'message_queue', 'failure_code' ) ) {
            $dbh->do(
                q{
                ALTER TABLE message_queue ADD failure_code mediumtext AFTER content_type
            }
            );
        }
    },
    }
