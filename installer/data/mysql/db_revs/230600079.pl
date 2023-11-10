use Modern::Perl;

return {
    bug_number  => "12133",
    description => "Add system preference ChildNeedsGuarantor",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences (variable,value,explanation,options,type)
            VALUES('ChildNeedsGuarantor', 0, 'If ON, a child patron must have a guarantor when adding the patron.', '', 'YesNo');
        }
        );

        say $out "Added new system preference 'ChildNeedsGuarantor'";
    },
};
