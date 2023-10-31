use Modern::Perl;

return {
    bug_number  => "34520",
    description => "Correct item_groups FK in reserves table",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        if ( foreign_key_exists( 'reserves', 'reserves_ibfk_ig' ) ) {
            $dbh->do(
                q|
                ALTER TABLE reserves
                DROP FOREIGN KEY reserves_ibfk_ig
            |
            );

            $dbh->do(
                q|
                ALTER TABLE reserves
                ADD CONSTRAINT reserves_ibfk_ig
                    FOREIGN KEY (item_group_id)
                    REFERENCES item_groups (item_group_id) ON DELETE SET NULL ON UPDATE CASCADE
            |
            );
        }

        say $out "FK 'reserves_ibfk_ig' on reserves updated to ON DELETE SET NULL";
    },
};
