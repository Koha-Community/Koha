package Koha::QueryParser::Driver::PQF::query_plan::node::atom;
use base 'OpenILS::QueryParser::query_plan::node::atom';

use strict;
use warnings;

=head1 NAME

Koha::QueryParser::Driver::PQF::query_plan::node::atom - atom subclass for PQF driver

=head1 FUNCTIONS

=head2 Koha::QueryParser::Driver::PQF::query_plan::node::atom::target_syntax

    my $pqf = $atom->target_syntax($server);

Transforms an OpenILS::QueryParser::query_plan::node::atom object into PQF. Do not use
directly.

=cut

sub target_syntax {
    my ($self, $server) = @_;

    my $content = $self->content;
    $content =~ s/"/\\"/g;

    return ' "' .  $content . '" ';
}

1;
