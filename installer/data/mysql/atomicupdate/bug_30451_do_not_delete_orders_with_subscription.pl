use Modern::Perl;

return {
    bug_number  => "30451",
    description => "Update FK constraint on aqorders.subscriptionid to ON DELETE SET NULL",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        if ( foreign_key_exists( 'aqorders', 'aqorders_subscriptionid' ) ) {
            $dbh->do(q{
                ALTER TABLE aqorders
                DROP FOREIGN KEY aqorders_subscriptionid
            });
        }
        $dbh->do(q{
            ALTER TABLE aqorders
            ADD CONSTRAINT `aqorders_subscriptionid` FOREIGN KEY (`subscriptionid`) REFERENCES subscription(`subscriptionid`) ON DELETE SET NULL ON UPDATE CASCADE
        });
        say $out "Update FK constraint on subscriptionid";
    },
};
