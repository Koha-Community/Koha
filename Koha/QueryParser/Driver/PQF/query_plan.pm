package Koha::QueryParser::Driver::PQF::query_plan;
use base 'OpenILS::QueryParser::query_plan';

use strict;
use warnings;

=head2 Koha::QueryParser::Driver::PQF::query_plan::target_syntax

    my $pqf = $query_plan->target_syntax($server);

Transforms an OpenILS::QueryParser::query_plan object into PQF. Do not use directly.

=cut

sub target_syntax {
    my ($self, $server) = @_;
    my $pqf = '';
    my $node_pqf;
    my $node_count = 0;

    for my $node ( @{$self->query_nodes} ) {

        if (ref($node)) {
            $node_pqf = $node->target_syntax($server);
            $node_count++ if $node_pqf;
            $pqf .= $node_pqf;
        }
    }
    $pqf = ($self->joiner eq '|' ? ' @or ' : ' @and ') x ($node_count - 1) . $pqf;
    $node_count = ($node_count ? '1' : '0');
    for my $node ( @{$self->filters} ) {
        if (ref($node)) {
            $node_pqf = $node->target_syntax($server);
            $node_count++ if $node_pqf;
            $pqf .= $node_pqf;
        }
    }
    $pqf = ($self->joiner eq '|' ? ' @or ' : ' @and ') x ($node_count - 1) . $pqf;
    foreach my $modifier ( @{$self->modifiers} ) {
        my $modifierpqf = $modifier->target_syntax($server, $self);
        $pqf = $modifierpqf . ' ' . $pqf if $modifierpqf;
    }
    return ($self->negate ? '@not @attr 1=_ALLRECORDS @attr 2=103 "" ' : '') . $pqf;
}

1;
