use Modern::Perl;

return {
    bug_number  => "21729",
    description => "Add new column reserves.patron_expiration_date",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};
        unless ( column_exists( 'reserves', 'patron_expiration_date' ) ) {
            $dbh->do(
                q{
                ALTER TABLE reserves
                ADD COlUMN patron_expiration_date date DEFAULT NULL COMMENT 'the date the hold expires - usually the date entered by the patron to say they don''t need the hold after a certain date'
                AFTER expirationdate
            }
            );
        }
        unless ( column_exists( 'old_reserves', 'patron_expiration_date' ) ) {
            $dbh->do(
                q{
                ALTER TABLE old_reserves
                ADD COlUMN patron_expiration_date date DEFAULT NULL COMMENT 'the date the hold expires - usually the date entered by the patron to say they don''t need the hold after a certain date'
                AFTER expirationdate
            }
            );
        }

    },
};
