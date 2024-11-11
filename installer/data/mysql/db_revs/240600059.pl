use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "37221",
    description => "Add new system preference OPACOverDrive",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        my $count_sql =
            q{SELECT count( value ) AS count FROM systempreferences WHERE variable IN ('OverDriveLibraryID', 'OverDriveClientKey', 'OverDriveClientSecret') AND value IS NOT NULL AND value != ''};
        my ($count) = $dbh->selectrow_array($count_sql);
        my $enabled =
            $count == 3 ? 1 : 0;    # If all 3 preferences are enabled OverDrive content has been previously enabled

        my $sth = $dbh->prepare(
            q{
            INSERT IGNORE INTO systempreferences (variable, value, explanation, options, type)
            VALUES ('OPACOverDrive', ?, 'Enable OverDrive integration in the OPAC', '', 'YesNo')
        }
        );
        $sth->execute($enabled);

        if ($enabled) {
            say_success( $out, "Added and enabled new system preference 'OPACOverDrive'" );
        } else {
            say_success( $out, "Added new system preference 'OPACOverDrive'" );
        }
    },
};
