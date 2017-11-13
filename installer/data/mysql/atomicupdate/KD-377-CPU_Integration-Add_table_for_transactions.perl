$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    # you can use $dbh here like:

    $dbh->do("
            CREATE TABLE payments_transactions (
                transaction_id int(11) NOT NULL auto_increment,
                borrowernumber int(11) NOT NULL,
                accountlines_id int(11),
                status ENUM('paid','pending','cancelled','unsent','processing') DEFAULT 'unsent',
                timestamp timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                description TEXT NOT NULL,
                price_in_cents int(11) NOT NULL,
                user_branch varchar(10),
                is_self_payment int(11) NOT NULL DEFAULT 0,
                PRIMARY KEY (transaction_id),
                FOREIGN KEY (accountlines_id)
                    REFERENCES accountlines(accountlines_id)
                    ON DELETE CASCADE,
                FOREIGN KEY (borrowernumber)
                    REFERENCES borrowers(borrowernumber)
                    ON DELETE CASCADE
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
            ");
    $dbh->do("
            CREATE TABLE payments_transactions_accountlines (
                transactions_accountlines_id int(11) NOT NULL auto_increment,
                transaction_id int(11) NOT NULL,
                accountlines_id int(11) NOT NULL,
                paid_price_cents int(11) NOT NULL,
                PRIMARY KEY (transactions_accountlines_id),
                FOREIGN KEY (transaction_id)
                    REFERENCES payments_transactions(transaction_id)
                    ON DELETE CASCADE,
                FOREIGN KEY (accountlines_id)
                    REFERENCES accountlines(accountlines_id)
                    ON DELETE CASCADE
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
        ");

    # Add system preferences
    $dbh->do("INSERT INTO systempreferences (variable, value, options, explanation, type) VALUES ('OnlinePayments', '', '', 'Maps Koha account types into online payment store item numbers and defines the interfaces that will be used for each branch', 'textarea')");
    $dbh->do("INSERT INTO systempreferences (variable, value, options, explanation, type) VALUES ('POSIntegration', '', '', 'Maps Koha account types into POS item numbers and defines the interfaces that will be used for each branch', 'textarea')");
    $dbh->do("INSERT INTO systempreferences (variable, value, options, explanation, type) VALUES ('OnlinePaymentMinTotal', '0', '', 'Defines a minimum amount of money that Borrower can pay through online payments', 'Integer')");

    # Always end with this (adjust the bug info)
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug XXXXX - description)\n";
}
