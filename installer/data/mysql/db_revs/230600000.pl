use Modern::Perl;
use utf8;
use Encode qw( encode_utf8 );

return {
    bug_number => undef,
    description => 'Increase DBRev for 23.06',
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};

        say $out encode_utf8 "📜 Another one bites the dust;";
        say $out encode_utf8 "📜 and another one gone and another one gone.";
        say $out encode_utf8 "📜 Another one bites the dust.";
        say $out encode_utf8 "📜 Hey I'm gonna get you too!";
        say $out encode_utf8 "📜 Another one bites the dust.";
    },
}
