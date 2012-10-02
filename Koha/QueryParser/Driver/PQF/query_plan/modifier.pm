package Koha::QueryParser::Driver::PQF::query_plan::modifier;
use base 'OpenILS::QueryParser::query_plan::modifier';

use strict;
use warnings;

=head2 Koha::QueryParser::Driver::PQF::query_plan::modifier::target_syntax

    my $pqf = $modifier->target_syntax($server, $query_plan);

Transforms an OpenILS::QueryParser::query_plan::modifier object into PQF. Do not use
directly. The second argument points ot the query_plan, since modifiers do
not have a reference to their parent query_plan.

=cut

sub target_syntax {
    my ($self, $server, $query_plan) = @_;
    my $pqf = '';
    my @fields;

    my $attributes = $query_plan->QueryParser->bib1_mapping_by_name('modifier', $self->name, $server);
    $pqf = ($attributes->{'op'} ? $attributes->{'op'} . ' ' : '') . ($self->negate ? '@not @attr 1=_ALLRECORDS @attr 2=103 "" ' : '') . $attributes->{'attr_string'};
    return $pqf;
}

1;
