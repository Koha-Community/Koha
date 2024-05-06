use Modern::Perl;

return {
    bug_number  => "25159",
    description => "Add action logs should be stored in JSON ( and as a diff of the change )",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        unless ( column_exists( 'action_logs', 'diff' ) ) {
            $dbh->do(q{ALTER TABLE action_logs ADD COLUMN diff LONGTEXT NULL DEFAULT NULL AFTER trace;});
        }

        say $out "Added column 'action_logs.diff'";
    },
};
