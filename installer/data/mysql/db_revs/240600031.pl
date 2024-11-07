use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "23685",
    description => "Add system preferences ReportsExportFormatODS and ReportsExportLimit",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # sysprefs
        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences ( variable, value, options, explanation, type ) VALUES
            ('ReportsExportFormatODS',1,NULL,'Show ODS download in Reports','YesNo'),
            ('ReportsExportLimit',NULL,NULL,'Limit for report downloads','Integer');
        }
        );
        say_success( $out, "Added new system preferences 'ReportsExportFormatODS' and 'ReportsExportLimit'" );
    },
};
