use Modern::Perl;

return {
    bug_number  => "30200",
    description => "Add ILLRequestsTabs system preference",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Do you stuffs here
        $dbh->do(
            q{
            INSERT IGNORE INTO `systempreferences`
                (variable,value,options,explanation,type)
            VALUES
                ('ILLRequestsTabs','','','Add customizable tabs to interlibrary loan requests list','Textarea');
        }
        );

    },
};
