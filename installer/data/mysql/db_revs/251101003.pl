use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "38876",
    description => "Typo in UpdateNotForLoanStatusOnCheckout description",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Do you stuffs here
        $dbh->do(
            q{UPDATE systempreferences set explanation="This is a list of value pairs. When an item is checked out, if its not for loan value matches the value on the left, then the items not for loan value will be updated to the value on the right. \nE.g. ''-1: 0'' will cause an item that was set to ''Ordered'' to now be available for loan. Each pair of values should be on a separate line." WHERE variable='UpdateNotForLoanStatusOnCheckout'}
        );

        # sysprefs
        say $out "Updated system preference 'UpdateNotForLoanStatusOnCheckout'";

    },
};
