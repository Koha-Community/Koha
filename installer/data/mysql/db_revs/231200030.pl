use Modern::Perl;

return {
    bug_number  => "35728",
    description => "Add option to NOT redirect to result when search returns only one record",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type) VALUES ('RedirectToSoleResult', '1', NULL, 'When a catalog search via the staff interface or the OPAC returns only one record, redirect to the result.', 'YesNo') }
        );

        say $out "Added system preference 'RedirectToSoleResult'";
    },
};
