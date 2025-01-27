use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "38436",
    description => "Adjust column names for holdings tables in the table settings",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        say $dbh->do(
            q{
            UPDATE columns_settings
            SET columnname = REGEXP_REPLACE(columnname, '.*holdings_', '')
            WHERE module="catalogue" AND page="detail" AND ( tablename="holdings_table" OR tablename="otherholdings_table")
        }
        );
        say_success( $out, "Column names renamed" );
    },
};
