use Modern::Perl;

return {
    bug_number  => "35657",
    description => "Add assignee_id to tickets",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        unless ( column_exists( 'tickets', 'assignee_id' ) ) {
            $dbh->do(
                q{
                ALTER TABLE tickets ADD COLUMN assignee_id int(11) DEFAULT NULL COMMENT 'id of the user this ticket is assigned to' AFTER status
            }
            );
            $dbh->do(
                q{
                ALTER TABLE tickets
                ADD CONSTRAINT `tickets_ibfk_4` FOREIGN KEY (`assignee_id`)
                REFERENCES `borrowers` (`borrowernumber`) ON DELETE CASCADE ON UPDATE CASCADE
            }
            );
            say $out "Added column 'tickets.assignee_id'";
        }

        unless ( column_exists( 'ticket_updates', 'assignee_id' ) ) {
            $dbh->do(
                q{
                ALTER TABLE ticket_updates ADD COLUMN assignee_id int(11) DEFAULT NULL COMMENT 'id of the user this ticket was assigned to with this update' AFTER user_id
            }
            );
            $dbh->do(
                q{
                ALTER TABLE ticket_updates
                ADD CONSTRAINT `ticket_updates_ibfk_4` FOREIGN KEY (`assignee_id`)
                REFERENCES `borrowers` (`borrowernumber`) ON DELETE CASCADE ON UPDATE CASCADE
            }
            );
            say $out "Added column 'ticket_updates.assignee_id'";
        }
    },
};
