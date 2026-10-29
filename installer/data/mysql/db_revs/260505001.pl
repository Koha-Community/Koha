use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "41318",
    description => "Rename system preference AmazonLocale to AmazonLocaleTld",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        my $pref_exists =
            $dbh->selectrow_array(q{SELECT COUNT(*) FROM systempreferences WHERE variable = "AmazonLocale"});
        if ($pref_exists) {
            $dbh->do(
                q{
                UPDATE systempreferences
                SET `variable`="AmazonLocaleTld",
                    `value` = CASE `value`
                            WHEN 'CA' THEN 'ca'
                            WHEN 'UK' THEN 'co.uk'
                            WHEN 'DE' THEN 'de'
                            WHEN 'FR' THEN 'fr'
                            WHEN 'IN' THEN 'in'
                            WHEN 'JP' THEN 'jp'
                            ELSE 'com'
                        END
                WHERE `variable`="AmazonLocale"
            }
            ) && say_info( $out, "Renamed system preference 'AmazonLocale' to 'AmazonLocaleTld" );
        }
    },
};
