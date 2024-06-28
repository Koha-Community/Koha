use Modern::Perl;

return {
    bug_number  => "26205",
    description =>
        "Add new system preference OPACShowLibraries to control whether the libraries link appears in the OPAC",
    up => sub {
        my ($args) = @_;
        my $dbh = $args->{dbh};

        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences (variable, value, explanation, options, type)
            VALUES ('OPACShowLibraries', '1', 'If enabled, a "Libraries" link appears in the OPAC pointing to a page with library information', '', 'YesNo')
        }
        );
    },
    }
