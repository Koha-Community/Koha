use Modern::Perl;
use utf8;
use Encode qw( encode_utf8 );

return {
    bug_number  => undef,
    description => 'Increase DBRev for 24.06',
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};
        say $out encode_utf8 "🎵 Mamma mia, here we go again!";
    },
    }
