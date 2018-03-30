$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do( "
        CREATE TABLE IF NOT EXISTS invoice_adjustments (
            adjustment_id int(11) NOT NULL AUTO_INCREMENT,
            invoiceid int(11) NOT NULL,
            adjustment decimal(28,6),
            reason varchar(80) default NULL,
            note mediumtext default NULL,
            budget_id int(11) default NULL,
            encumber_open smallint(1) NOT NULL default 1,
            timestamp timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
            PRIMARY KEY (adjustment_id),
            CONSTRAINT invoice_adjustments_fk_invoiceid FOREIGN KEY (invoiceid) REFERENCES aqinvoices (invoiceid) ON DELETE CASCADE ON UPDATE CASCADE,
            CONSTRAINT invoice_adjustments_fk_budget_id FOREIGN KEY (budget_id) REFERENCES aqbudgets (budget_id) ON DELETE SET NULL ON UPDATE CASCADE
        )
        " );
    $dbh->do("INSERT IGNORE INTO authorised_value_categories (category_name) VALUES ('ADJ_REASON')");
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 19166 - Add the ability to add adjustments to an invoice)\n";
}
