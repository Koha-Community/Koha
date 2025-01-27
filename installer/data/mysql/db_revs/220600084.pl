use Modern::Perl;

return {
    bug_number  => "32162",
    description => "Add primary key to erm_eholdings_packages_agreements",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};
        unless ( primary_key_exists('erm_eholdings_packages_agreements') ) {
            $dbh->do(
                q{
                ALTER TABLE erm_eholdings_packages_agreements
                DROP FOREIGN KEY erm_eholdings_packages_agreements_ibfk_1,
                DROP FOREIGN KEY erm_eholdings_packages_agreements_ibfk_2,
                DROP CONSTRAINT erm_eholdings_packages_agreements_uniq,
                ADD PRIMARY KEY(`package_id`, `agreement_id`)
            }
            );
            $dbh->do(
                q{
                ALTER TABLE erm_eholdings_packages_agreements
                ADD CONSTRAINT `erm_eholdings_packages_agreements_ibfk_1` FOREIGN KEY (`package_id`) REFERENCES `erm_eholdings_packages` (`package_id`) ON DELETE CASCADE ON UPDATE CASCADE,
                ADD CONSTRAINT `erm_eholdings_packages_agreements_ibfk_2` FOREIGN KEY (`agreement_id`) REFERENCES `erm_agreements` (`agreement_id`) ON DELETE CASCADE ON UPDATE CASCADE
            }
            );
        }
    },
};
