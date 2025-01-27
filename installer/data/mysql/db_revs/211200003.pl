use Modern::Perl;

return {
    bug_number  => "29457",
    description => "Fee Cancellation records the wrong manager_id",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};
        say $out
            "WARNING: You may have some incorrect manager_id's recorded against account cancellation lines, please see bugzilla for details.";
        say $out "NOTE: You may already have this bugfix applied at an earlier upgrade.";
    },
    }
