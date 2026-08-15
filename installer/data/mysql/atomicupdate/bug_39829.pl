use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "39829",
    description => "Add SIP aj_field_template to allow customizing title info",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        unless ( column_exists( 'sip_accounts', 'aj_field_template' ) ) {
            $dbh->do(
                q{
                ALTER TABLE sip_accounts
                ADD COLUMN
                `aj_field_template` text NULL
                AFTER `ae_field_template`
            }
            );
            say $out "Added column 'sip_accounts.aj_field_template'";
        } else {
            say $out "Column already existed: 'sip_accounts.aj_field_template'";
        }
    },
};
