package Koha::SuggestionEngine::Plugin::Null;

# Copyright 2012 C & P Bibliography Services
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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

=head1 NAME

Koha::SuggestionEngine::Plugin::Null - an example plugin that does nothing but allow us to run tests

=head1 SYNOPSIS


=head1 DESCRIPTION

Plugin to allow us to run unit tests and regression tests against the
SuggestionEngine.

=cut

use strict;
use warnings;
use Carp;

use base qw(Koha::SuggestionEngine::Base);

=head2 NAME
    my $name = $plugin->NAME;

=cut

sub NAME {
    return 'Null';
}

=head2 VERSION
    my $version = $plugin->VERSION;

=cut

sub VERSION {
    return '1.1';
}

=head2 get_suggestions

    my $suggestions = $suggestor->get_suggestions( {search => 'books');

Return a boring suggestion.

=cut

sub get_suggestions {
    my $self  = shift;
    my $param = shift;

    my @result = ();

    push @result, { search => 'book', label => 'Book!', relevance => 1 }
      if ( $param->{'search'} eq 'books' );

    return \@result;
}

1;
