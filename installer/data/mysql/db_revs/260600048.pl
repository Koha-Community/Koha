use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "24535",
    description => "Increasing items.barcode length",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        my @tables   = qw/ items deleteditems pending_offline_operations tmp_holdsqueue /;
        my %comments = (
            items        => q{ COMMENT 'item barcode (MARC21 952$p)'},
            deleteditems => q{ COMMENT 'item barcode (MARC21 952$p)'},
        );
        my $new_length = 32;
        for my $table (@tables) {
            my $comment = $comments{$table} // '';
            $dbh->do(qq{ALTER TABLE $table MODIFY barcode VARCHAR($new_length)$comment});
        }

        say_success( $out, "barcode column length set to VARCHAR($new_length) in tables: " . join( ", ", @tables ) );
    },
};
