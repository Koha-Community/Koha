package Koha::SearchEngine::Index;
use Moose;

use Moose::Util qw( apply_all_roles );

sub BUILD {
    my $self = shift;
    my $syspref = 'Solr';
    apply_all_roles( $self, "Koha::SearchEngine::${syspref}::Index" );
};
1;
