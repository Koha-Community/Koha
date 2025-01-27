use Modern::Perl;

return {
    bug_number  => "13188",
    description => "Allow configuration of required fields when a patron is editing their information via the OPAC",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` )
            SELECT 'PatronSelfModificationMandatoryField', value, NULL, 'Define the required fields when a patron is editing their information via the OPAC','free'
            FROM (SELECT value FROM systempreferences WHERE variable='PatronSelfRegistrationBorrowerMandatoryField') tmp
        }
        );

        my ($syspref_value) = $dbh->selectrow_array(
            q{
            SELECT value FROM systempreferences WHERE variable='PatronSelfModificationMandatoryField'
        }
        );
        say $out "Added new system preference 'PatronSelfModificationMandatoryField' with value '$syspref_value'";
    },
    }
