use Modern::Perl;

return {
    bug_number  => "27753",
    description => "Automate resolution of return claim when checking in an item",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
                ('AutoClaimReturnStatusOnCheckin','','NULL','When in use this system preference will automatically resolve the claim return and will update the lost authorized value upon check in.','Free')}
        );

        say $out "Added new system preference 'AutoClaimReturnStatusOnCheckin'";

        $dbh->do(
            q{INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
                ('AutoClaimReturnStatusOnCheckout','','NULL','When in use this system preference will automatically resolve the claim return and will update the lost authorized value upon check out.','Free')}
        );

        say $out "Added new system preference 'AutoClaimReturnStatusOnCheckout'";
    },
};
