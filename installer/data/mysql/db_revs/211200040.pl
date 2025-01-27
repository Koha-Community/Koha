use Modern::Perl;

return {
    bug_number  => 30565,
    description => "Update table stockrotationrotas",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};
        if ( !unique_key_exists( 'stockrotationrotas', 'stockrotationrotas_title' ) ) {
            $dbh->do(
                q|
ALTER TABLE stockrotationrotas ADD CONSTRAINT UNIQUE KEY stockrotationrotas_title (title)
            |
            );
        }

        # Make sure that description is NOT NULL
        $dbh->do(
            q|
ALTER TABLE stockrotationrotas MODIFY COLUMN description text NOT NULL COMMENT 'Description for this rota'
        |
        );
    },
};
