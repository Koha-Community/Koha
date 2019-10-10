$DBversion = 'XXX';    # will be replaced by the RM
if ( CheckVersion($DBversion) ) {

    # Adding account_debit_types
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

    # Adding ac_debit_types_branches
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

    # Populating account_debit_types
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

    # Moving MANUAL_INV to account_debit_types
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

    # Adding debit_type_code to accountlines
    unless ( column_exists('accountlines', 'debit_type_code') ) {
        $dbh->do(
            qq{
                ALTER IGNORE TABLE accountlines
                ADD
                  debit_type_code varchar(64) DEFAULT NULL
                AFTER
                  accounttype
              }
        );
    }

    # Linking debit_type_code in accountlines to code in account_debit_types
    unless ( foreign_key_exists( 'accountlines', 'accountlines_ibfk_debit_type' ) ) {
        $dbh->do(
            qq{
            ALTER TABLE accountlines ADD CONSTRAINT `accountlines_ibfk_debit_type` FOREIGN KEY (`debit_type_code`) REFERENCES `account_debit_types` (`code`) ON DELETE RESTRICT ON UPDATE CASCADE
              }
        );
    }

    # Adding a check constraints to accountlines
    $dbh->do(
        qq{
        ALTER TABLE accountlines ADD CONSTRAINT `accountlines_check_type` CHECK (accounttype IS NOT NULL OR debit_type_code IS NOT NULL)
        }
    );

    # Populating debit_type_code
    $dbh->do(
        qq{
        UPDATE accountlines SET debit_type_code = accounttype, accounttype = NULL WHERE accounttype IN (SELECT code from account_debit_types)
        }
    );

    # Remove MANUAL_INV
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
