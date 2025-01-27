use Modern::Perl;

return {
    bug_number  => "29897",
    description => "Display author identifiers for researchers",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};
        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
            ('OPACAuthorIdentifiers','0','','Display author identifiers on the OPAC detail page','YesNo')
        }
        );

        say $out "Added new system preference 'OPACAuthorIdentifiers'";
    },
};
