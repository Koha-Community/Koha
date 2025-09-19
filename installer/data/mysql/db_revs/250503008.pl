use Modern::Perl;

return {
    bug_number  => "36135",
    description => "Add new permission batch_modify_holds",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{INSERT IGNORE permissions (module_bit, code, description) VALUES (13, 'batch_modify_holds', 'Perform batch modification of holds')}
        );

        say $out "Added new permission 'batch_modify_holds'";
    },
};
