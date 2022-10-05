use Modern::Perl;

return {
    bug_number => "31333",
    description => "Add new suggestionPatronCategoryExceptions system preference",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};

        $dbh->do(q{INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type) VALUES ('suggestionPatronCategoryExceptions', '', '', 'List the patron categories not affected by suggestion system preference if on', 'Free') });
    },
};
