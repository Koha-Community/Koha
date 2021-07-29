$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    $dbh->do(q{
        INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
        ('TwoFactorAuthentication', '0', 'NULL', 'Enables two-factor authentication', 'YesNo')
    });

    if( !column_exists( 'borrowers', 'secret' ) ) {
      $dbh->do(q{
          ALTER TABLE borrowers ADD COLUMN `secret` MEDIUMTEXT COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Secret for 2FA' AFTER `password`
      });
    }

    if( !column_exists( 'deletedborrowers', 'secret' ) ) {
      $dbh->do(q{
          ALTER TABLE deletedborrowers ADD COLUMN `secret` MEDIUMTEXT COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Secret for 2FA' AFTER `password`
        });
    }

    if( !column_exists( 'borrowers', 'auth_method' ) ) {
      $dbh->do(q{
          ALTER TABLE borrowers ADD COLUMN `auth_method` ENUM('password', 'two-factor') NOT NULL DEFAULT 'password' COMMENT 'Authentication method' AFTER `secret`
      });
    }

    if( !column_exists( 'deletedborrowers', 'auth_method' ) ) {
      $dbh->do(q{
          ALTER TABLE deletedborrowers ADD COLUMN `auth_method` ENUM('password', 'two-factor') NOT NULL DEFAULT 'password' COMMENT 'Authentication method' AFTER `secret`
      });
    }

    NewVersion( $DBversion, 28786, "Add new syspref TwoFactorAuthentication");
}
