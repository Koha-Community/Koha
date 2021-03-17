$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do(
        qq{
            INSERT IGNORE INTO account_debit_types (
              code,
              description,
              can_be_invoiced,
              can_be_sold,
              default_amount,
              is_system
            )
            VALUES
              ('VOID', 'Credit has been voided', 0, 0, NULL, 1)
        }
    );

    $dbh->do(q{
        INSERT IGNORE INTO account_offset_types ( type ) VALUES ('VOID');
    });

    NewVersion( $DBversion, 27971, "Add VOID debit type code");
}
