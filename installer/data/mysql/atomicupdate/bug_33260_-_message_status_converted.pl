use Modern::Perl;

return {
    bug_number  => "33260",
    description => "Add a 'converted' status to the message queue",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        my ($column_type) = $dbh->selectrow_array(
            q{SELECT COLUMN_TYPE FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'message_queue' AND COLUMN_NAME = 'status'}
        );

        if ( $column_type =~ /'converted'/ ) {
            say $out "Status 'converted' already exists in message_queue.status, skipping";
            return;
        }

        # Add it to the statuses there are, whichever other statuses have been added
        $column_type =~ s/\)$/,'converted')/;
        $dbh->do(qq{ALTER TABLE message_queue MODIFY COLUMN `status` $column_type NOT NULL DEFAULT 'pending'});

        say $out "Added status 'converted' to message_queue.status";
    },
};
