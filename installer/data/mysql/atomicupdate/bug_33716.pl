use Modern::Perl;

return {
    bug_number  => "33716",
    description => "Add new ILLModuleDisclaimerByType system preference ",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{
                INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type) VALUES (
                    'ILLModuleDisclaimerByType', '', '', 'YAML defining disclaimer settings for each ILL request type',
                    'Textarea'
                );
            }
        );
        say $out "Added new system preference 'ILLModuleDisclaimerByType'";
    },
};
