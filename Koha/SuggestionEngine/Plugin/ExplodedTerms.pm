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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

=head1 NAME

Koha::SuggestionEngine::Plugin::ExplodedTerms - suggest searches for broader/narrower/related subjects

=head1 SYNOPSIS

=cut

=head1 DESCRIPTION

Plugin to suggest expanding the search by adding broader/narrower/related
subjects to subject searches.

=cut

use Modern::Perl;

use base qw(Koha::SuggestionEngine::Base);

use Koha::I18N qw(__);

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
    my ( $self, $param ) = @_;

    my $search = $param->{'search'};

    return if ( $search =~ m/^(ccl=|cql=|pqf=)/ );
    $search =~ s/(su|su-br|su-na|su-rl)[:=](\w*)/OP!$2/g;
    return if ( $search =~ m/\w+[:=]\w+/ );

    my $indexes_to_label = {
        'su-na' => __('Search also for narrower subjects'),
        'su-br' => __('Search also for broader subjects'),
        'su-rl' => __('Search also for related subjects'),
    };

    my @results;
    foreach my $index ( keys %{$indexes_to_label} ) {
        my $thissearch = $search;
        $thissearch = "$index:$thissearch"
            unless ( $thissearch =~ s/OP!/$index:/g );
        push @results, {
            'search'  => $thissearch,
            relevance => 100,

            # FIXME: it'd be nice to have some empirical measure of
            #        "relevance" in this case, but we don't.
            label => $indexes_to_label->{$index}
        };
    }
    return \@results;
}

1;
