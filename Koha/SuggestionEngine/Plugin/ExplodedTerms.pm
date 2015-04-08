package Koha::SuggestionEngine::Plugin::ExplodedTerms;

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

Koha::SuggestionEngine::Plugin::ExplodedTerms - suggest searches for broader/narrower/related subjects

=head1 SYNOPSIS


=head1 DESCRIPTION

Plugin to suggest expanding the search by adding broader/narrower/related
subjects to subject searches.

=cut

use strict;
use warnings;
use Carp;
use C4::Templates qw(gettemplate); # This is necessary for translatability

use base qw(Koha::SuggestionEngine::Base);

=head2 NAME
    my $name = $plugin->NAME;

=cut

sub NAME {
    return 'ExplodedTerms';
}

=head2 VERSION
    my $version = $plugin->VERSION;

=cut

sub VERSION {
    return '1.0';
}

=head2 get_suggestions

    my $suggestions = $plugin->get_suggestions(\%param);

Return suggestions for the specified search that add broader/narrower/related
terms to the search.

=cut

sub get_suggestions {
    my $self  = shift;
    my $param = shift;

    my $search = $param->{'search'};

    return if ( $search =~ m/^(ccl=|cql=|pqf=)/ );
    $search =~ s/(su|su-br|su-na|su-rl)[:=](\w*)/OP!$2/g;
    return if ( $search =~ m/\w+[:=]\w+/ );

    my @indexes = (
        'su-na',
        'su-br',
        'su-rl'
    );
    my $cgi = new CGI;
    my $template = C4::Templates::gettemplate('text/explodedterms.tt', 'opac', $cgi);
    my @results;
    foreach my $index (@indexes) {
        my $thissearch = $search;
        $thissearch = "$index=$thissearch"
          unless ( $thissearch =~ s/OP!/$index=/g );
        $template->{VARS}->{index} = $index;
        my $label = pack("U0a*", $template->output); #FIXME: C4::Templates is
        # returning incorrectly-marked UTF-8. This fixes the problem, but is
        # an annoying workaround.
        push @results,
        {
            'search'  => $thissearch,
            relevance => 100,
                # FIXME: it'd be nice to have some empirical measure of
                #        "relevance" in this case, but we don't.
            label => $label
        };
    } return \@results;
}

1;
