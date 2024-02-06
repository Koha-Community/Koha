use Modern::Perl;

return {
    bug_number  => 36002,
    description => "Remove aqorders.purchaseordernumber",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};
        if ( column_exists( 'aqorders', 'purchaseordernumber' ) ) {
            $dbh->do(q{ALTER TABLE aqorders DROP COLUMN purchaseordernumber});
        }
    },
};
