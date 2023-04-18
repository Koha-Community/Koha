use Modern::Perl;

return {
    bug_number => "33557",
    description => "Add a system preference LinkerConsiderThesaurus",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};
        $dbh->do(q{
            INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
            ('LinkerConsiderThesaurus','0',NULL,'If ON the authority linker will only search for 6XX authorities from the same source as the heading','YesNo')
        });
        say $out "Added new system preference 'LinkerConsiderThesaurus'";
    },
};
