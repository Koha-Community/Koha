use Modern::Perl;
use utf8;
use Encode qw( encode_utf8 );

return {
    bug_number  => undef,
    description => 'Increase DBRev for 23.12',
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};
        say $out encode_utf8 "📜 Bugs will happen. (Nick Clemens)";
        say $out encode_utf8 "📜 It's all about the people. (Chris Cormack)";
    },
    }
