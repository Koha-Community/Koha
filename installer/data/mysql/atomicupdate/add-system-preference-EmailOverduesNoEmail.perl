use Modern::Perl;
 
{
    bug_number => "20076",
    description => "Add system preference EmailOverduesNoEmail",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};
 
        $dbh->do(q{
            INSERT IGNORE INTO systempreferences (`variable`,`value`,`options`,`explanation`,`type`)
            VALUES ('EmailOverduesNoEmail','1','','Send send overdues of patrons without email address to staff', 'YesNo')
            });
    },
}
