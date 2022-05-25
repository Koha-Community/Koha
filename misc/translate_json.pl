use Modern::Perl;

use File::Slurp qw( read_file );
use JSON qw( from_json to_json );

my $json = read_file('koha-tmpl/intranet-tmpl/prog/js/vue/locales/en.json');
my $h = from_json($json);
my $translated = {};
while (my ($k, $v) = each %$h ){
    if ( ref($v) ) {
        for my $kk ( keys %$v ) {
            if ( $kk eq 'counter' ) {
                $translated->{$k}->{counter} = "$k \%{counter}";
            } elsif ( $kk eq 'id' ) {
                $translated->{$k}->{id} = "$k #\%{id}";
            } else {
                die "INVALID structure with key " . $kk;
            }
        }
    } else {
        if ( $k =~ /^There are no/ ) {
            $translated->{$k} = "$k."
        }
        else {
            $translated->{$k} = $k
        }
    }
}

say to_json($translated, {utf8 => 1, pretty => 1, canonical => 1});
