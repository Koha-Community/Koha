use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "42447",
    description => "Convert SIP template fields to TEXT",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{
            ALTER TABLE `sip_accounts`
                MODIFY COLUMN `ae_field_template` TEXT DEFAULT NULL,
                MODIFY COLUMN `av_field_template` TEXT DEFAULT NULL,
                MODIFY COLUMN `da_field_template` TEXT DEFAULT NULL
        }
        );
        say_success( $out, "Converted sip_accounts template columns to TEXT" );

        $dbh->do(
            q{
            ALTER TABLE `sip_account_custom_item_fields`
                MODIFY COLUMN `template` TEXT NOT NULL COMMENT 'Template toolkit template'
        }
        );
        say_success( $out, "Converted sip_account_custom_item_fields.template to TEXT" );

        $dbh->do(
            q{
            ALTER TABLE `sip_account_custom_patron_fields`
                MODIFY COLUMN `template` TEXT NOT NULL COMMENT 'Template toolkit template'
        }
        );
        say_success( $out, "Converted sip_account_custom_patron_fields.template to TEXT" );
    },
};
