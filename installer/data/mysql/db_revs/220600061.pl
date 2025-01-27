use Modern::Perl;

return {
    bug_number  => "31333",
    description => "Add the ability to limit purchase suggestions by patron category",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type) VALUES ('suggestionPatronCategoryExceptions', '', '', 'List the patron categories not affected by suggestion system preference if on', 'Free') }
        );
        say $out "Added new system preference 'suggestionPatronCategoryExceptions'";
    },
};
