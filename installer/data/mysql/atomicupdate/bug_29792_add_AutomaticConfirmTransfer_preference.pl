use Modern::Perl;

return {
    bug_number => "29792",
    description => "Add AutomaticConfirmTransfer system preference",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};
        $dbh->do(q{
            INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
            ('AutomaticConfirmTransfer','0',NULL,'Defines whether transfers should be automatically confirmed at checkin if modal dismissed','YesNo')
        });
        # Print useful stuff here
        say $out "AutomaticConfirmTransfer system preference added";
    },
};
