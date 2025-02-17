use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "39145",
    description => "Adjust preference ListOwnershipUponPatronDeletion",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{
            UPDATE systempreferences SET options='delete|transfer|transfer_public' WHERE variable = 'ListOwnershipUponPatronDeletion'
        }
        );
        say $out "Updated system preference 'ListOwnershipUponPatronDeletion'";
    },
};
