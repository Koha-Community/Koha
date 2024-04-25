use Modern::Perl;

return {
    bug_number  => "32602",
    description => "Add administrative plugins type",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        my $permission_added = $dbh->do(
            q{
            INSERT IGNORE INTO permissions (module_bit, code, description) VALUES ( 19, 'admin', 'Use administrative plugins');
        }
        );

        if ( $permission_added == 1 ) {
            say $out "Added new permission 'plugins_admin'";
        }
    },
};
