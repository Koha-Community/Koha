use Modern::Perl;

return {
    bug_number  => "26831",
    description => "Add new system preference PurgeListShareInvitesOlderThan",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type) VALUES ('PurgeListShareInvitesOlderThan', '14', NULL, 'If not empty, number of days used when deleting unaccepted list share invites', 'Integer') }
        );
    },
};
