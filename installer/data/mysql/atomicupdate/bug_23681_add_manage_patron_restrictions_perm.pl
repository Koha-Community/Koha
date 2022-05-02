use Modern::Perl;

return {
    bug_number => "23681",
    description => "Add manage_patron_restrictions_permission",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};
        # Do you stuffs here
        $dbh->do(q{ INSERT IGNORE INTO permissions (module_bit, code, description) VALUES ( 3, 'manage_patron_restrictions', 'Manage patron restrictions')});
        # Print useful stuff here
        say $out "Update is going well so far";
    },
};