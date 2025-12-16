use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "41460",
    description => "Remove column default from systempreferences.value",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Do you stuffs here
        $dbh->do(q{MODIFY COLUMN `value` mediumtext NOT NULL COMMENT 'system preference values'});

        # Print useful stuff here
        # tables
        say $out "Removed default from column 'systempreferences.value'";
    },
};
