use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "39062",
    description => "Increase the size of items.stocknumber and deleteditems.stocknumber",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{ALTER TABLE items MODIFY COLUMN stocknumber varchar(80) DEFAULT NULL COMMENT 'inventory number (MARC21 952$i)'}
        );
        $dbh->do(
            q{ALTER TABLE deleteditems MODIFY COLUMN stocknumber varchar(80) DEFAULT NULL COMMENT 'inventory number (MARC21 952$i)'}
        );

        say_success( $out, "Increased length of items.stocknumber" );
        say_success( $out, "Increased length of deleteditems.stocknumber" );
    },
};
