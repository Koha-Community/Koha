use Modern::Perl;

return {
    bug_number  => "35386",
    description => "Add RESTAPIRenewalBranch preference",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
            ('RESTAPIRenewalBranch','apiuserbranch','itemhomebranch|patronhomebranch|checkoutbranch|apiuserbranch|none','Choose how the branch for an API renewal is recorded in statistics','Choice')
        }
        );

        say $out "Added new system preference 'RESTAPIRenewalBranch'";
    },
};
