use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_failure say_success say_info);

return {
    bug_number  => "37711",
    description => "Allow setting auto-register per interface (identity providers)",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        if ( !column_exists( 'identity_provider_domains', 'auto_register_opac' ) ) {
            $dbh->do(
                q{
                ALTER TABLE identity_provider_domains
                    ADD COLUMN `auto_register_opac` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Allow user auto register (OPAC)'
                        AFTER `allow_staff`;
            }
            );
            say_success( $out, "Added column 'identity_provider_domains.auto_register_opac'" );
        }

        if ( !column_exists( 'identity_provider_domains', 'auto_register_staff' ) ) {
            $dbh->do(
                q{
                ALTER TABLE identity_provider_domains
                    ADD COLUMN `auto_register_staff` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Allow user auto register (Staff interface)'
                        AFTER `auto_register_opac`;
            }
            );
            say_success( $out, "Added column 'identity_provider_domains.auto_register_staff'" );
        }

        # if this is a sane upgrade, then the column exists and to keep the current
        # behavior we only enable OPAC auto-register, if enabled previously
        if ( column_exists( 'identity_provider_domains', 'auto_register' ) ) {
            $dbh->do(
                q{
                UPDATE identity_provider_domains
                SET auto_register_opac=auto_register;
            }
            );

            $dbh->do(
                q{
                ALTER TABLE identity_provider_domains
                    DROP COLUMN `auto_register`;
            }
            );
            say_success( $out, "Removed column 'identity_provider_domains.auto_register'" );
        }
    },
};
