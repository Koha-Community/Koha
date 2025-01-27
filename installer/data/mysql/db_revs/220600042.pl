use Modern::Perl;

return {
    bug_number  => "27981",
    description => "Make it possible to force 001 = biblionumber",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences (variable, value, options, explanation, type) VALUES ('autoControlNumber','OFF','biblionumber|OFF',
            'Used to autogenerate a Control Number: biblionumber will be as biblionumber; OFF will leave it as is','Choice');
        }
        );

        say $out "Added new system preference 'autoControlNumber'";
    },
};
