use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "42764",
    description => "Fix typo in reports_dictionary.report_area column comment",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{
            ALTER TABLE `reports_dictionary`
            MODIFY COLUMN `report_area` varchar(6) DEFAULT NULL
                COMMENT 'Koha module this definition is for (Circulation, Catalog, Patrons, Acquisitions, Accounts)'
        }
        );

        say_success( $out, "Fixed typo in reports_dictionary.report_area column comment" );
    },
};
