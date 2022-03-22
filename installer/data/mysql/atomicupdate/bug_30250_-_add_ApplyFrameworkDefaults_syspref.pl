use Modern::Perl;

return {
    bug_number => "30250",
    description => "Add new system preference ApplyFrameworkDefaults",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};

        $dbh->do(q{INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type) VALUES ('ApplyFrameworkDefaults', 'new', "new|duplicate|changed|imported", "Configure when to apply framework default values - when cataloguing a new record, or when editing a record as new (duplicating), or when changing framework, or when importing a record", 'multiple') });
    },
};
