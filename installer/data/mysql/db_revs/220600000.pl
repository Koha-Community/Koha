use Modern::Perl;
use utf8;
use Encode qw( encode_utf8 );

return {
    bug_number  => undef,
    description => 'Increase DBRev for 22.06',
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        say $out encode_utf8 '📜 The road of excess';
        say $out encode_utf8 '📜 leads to the palace of wisdom;';
        say $out encode_utf8 '📜 for we never know what is enough';
        say $out encode_utf8 '📜 until we know what is more than enough.';
    },
    }
