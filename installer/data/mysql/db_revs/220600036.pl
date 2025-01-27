use Modern::Perl;

return {
    bug_number  => "31017",
    description => "Add type option to vendors",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};
        unless ( column_exists( 'aqbooksellers', 'type' ) ) {
            $dbh->do(
                q{
                ALTER TABLE aqbooksellers ADD COLUMN type varchar(255) DEFAULT NULL AFTER accountnumber
            }
            );

            say $out "Added column 'aqbooksellers.type'";
        }
        $dbh->do(
            q{
            INSERT IGNORE INTO authorised_value_categories( category_name, is_system ) VALUES ('VENDOR_TYPE', 1);
        }
        );
        say $out "Added VENDOR_TYPE authorised value category";
    },
};
