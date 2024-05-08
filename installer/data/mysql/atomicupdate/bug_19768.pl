use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_failure say_success say_info);

return {
    bug_number  => "19768",
    description => "Add 'Title notes' tab to OpacSerialDefaultTab preference",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Do you stuffs here
        $dbh->do(
            q{ UPDATE systempreferences SET value = 'holdings|serialcollection|subscriptions|titlenotes', options = 'holdings|serialcollection|subscriptions|titlenotes' WHERE variable = 'opacSerialDefaultTab' }
        );

        # Print useful stuff here
        say $out "Added 'Title notes' option to opacSerialDefaultTab preference";

    },
};
