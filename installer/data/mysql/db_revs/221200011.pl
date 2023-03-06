use Modern::Perl;

return {
    bug_number => "25655",
    description => "Store actual cost in foreign currency and currency from the invoices",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};
        unless ( column_exists('aqorders', 'invoice_unitprice') ) {
            $dbh->do(q{
                ALTER TABLE aqorders
                ADD COLUMN invoice_unitprice decimal(28,6) DEFAULT NULL COMMENT 'the unit price in foreign currency' AFTER estimated_delivery_date
            });
        }
        say $out "Added column 'aqorders.invoice_unitprice'";

        unless ( column_exists('aqorders', 'invoice_currency') ) {
            $dbh->do(q{
                ALTER TABLE aqorders
                ADD COLUMN invoice_currency varchar(10) DEFAULT NULL COMMENT 'the currency of the invoice_unitprice' AFTER invoice_unitprice,
                ADD CONSTRAINT `aqorders_invoice_currency` FOREIGN KEY (`invoice_currency`) REFERENCES `currency` (`currency`) ON DELETE SET NULL ON UPDATE SET NULL
            });
        }
        say $out "Added column 'aqorders.invoice_currency'";
    },
};
