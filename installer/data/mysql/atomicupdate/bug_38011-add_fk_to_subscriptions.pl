use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_failure say_success say_info);

return {
    bug_number  => "38011",
    description => "Add missing foreign key to subscription table",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        unless ( foreign_key_exists( 'subscription', 'subscription_ibfk_4' ) ) {

            $dbh->do(
                q{
                ALTER TABLE subscription MODIFY COLUMN aqbooksellerid int(11) DEFAULT NULL COMMENT 'foreign key for aqbooksellers.id to link to the vendor'
            }
            );

            $dbh->do(
                q|
                ALTER TABLE subscription
                ADD CONSTRAINT  subscription_ibfk_4
                    FOREIGN KEY (aqbooksellerid)
                    REFERENCES aqbooksellers (id) ON DELETE SET NULL ON UPDATE CASCADE
            |
            );
            say_success( $out, "Updated foreign key 'subscription_ibfk_4'" );
        } else {
            say_warning( $out, "Foreign key 'subscription_ibfk_4' already exists" );
        }
    },
};
