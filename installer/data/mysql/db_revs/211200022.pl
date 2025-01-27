use Modern::Perl;

return {
    bug_number  => "11083",
    description => "Add syspref AuthorityXSLTResultsDisplay",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Do you stuffs here
        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences (`variable`, `value`, `options`, `explanation`, `type`) VALUES
            ('AuthorityXSLTResultsDisplay','','','Enable XSL stylesheet control over authority results page display on intranet','Free')
        }
        );
    },
};

