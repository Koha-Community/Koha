package Koha::QueryParser::Driver::PQF::query_plan::node;
use base 'OpenILS::QueryParser::query_plan::node';

use strict;
use warnings;

=head1 NAME

Koha::QueryParser::Driver::PQF::query_plan::node - node subclass for PQF driver

=head1 FUNCTIONS

=head2 Koha::QueryParser::Driver::PQF::query_plan::node::target_syntax

    my $pqf = $node->target_syntax($server);

Transforms an OpenILS::QueryParser::query_plan::node object into PQF. Do not use directly.

=cut

sub target_syntax {
    my ($self, $server) = @_;
    my $pqf = '';
    my $atom_content;
    my $atom_count = 0;
    my @fields = ();
    my $fieldobj;
    my $relbump;

    if (scalar(@{$self->fields})) {
        foreach my $field (@{$self->fields}) {
            $fieldobj = $self->plan->QueryParser->bib1_mapping_by_name('field', $self->classname, $field, $server);
            $relbump = $self->plan->QueryParser->bib1_mapping_by_name('relevance_bump', $self->classname, $field, $server);
            if ($relbump) {
                $fieldobj->{'attr_string'} .= ' ' . $relbump->{'attr_string'};
            }
            push @fields, $fieldobj unless (!defined($fieldobj) || ($field eq $self->classname && @{$self->fields} > 1));
        }
    } else {
        $fieldobj = $self->plan->QueryParser->bib1_mapping_by_name('field', $self->classname, $self->classname, $server);
        my $relbumps = $self->plan->QueryParser->bib1_mapping_by_name('relevance_bump', $self->classname, '', $server);
        push @fields, $fieldobj;
        if ($relbumps) {
            foreach my $field (keys %$relbumps) {
                $relbump = $relbumps->{$field};
                $fieldobj = $self->plan->QueryParser->bib1_mapping_by_name('field', $relbump->{'classname'}, $relbump->{'field'}, $server);
                $fieldobj->{'attr_string'} ||= '';
                $fieldobj->{'attr_string'} .= ' ' . $relbump->{$server}{'attr_string'} if $relbump->{$server}{'attr_string'};
                push @fields, $fieldobj;
            }
        }
    }

    if (@{$self->phrases}) {
        foreach my $phrase (@{$self->phrases}) {
            if ($phrase) {
                $pqf .= ' @or ' x (scalar(@fields) - 1);
                foreach my $attributes (@fields) {
                    $pqf .= $attributes->{'attr_string'} . ($attributes->{'4'} ? '' : ' @attr 4=1') . ' "' . $phrase . '" ';
                }
                $atom_count++;
            }
        }
    } else {
        foreach my $atom (@{$self->query_atoms}) {
            if (ref($atom)) {
                $atom_content = $atom->target_syntax($server);
                if ($atom_content) {
                    $pqf .= ' @or ' x (scalar(@fields) - 1);
                    foreach my $attributes (@fields) {
                        $attributes->{'attr_string'} ||= '';
                        $pqf .= $attributes->{'attr_string'} . ($attributes->{'4'} ? '' : ' @attr 4=6 ') . $atom_content . ' ';
                    }
                    $atom_count++;
                }
            }
        }
    }
    $pqf = (OpenILS::QueryParser::_util::default_joiner eq '|' ? ' @or ' : ' @and ') x ($atom_count - 1) . $pqf;
    return ($self->negate ? '@not @attr 1=_ALLRECORDS @attr 2=103 "" ' : '') . $pqf;
}

1;
