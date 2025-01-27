use Modern::Perl;

return {
    bug_number  => "26205",
    description => "Add new system preference NewsLog to log news changes",
    up          => sub {
        my ($args) = @_;
        my $dbh = $args->{dbh};

        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences (variable, value, explanation, options, type)
            VALUES ('NewsLog', '0', 'If enabled, log OPAC News changes', '', 'YesNo')
        }
        );
    },
    }
