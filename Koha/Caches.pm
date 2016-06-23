package Koha::Caches;

use Modern::Perl;
use Koha::Cache;

our $singleton_caches;
sub get_instance {
    my ($class, $subnamespace) = @_;
    $subnamespace //= '';
    $singleton_caches->{$subnamespace} = Koha::Cache->new({}, { subnamespace => $subnamespace } ) unless $singleton_caches->{$subnamespace};
    return $singleton_caches->{$subnamespace};
}

sub flush_L1_caches {
    return unless $singleton_caches;
    for my $cache ( values %$singleton_caches ) {
        $cache->flush_L1_cache;
    }
}

1;
