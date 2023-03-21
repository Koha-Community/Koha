use Modern::Perl;

return {
    bug_number  => "33260",
    description => "Show message queue on staff interface and make notices printable",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type) VALUES ('NoticesManagement', '0', NULL, 'Enable the interface to view and print generated notices', 'YesNo') }
        );

        say $out "Added system preference 'NoticesManagement'";
    },
};
