use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "43671",
    description => "Add system preference SCOLoadHoldsByDefault",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Do your stuff here
        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences ( `variable`, `value` ) VALUES ('SCOLoadHoldsByDefault','1')
        }
        );

        say_success( $out, "Added new system preference SCOLoadHoldsByDefault" );
    },
};
