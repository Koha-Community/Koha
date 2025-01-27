use Modern::Perl;

return {
    bug_number  => "30823",
    description => "Replace recalls FULFILL actions with FILL in action logs",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(q{ UPDATE action_logs SET action = 'FILL' WHERE action = 'FULFILL' AND module = 'RECALLS' });
    },
};
