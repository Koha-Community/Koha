package Koha::Z3950Responder::RPN;

package Net::Z3950::RPN::Term;

# Copyright The National Library of Finland 2018
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

=head1 NAME

Koha::Z3950Responder::RPN

=head1 SYNOPSIS

Overrides for the C<Net::Z3950::RPN> classes adding a C<to_koha> method that
converts the query to a syntax that C<Koha::SearchEngine> understands.

=head1 DESCRIPTION

The method used here is described in C<samples/render-search.pl> of
C<Net::Z3950::SimpleServer>.

=cut

sub to_koha {
    my ( $self, $mappings ) = @_;

    my $attrs  = $self->{'attributes'};
    my $fields = $mappings->{use}{default};
    my $split  = 0;
    my $prefix = '';
    my $suffix = '';
    my $term   = $self->{'term'};
    utf8::decode($term);

    if ($attrs) {
        foreach my $attr (@$attrs) {
            if ( $attr->{'attributeType'} == 1 ) {    # use
                my $use = $attr->{'attributeValue'};
                $fields = $mappings->{use}{$use} if defined $mappings->{use}{$use};
            } elsif ( $attr->{'attributeType'} == 4 ) {    # structure
                $split = 1 if ( $attr->{'attributeValue'} == 2 );
            } elsif ( $attr->{'attributeType'} == 5 ) {    # truncation
                my $truncation = $attr->{'attributeValue'};
                $prefix = '*' if ( $truncation == 2 || $truncation == 3 );
                $suffix = '*' if ( $truncation == 1 || $truncation == 3 );
            }
        }
    }

    $fields = [$fields] unless !defined $fields || ref($fields) eq 'ARRAY';

    if ($split) {
        my @terms;
        foreach my $word ( split( /\s/, $term ) ) {
            $word =~ s/^[\,\.;:\\\/\"\'\-\=]+//g;
            $word =~ s/[\,\.;:\\\/\"\'\-\=]+$//g;
            next if ( !$word );
            $word = $self->escape($word);
            my @words;
            if ($fields) {
                foreach my $field ( @{$fields} ) {
                    push( @words, "$field:($prefix$word$suffix)" );
                }
            } else {
                push( @words, "($prefix$word$suffix)" );
            }
            push( @terms, join( ' OR ', @words ) );
        }
        return '(' . join( ' AND ', @terms ) . ')';
    }

    my @terms;
    $term = $self->escape($term);
    return "($prefix$term$suffix)" unless $fields;
    foreach my $field ( @{$fields} ) {
        push( @terms, "$field:($prefix$term$suffix)" );
    }
    return '(' . join( ' OR ', @terms ) . ')';
}

sub escape {
    my ( $self, $term ) = @_;

    $term =~ s/([()])/\\$1/g;
    return $term;
}

package Net::Z3950::RPN::And;

sub to_koha {
    my ( $self, $mappings ) = @_;

    return '(' . $self->[0]->to_koha($mappings) . ' AND ' . $self->[1]->to_koha($mappings) . ')';
}

package Net::Z3950::RPN::Or;

sub to_koha {
    my ( $self, $mappings ) = @_;

    return '(' . $self->[0]->to_koha($mappings) . ' OR ' . $self->[1]->to_koha($mappings) . ')';
}

package Net::Z3950::RPN::AndNot;

sub to_koha {
    my ( $self, $mappings ) = @_;

    return '(' . $self->[0]->to_koha($mappings) . ' NOT ' . $self->[1]->to_koha($mappings) . ')';
}

1;
