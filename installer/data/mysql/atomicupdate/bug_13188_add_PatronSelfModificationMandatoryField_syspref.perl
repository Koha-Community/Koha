use Modern::Perl;

return {
    bug_number => "13188",
    description => "Allow configuration of required fields when a patron is editing their information via the OPAC",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};

       $dbh->do(q{
            INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` )
            SELECT 'PatronSelfModificationMandatoryField', value, NULL, 'Define the required fields when a patron is editing their information via the OPAC','multiple'
            FROM (SELECT value FROM systempreferences WHERE variable="PatronSelfRegistrationBorrowerMandatoryField") tmp
       });
    },
}
