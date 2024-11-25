use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "33462",
    description => "Force password reset for new patrons entered by staff",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};
        $dbh->do(
            q{
        INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` )
VALUES ('ForcePasswordResetWhenSetByStaff', '0', NULL,'Force a staff created patron account to reset its password after its first OPAC login.', 'YesNo')
        }
        );
        say_success( $out, "Added new system preference 'ForcePasswordResetWhenSetByStaff'" );

        if ( !column_exists( 'categories', 'force_password_reset_when_set_by_staff' ) ) {
            $dbh->do(
                q{
                ALTER TABLE categories ADD COLUMN `force_password_reset_when_set_by_staff` TINYINT(1) NULL DEFAULT NULL
                COMMENT "if patrons of this category are required to reset password after being created by a staff member"
                AFTER `require_strong_password`
                }
            );
        }

        say_success( $out, "Added column 'categories.force_password_reset_when_set_by_staff'" );

    },
};
