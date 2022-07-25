use Modern::Perl;

use File::Slurp qw( read_file );
use JSON qw( from_json to_json );
use Encode qw( decode_utf8 );

our $lang = $ARGV[0] || 'en';
my $json = read_file(sprintf 'koha-tmpl/intranet-tmpl/prog/js/vue/locales/%s.json', $lang);
$lang =~ s|-.*||;
my $h = from_json($json);
my $i; my $size = scalar keys %$h;
my $translated = {};
while (my ($k, $v) = each %$h ){
    warn sprintf "%s - Translating string %s/%s\n", $lang, ++$i, $size;
    if ( ref($v) ) {
        for my $kk ( keys %$v ) {
            ( my $vv = $k ) =~ s|\s*$||;
            if ( $kk eq 'counter' ) {
                $translated->{$k}->{counter} = translate("$vv \%{counter}");
            } elsif ( $kk eq 'id' ) {
                $translated->{$k}->{id} = translate("$vv #\%{id}");
            } else {
                die "INVALID structure with key " . $kk;
            }
        }
    } elsif ( $k =~ /^There are no/ ) {
        $translated->{$k} = translate("$k.");
    }
    else {
        $translated->{$k} = translate($k);
    }
}

say to_json($translated, {utf8 => 1, pretty => 1, canonical => 1});

sub translate {
    my ( $string) = @_;
    my $translated = $string;
    return "/" if $string eq "/";
    if ( $lang ne 'en' ) {
        my $cmd = sprintf 'trans --brief :%s "%s"', $lang, $string;
        $translated = decode_utf8 qx{$cmd};
        chomp $translated;
    }
    return $translated;
}
