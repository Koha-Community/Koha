$DBversion = 'XXX';    # will be replaced by the RM
if ( CheckVersion($DBversion) ) {

    # Adding account_credit_types
    $dbh->do(
        qq{
            CREATE TABLE IF NOT EXISTS account_credit_types (
              code varchar(80) NOT NULL,
              description varchar(200) NULL,
              can_be_added_manually tinyint(4) NOT NULL DEFAULT 1,
              is_system tinyint(1) NOT NULL DEFAULT 0,
              PRIMARY KEY (code)
            ) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci
          }
    );

    # Adding account_credit_types_branches
    $dbh->do(
        qq{
            CREATE TABLE IF NOT EXISTS account_credit_types_branches (
                credit_type_code VARCHAR(80),
                branchcode VARCHAR(10),
                FOREIGN KEY (credit_type_code) REFERENCES account_credit_types(code) ON DELETE CASCADE,
                FOREIGN KEY (branchcode) REFERENCES branches(branchcode) ON DELETE CASCADE
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
        }
    );

    # Populating account_credit_types
    $dbh->do(
        qq{
            INSERT IGNORE INTO account_credit_types (
              code,
              description,
              can_be_added_manually,
              is_system
            )
            VALUES
              ('PAYMENT', 'Payment', 0, 1),
              ('WRITEOFF', 'Writeoff', 0, 1),
              ('FORGIVEN', 'Forgiven', 1, 1),
              ('CREDIT', 'Credit', 1, 1),
              ('LOST_RETURN', 'Lost item fee refund', 0, 1)
        }
    );

    # Adding credit_type_code to accountlines
    unless ( column_exists('accountlines', 'credit_type_code') ) {
        $dbh->do(
            qq{
                ALTER IGNORE TABLE accountlines
                ADD
                  credit_type_code varchar(80) DEFAULT NULL
                AFTER
                  accounttype
              }
        );
    }

    # Linking credit_type_code in accountlines to code in account_credit_types
    unless ( foreign_key_exists( 'accountlines', 'accountlines_ibfk_credit_type' ) ) {
        $dbh->do(
            qq{
                ALTER TABLE accountlines
                ADD CONSTRAINT
                  `accountlines_ibfk_credit_type`
                FOREIGN KEY (`credit_type_code`) REFERENCES `account_credit_types` (`code`)
                ON DELETE RESTRICT
                ON UPDATE CASCADE
              }
        );
    }

    # Dropping the check constraint in accountlines
    $dbh->do(
        qq{
          ALTER TABLE
            accountlines
          ADD CONSTRAINT
            `accountlines_check_type`
          CHECK (credit_type_code IS NOT NULL OR debit_type_code IS NOT NULL)
        }
    );

    # Update accountype 'C' to 'CREDIT'
    $dbh->do(
        qq{
          UPDATE accountlines SET accounttype = 'CREDIT' WHERE accounttype = 'C' OR accounttype = 'CR'
        }
    );

    # Update accountype 'FOR' to 'FORGIVEN'
    $dbh->do(
        qq{
          UPDATE accountlines SET accounttype = 'FORGIVEN' WHERE accounttype = 'FOR' OR accounttype = 'FORW'
        }
    );

    # Update accountype 'Pay' to 'PAYMENT'
    $dbh->do(
        qq{
          UPDATE accountlines SET accounttype = 'PAYMENT' WHERE accounttype = 'Pay' OR accounttype = 'PAY'
        }
    );

    # Update accountype 'W' to 'WRITEOFF'
    $dbh->do(
        qq{
          UPDATE accountlines SET accounttype = 'WRITEOFF' WHERE accounttype = 'W' OR accounttype = 'WO'
        }
    );

    # Add any unexpected accounttype codes to credit_types as appropriate
    $dbh->do(
        qq{
          INSERT IGNORE INTO account_credit_types (
            code,
            description,
            can_be_added_manually,
            is_system
          )
          SELECT
            DISTINCT(accounttype),
            "Unexpected type found during upgrade",
            1,
            0
          FROM
            accountlines
          WHERE
            amount < 0
        }
    );

    # Populating credit_type_code
    $dbh->do(
        qq{
        UPDATE accountlines SET credit_type_code = accounttype, accounttype = NULL WHERE accounttype IN (SELECT code from account_credit_types)
        }
    );

    # Adding a check constraints to accountlines
    $dbh->do(
        qq{
        ALTER TABLE accountlines ADD CONSTRAINT `accountlines_check_type` CHECK (accounttype IS NOT NULL OR credit_type_code IS NOT NULL)
        }
    );

    SetVersion($DBversion);
    print "Upgrade to $DBversion done (Bug 23049 - Add account debit_credit)\n";
}
