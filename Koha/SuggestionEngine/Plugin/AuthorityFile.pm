package Koha::SuggestionEngine::Plugin::AuthorityFile;

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

Koha::SuggestionEngine::Plugin::AuthorityFile - get suggestions from the authority file

=head1 SYNOPSIS


=head1 DESCRIPTION

Plugin to get suggestions from Koha's authority file

=cut

use strict;
use warnings;
use Carp;

use base qw(Koha::SuggestionEngine::Base);

=head2 NAME
    my $name = $plugin->NAME;

=cut

sub NAME {
    return 'AuthorityFile';
}

=head2 VERSION
    my $version = $plugin->VERSION;

=cut

sub VERSION {
    return '1.1';
}

=head2 get_suggestions

    my $suggestions = $plugin->get_suggestions(\%param);

Return suggestions for the specified search by searching for the
search terms in the authority file and returning the results.

=cut

sub get_suggestions {
    my $self  = shift;
    my $param = shift;

    my $search = $param->{'search'};

    # Remove any CCL. This does not handle CQL or PQF, which is unfortunate,
    # but what can you do? At some point the search will have to be passed
    # not as a string but as some sort of data structure, at which point it
    # will be possible to support multiple search syntaxes.
    $search =~ s/ccl=//;
    $search =~ s/\w*[:=](\w*)/$1/g;

    my @marclist  = ['mainentry'];
    my @and_or    = ['and'];
    my @excluding = [];
    my @operator  = ['any'];
    my @value     = ["$search"];

    # FIXME: calling into C4
    require C4::AuthoritiesMarc;
    my ( $searchresults, $count ) = C4::AuthoritiesMarc::SearchAuthorities(
        @marclist,  @and_or, @excluding,       @operator,
        @value,      0,        $param->{'count'}, '',
        'Relevance', 0
    );

    my @results;
    foreach my $auth (@$searchresults) {
        push @results,
          {
            'search'  => "an=$auth->{'authid'}",
            relevance => $count--,
            label     => $auth->{summary}->{authorized}->[0]->{heading}
          };
    }
    return \@results;
}

1;
