use Modern::Perl;
use Koha::Installer::Output qw(say_success say_failure);

return {
    bug_number  => "43671",
    description => "Add system preference SCOLoadHoldsByDefault",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        unless (
            $dbh->selectrow_array(q{SELECT COUNT(*) FROM systempreferences WHERE variable = 'SCOLoadHoldsByDefault'}) )
        {
            my $ok = $dbh->do(
                q{
                INSERT IGNORE INTO systempreferences ( `variable`, `value` ) VALUES ('SCOLoadHoldsByDefault','1')
            }
            );
            if ($ok) {
                say_success( $out, "Added new system preference SCOLoadHoldsByDefault" );
            } else {
                say_failure( $out, "Failed to add system preference SCOLoadHoldsByDefault: " . $dbh->errstr );
            }
        }
    },
};
