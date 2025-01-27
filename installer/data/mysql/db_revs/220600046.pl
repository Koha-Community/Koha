use Modern::Perl;

return {
    bug_number  => "15348",
    description => "Add new column aqorders.estimated_delivery_date",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        unless ( column_exists( 'aqorders', 'estimated_delivery_date' ) ) {
            $dbh->do(
                q{
                ALTER TABLE aqorders
                  ADD estimated_delivery_date date DEFAULT NULL COMMENT 'Estimated delivery date'
                  AFTER suppliers_report
            }
            );
        }
    },
};
