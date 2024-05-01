use Modern::Perl;

return {
    bug_number => "18317",
    description => "Allow check out of already checked out items through SIP"
    up => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(q{
            INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
            ('AllowItemsOnLoanCheckoutSIP','0','','Do not generate ISSUED_TO_ANOTHER warning when checking out items already checked out to someone else via SIP. This allows self checkouts for those items.','YesNo')
        });

        say $out "Added new system preference 'AllowItemsOnLoanCheckoutSIP'";
    },
};
