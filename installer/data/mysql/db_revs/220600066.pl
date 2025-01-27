use Modern::Perl;

return {
    bug_number  => "31626",
    description => "Add letter id to the message queue table",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};
        unless ( column_exists( 'message_queue', 'letter_id' ) ) {
            $dbh->do(
                q{
                ALTER TABLE message_queue
                ADD COLUMN `letter_id` int(11) DEFAULT NULL COMMENT 'Foreign key to the letters table' AFTER message_id,
                ADD CONSTRAINT letter_fk FOREIGN KEY (letter_id) REFERENCES letter(id) ON DELETE SET NULL ON UPDATE CASCADE
            }
            );

            say $out "Added column 'message_queue.letter_id'";
        }
    },
};
