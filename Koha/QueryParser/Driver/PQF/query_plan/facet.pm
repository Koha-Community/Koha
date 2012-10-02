package Koha::QueryParser::Driver::PQF::query_plan::facet;
use base 'OpenILS::QueryParser::query_plan::facet';

use strict;
use warnings;

=head2 Koha::QueryParser::Driver::PQF::query_plan::facet::target_syntax

    my $pqf = $facet->target_syntax($server);

Transforms an OpenILS::QueryParser::query_plan::facet object into PQF. Do not use
directly.

=cut

sub target_syntax {
    my ($self, $server) = @_;

    return '';
}

1;
