use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "40405",
    description => "Set systempreferences.value to NOT NULL",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        my $modified = $dbh->do(
            q{
            UPDATE systempreferences
            SET value=""
            WHERE value IS NULL
        }
        );

        if ( $modified ne "0E0" ) {
            say $out sprintf "Adjusted %s systempreference's value to an empty string", $modified;
        }

        $dbh->do(
            q{
            ALTER TABLE systempreferences
            MODIFY COLUMN `value` mediumtext NOT NULL DEFAULT '' COMMENT 'system preference values'
        }
        );
    },
};
