use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "36453",
    description => "Update BlockExpiredPatronOpacActions where 24.06.000.02 was already run",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        my $sth = $dbh->prepare(
            q{
            SELECT DATA_TYPE
                FROM INFORMATION_SCHEMA.COLUMNS
                WHERE TABLE_NAME = 'categories' and COLUMN_NAME = 'BlockExpiredPatronOpacActions'
        }
        );
        $sth->execute;
        my $data_type = $sth->fetchrow();

        if ( $data_type eq 'mediumtext' ) {
            $dbh->do(
                "ALTER TABLE categories MODIFY BlockExpiredPatronOpacActions varchar(128) NOT NULL DEFAULT 'follow_syspref_BlockExpiredPatronOpacActions' COMMENT 'specific actions expired patrons of this category are blocked from performing or if the BlockExpiredPatronOpacActions system preference is to be followed'"
            ) and say_success( $out, "Updated categories.BlockExpiredPatronOpacActions to varchar(128)" );
        } else {
            say_info( $out, "categories.BlockExpiredPatronOpacActions already varchar(128)" );
        }
    },
};
