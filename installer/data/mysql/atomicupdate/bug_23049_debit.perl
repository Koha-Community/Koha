$DBversion = 'XXX';    # will be replaced by the RM
if ( CheckVersion($DBversion) ) {

    $dbh->do(
        qq{
            CREATE TABLE IF NOT EXISTS account_debit_types (
              code varchar(64) NOT NULL,
              description varchar(200) NULL,
              can_be_added_manually tinyint(4) NOT NULL DEFAULT 1,
              default_amount decimal(28, 6) NULL,
              is_system tinyint(1) NOT NULL DEFAULT 0,
              PRIMARY KEY (code)
            ) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci
          }
    );

    $dbh->do(
        qq{
            CREATE TABLE IF NOT EXISTS ac_debit_types_branches (
                debit_type_code VARCHAR(64),
                branchcode VARCHAR(10),
                FOREIGN KEY (debit_type_code) REFERENCES account_debit_types(code) ON DELETE CASCADE,
                FOREIGN KEY (branchcode) REFERENCES branches(branchcode) ON DELETE CASCADE
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
        }
    );

    $dbh->do(
        qq{
            INSERT IGNORE INTO account_debit_types (
              code,
              description,
              can_be_added_manually,
              default_amount,
              is_system
            )
            VALUES
              ('ACCOUNT', 'Account creation fee', 0, NULL, 1),
              ('ACCOUNT_RENEW', 'Account renewal fee', 0, NULL, 1),
              ('HE', 'Hold waiting too long', 0, NULL, 1),
              ('LOST', 'Lost item', 1, NULL, 1),
              ('M', 'Manual fee', 1, NULL, 0),
              ('N', 'New card fee', 1, NULL, 1),
              ('OVERDUE', 'Overdue fine', 0, NULL, 1),
              ('PF', 'Lost item processing fee', 0, NULL, 1),
              ('RENT', 'Rental fee', 0, NULL, 1),
              ('RENT_DAILY', 'Daily rental fee', 0, NULL, 1),
              ('RENT_RENEW', 'Renewal of rental item', 0, NULL, 1),
              ('RENT_DAILY_RENEW', 'Rewewal of daily rental item', 0, NULL, 1),
              ('Res', 'Hold fee', 0, NULL, 1)
        }
    );

    $dbh->do(
        qq{
            INSERT IGNORE INTO account_debit_types (
              code,
              default_amount,
              description,
              can_be_added_manually,
              is_system
            )
            SELECT
              SUBSTR(authorised_value, 1, 64),
              lib,
              authorised_value,
              1,
              0
            FROM
              authorised_values
            WHERE
              category = 'MANUAL_INV'
          }
    );

    $dbh->do(
        qq{
            ALTER IGNORE TABLE accountlines
            ADD
              debit_type varchar(64) DEFAULT NULL
            AFTER
              accounttype
          }
    );

    $dbh->do(
        qq{
        ALTER TABLE accountlines ADD CONSTRAINT `accountlines_ibfk_debit_type` FOREIGN KEY (`debit_type`) REFERENCES `account_debit_types` (`code`) ON DELETE SET NULL ON UPDATE CASCADE
          }
    );

    $dbh->do(
        qq{
        ALTER TABLE accountlines ADD CONSTRAINT `accountlines_check_type` CHECK (accounttype IS NOT NULL OR debit_type IS NOT NULL)
        }
    );

    $dbh->do(
        qq{
        UPDATE accountlines SET debit_type = accounttype, accounttype = NULL WHERE accounttype IN (SELECT code from account_debit_types)
        }
    );

    # Clean up MANUAL_INV
    $dbh->do(
        qq{
        DELETE FROM authorised_values WHERE category = 'MANUAL_INV'
        }
    );
    $dbh->do(
        qq{
        DELETE FROM authorised_value_categories WHERE category_name = 'MANUAL_INV'
        }
    );

    # Add new permission
    $dbh->do(
        q{
            INSERT IGNORE INTO permissions (module_bit, code, description)
            VALUES
              (
                3,
                'manage_accounts',
                'Manage Account Debit and Credit Types'
              )
        }
    );

    SetVersion($DBversion);
    print "Upgrade to $DBversion done (Bug 23049 - Add account debit_types)\n";
}
