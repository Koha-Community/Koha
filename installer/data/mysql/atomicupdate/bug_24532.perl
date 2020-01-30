$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    # Add any pathalogical incorrect debit_types as credit_types as appropriate
    $dbh->do(
        qq{
          INSERT IGNORE INTO account_credit_types (
            code,
            description,
            can_be_added_manually,
            is_system
          )
          SELECT
            DISTINCT(debit_type_code),
            "Unexpected type found during upgrade",
            1,
            0
          FROM
            accountlines
          WHERE
            amount < 0
          AND
            debit_type_code IS NOT NULL
        }
    );

    # Correct any pathalogical cases
    $dbh->do( qq{
      UPDATE
        accountlines
      SET
        credit_type_code = debit_type_code,
        debit_type_code = NULL
      WHERE
        amount < 0
      AND
        debit_type_code IS NOT NULL
    });

    # Always end with this (adjust the bug info)
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug XXXXX - description)\n";
}
