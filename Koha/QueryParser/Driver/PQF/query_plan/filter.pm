package Koha::QueryParser::Driver::PQF::query_plan::filter;
use base 'OpenILS::QueryParser::query_plan::filter';

use strict;
use warnings;

=head2 Koha::QueryParser::Driver::PQF::query_plan::filter::target_syntax

    my $pqf = $filter->target_syntax($server);

Transforms an OpenILS::QueryParser::query_plan::filter object into PQF. Do not use
directly.

=cut

sub target_syntax {
    my ($self, $server) = @_;
    my $attributes = $self->plan->QueryParser->bib1_mapping_by_name( 'filter', $self->name, $server );

    if ($attributes->{'target_syntax_callback'}) {
        return $attributes->{'target_syntax_callback'}->($self->plan->QueryParser, $self->name, $self->args, $self->negate, $server);
    } else {
        return '';
    }
}

1;
