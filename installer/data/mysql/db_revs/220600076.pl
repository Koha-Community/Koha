use Modern::Perl;

return {
    bug_number  => "29792",
    description => "Fix transfers created from 'wrong transfer' checkin are not sent if modal dismissed",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};
        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
            ('AutomaticConfirmTransfer','0',NULL,'Defines whether transfers should be automatically confirmed at checkin if modal dismissed','YesNo')
        }
        );

        say $out "Added new system preference 'AutomaticConfirmTransfer'";
    },
};
