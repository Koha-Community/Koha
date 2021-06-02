$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    if( !column_exists( 'borrower_modifications', 'relationship' ) ) {
      $dbh->do(q{
          ALTER TABLE borrower_modifications ADD COLUMN `relationship` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL AFTER `borrowernotes`
      });
    }

    if( !column_exists( 'borrowers', 'relationship' ) ) {
      $dbh->do(q{
          ALTER TABLE borrowers ADD COLUMN `relationship` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'used for children to include the relationship to their guarantor' AFTER `borrowernotes`
      });
    }

    if( !column_exists( 'deletedborrowers', 'relationship' ) ) {
      $dbh->do(q{
          ALTER TABLE deletedborrowers ADD COLUMN `relationship` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'used for children to include the relationship to their guarantor' AFTER `borrowernotes`
      });
    }

    NewVersion( $DBversion, 28490, "Bring back accidentally deleted relationship columns");
}
