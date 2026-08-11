use Modern::Perl;

return {
    bug_number  => "41084",
    description => "Add EnableZotero system preference",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
            ('EnableZotero','1','','Enable Zotero export functionality','YesNo')
        }
        );

        say $out "Added new system preference 'EnableZotero'";
    },
};
