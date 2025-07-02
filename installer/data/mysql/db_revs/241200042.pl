use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "39838",
    description => "Rename alias_id -> vendor_alias_id",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        if ( TableExists('aqbookseller_aliases') ) {
            if ( column_exists( 'aqbookseller_aliases', 'alias_id' ) ) {
                $dbh->do(
                    q{
                        ALTER TABLE aqbookseller_aliases CHANGE COLUMN alias_id vendor_alias_id INT(11);
                    }
                );
                say_success(
                    $out,
                    q{Column 'aqbookseller_aliases.alias_id' renamed to 'aqbookseller_aliases.vendor_alias_id'}
                );
            }
        }
    },
};
