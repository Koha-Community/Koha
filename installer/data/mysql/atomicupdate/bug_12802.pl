use Modern::Perl;

return {
    bug_number  => '12802',
    description => 'Change type of system preference EmailFieldPrimary to multiple',
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do("UPDATE systempreferences SET type='multiple' WHERE variable='EmailFieldPrimary'");

        say $out "Updated system preference 'EmailFieldPrimary' to have type 'multiple'";
    },
};
