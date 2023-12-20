use Modern::Perl;

return {
    bug_number  => "35616",
    description => "Add source column to tickets table",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        unless ( column_exists( 'tickets', 'source' ) ) {
            $dbh->do(
                "ALTER TABLE `tickets` ADD COLUMN `source` enum('catalog') NOT NULL DEFAULT 'catalog' COMMENT 'source of ticket' AFTER `id`"
            );
            say $out "Added column 'tickets.source'";
        }
    },
};
