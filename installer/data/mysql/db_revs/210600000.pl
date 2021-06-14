use Modern::Perl;
use utf8;

{
    bug_number => undef,
    description => 'Increase DBRev for 21.06',
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};

        say $out '🎵 Run, rabbit run. 🎶';
        say $out 'Dig that hole, forget the sun,';
        say $out 'And when at last the work is done';
        say $out "Don't sit down it's time to dig another one.";
    },
}
