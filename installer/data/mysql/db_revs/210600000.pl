use Modern::Perl;
use utf8;
use Encode qw( encode_utf8 );

return {
    bug_number  => undef,
    description => 'Increase DBRev for 21.06',
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        say $out encode_utf8 '🎵 Run, rabbit run. 🎶';
        say $out encode_utf8 'Dig that hole, forget the sun,';
        say $out encode_utf8 'And when at last the work is done';
        say $out encode_utf8 "Don't sit down it's time to dig another one.";
    },
    }
