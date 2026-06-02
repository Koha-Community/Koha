use Modern::Perl;
use utf8;
use Encode qw( encode_utf8 );

return {
    bug_number  => undef,
    description => 'Increase DBRev for 26.06',
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};
        say $out encode_utf8 '🤖 Work it harder';
        say $out encode_utf8 '🤖 Make it better';
        say $out encode_utf8 '🤖 Do it faster';
        say $out encode_utf8 '🦾 Makes us stronger';
    },
    }
