use Modern::Perl;

return {
    bug_number => "29948",
    description => "Display author information for researchers",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};
        $dbh->do(q{
            INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
            ('OPACAuthorInformation','0','','Display author information on the OPAC detail page','multiple_sortable')
        });

        say $out "Added new system preference 'OPACAuthorInformation'";
    },
};
