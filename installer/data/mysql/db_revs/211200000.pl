use Modern::Perl;
use utf8;
use Encode qw( encode_utf8 );

return {
    bug_number  => undef,
    description => 'Increase DBRev for 21.12',
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        say $out encode_utf8 '📜 All that is gold does not glitter,';
        say $out encode_utf8 '📜 Not all those who wander are lost;';
        say $out encode_utf8 '📜 The old that is strong does not wither,';
        say $out encode_utf8 '📜 Deep roots are not reached by the frost.';
    },
    }
