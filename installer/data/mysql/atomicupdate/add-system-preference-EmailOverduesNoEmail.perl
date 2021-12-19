use Modern::Perl;
 
{
    bug_number => "20076",
    description => "Add system preference EmailOverduesNoEmail",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};
 
        $dbh->do(q{
            INSERT IGNORE INTO systempreferences (`variable`,`value`,`options`,`explanation`,`type`)
            VALUES ('EmailOverduesNoEmail','0','','Set mail sending to staff for patron has overdues but no email address', 'YesNo')
            });
    },
}
