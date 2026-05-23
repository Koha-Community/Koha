use Modern::Perl;
use Koha::Installer::Output qw(say_success);

return {
    bug_number  => "40633",
    description => "Add keyboard shortcut to advanced cataloging editor for fixed length field plugins",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{
            INSERT IGNORE INTO keyboard_shortcuts (shortcut_name, shortcut_keys)
            VALUES ('open_helper_plugin', 'Shift-Ctrl-H')
        }
        );

        say_success( $out, "Added 'open_helper_plugin' keyboard shortcut for the advanced cataloging editor" );
    },
};
