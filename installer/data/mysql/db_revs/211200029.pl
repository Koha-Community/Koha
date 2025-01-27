use Modern::Perl;

return {
    bug_number  => "30130",
    description => "A standard to edi_account",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};
        unless ( column_exists( 'vendor_edi_accounts', 'standard' ) ) {
            $dbh->do(
                q{
                ALTER TABLE vendor_edi_accounts ADD standard varchar(3) DEFAULT 'EUR' AFTER san
            }
            );

            $dbh->do(
                q{
                UPDATE vendor_edi_accounts SET standard = 'BIC' WHERE san IN ( '5013546025065', '9377779308820', '5013546031839' )
            }
            );
        }
    },
};
