package Koha::SearchEngine::Config;

use Moose;

use Moose::Util qw( apply_all_roles );

sub BUILD {
    my $self = shift;
    my $syspref = C4::Context->preference("SearchEngine");
    apply_all_roles( $self, "Koha::SearchEngine::${syspref}::Config" );
};
1;
