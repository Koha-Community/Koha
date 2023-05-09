use Modern::Perl;

return {
    bug_number => "33673",
    description => "Change \"global system preferences\" to \"system preferences\"",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};
        $dbh->do(q{ UPDATE permissions SET description = 'Manage system preferences' WHERE code = 'manage_sysprefs' });
        say $out "Updated manage_sysprefs permission description.";
    },
};
