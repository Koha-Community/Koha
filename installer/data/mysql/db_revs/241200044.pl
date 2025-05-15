use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "20747",
    description => "Allow LocalHoldsPriority to fill by hierarchical groups system rather than individual library ",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};
        my $local_holds_priority = C4::Context->preference('LocalHoldsPriority');

        # Do you stuffs here
        $dbh->do(
            q{
            UPDATE systempreferences
            SET options='GiveLibrary|None|GiveLibraryGroup|GiveLibraryAndGroup',
                value=CASE value WHEN '1' THEN 'GiveLibrary' ELSE 'None' END,
                type="Choice"
            WHERE variable="LocalHoldsPriority"
        },
        );

        say_success( $out, "Updated system preference 'LocalHoldsPriority'" );
    },
};
