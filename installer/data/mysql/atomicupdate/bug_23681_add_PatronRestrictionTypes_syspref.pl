use Modern::Perl;

return {
    bug_number => "23681",
    description => "Add PatronRestrictionTypes syspref",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};
        # Do you stuffs here
        $dbh->do(q{INSERT IGNORE INTO systempreferences (variable, value, explanation, options, type) VALUES ('PatronRestrictionTypes', '0', 'If enabled, it is possible to specify the "type" of patron restriction being applied.', '', 'YesNo');});
        # Print useful stuff here
        say $out "Update is going well so far";
    },
};