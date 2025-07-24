use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "38436",
    description => "Adjust column names for holdings tables in the table settings",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{
            UPDATE columns_settings
            SET columnname = SUBSTRING(columnname,LOCATE("_",columnname)+1)
            WHERE module="catalogue" AND page="detail" AND ( tablename="holdings_table" OR tablename="otherholdings_table") AND (columnname LIKE 'holdings_%' OR columnname LIKE 'otherholdings_%')
        }
        );
        say_success( $out, "Column names renamed" );
    },
};
