use Modern::Perl;
use utf8;
use Encode qw( encode_utf8 );

return {
    bug_number  => undef,
    description => 'Increase DBRev for 22.12',
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        say $out encode_utf8 '📜 Deep into that darkness peering, long I stood there wondering, fearing,';
        say $out encode_utf8 '📜 Doubting, dreaming dreams no mortal ever dared to dream before;';
        say $out encode_utf8 '📜 But the silence was unbroken, and the stillness gave no token';
    },
    }
