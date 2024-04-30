use Modern::Perl;

return {
    bug_number  => 36002,
    description => "Remove aqorders.purchaseordernumber",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        if ( column_exists( 'aqorders', 'purchaseordernumber' ) ) {
            my ($cnt) = $dbh->selectrow_array(
                q|
SELECT count(*) FROM aqorders
WHERE purchaseordernumber IS NOT NULL|
            );
            if ($cnt) {
                say $out "We found $cnt order lines where field purchaseordernumber was filled!";
                $dbh->do(
                    q|
CREATE TABLE zzaqorders_purchaseordernumber AS
SELECT ordernumber,purchaseordernumber FROM aqorders WHERE purchaseordernumber IS NOT NULL|
                );
                say $out q|These records have been copied to table: zzaqorders_purchaseordernumber.
Please examine the data and remove this table.|;
            }

            $dbh->do(q{ALTER TABLE aqorders DROP COLUMN purchaseordernumber});
        }
    },
};
