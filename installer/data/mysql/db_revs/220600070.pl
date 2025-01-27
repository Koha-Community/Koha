use Modern::Perl;

return {
    bug_number  => "31577",
    description => "Add category list pull-down to OpacHiddenItemsExceptions",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Do you stuffs here
        $dbh->do(
            q{
            UPDATE systempreferences SET value = REPLACE(value,"|",","),
            explanation = REPLACE(explanation,"separated by |,","separated by comma,")
            WHERE variable = "OpacHiddenItemsExceptions"
        }
        );

        # Print useful stuff here
        say $out "Updated system preference 'OpacHiddenItemsExceptions'";
    },
};
