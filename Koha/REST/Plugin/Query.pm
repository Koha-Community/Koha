package Koha::REST::Plugin::Query;

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

use Modern::Perl;

use Mojo::Base 'Mojolicious::Plugin';
use List::MoreUtils qw( any );
use Scalar::Util qw( reftype );
use JSON qw( decode_json );

use Koha::Exceptions;

=head1 NAME

Koha::REST::Plugin::Query

=head1 API

=head2 Mojolicious::Plugin methods

=head3 register

=cut

sub register {
    my ( $self, $app ) = @_;

=head2 Helper methods

=head3 extract_reserved_params

    my ( $filtered_params, $reserved_params ) = $c->extract_reserved_params($params);

Generates the DBIC query from the query parameters.

=cut

    $app->helper(
        'extract_reserved_params' => sub {
            my ( $c, $params ) = @_;

            my $reserved_params;
            my $filtered_params;
            my $path_params;

            my $reserved_words = _reserved_words();
            my @query_param_names = keys %{$c->req->params->to_hash};

            foreach my $param ( keys %{$params} ) {
                if ( grep { $param eq $_ } @{$reserved_words} ) {
                    $reserved_params->{$param} = $params->{$param};
                }
                elsif ( grep { $param eq $_ } @query_param_names ) {
                    $filtered_params->{$param} = $params->{$param};
                }
                else {
                    $path_params->{$param} = $params->{$param};
                }
            }

            return ( $filtered_params, $reserved_params, $path_params );
        }
    );

=head3 dbic_merge_sorting

    $attributes = $c->dbic_merge_sorting({ attributes => $attributes, params => $params });

Generates the DBIC order_by attributes based on I<$params>, and merges into I<$attributes>.

=cut

    $app->helper(
        'dbic_merge_sorting' => sub {
            my ( $c, $args ) = @_;
            my $attributes = $args->{attributes};
            my $result_set = $args->{result_set};

            my @order_by_styles = (
                '_order_by',
                '_order_by[]'
            );
            my @order_by_params;

            foreach my $order_by_style ( @order_by_styles ) {
                if ( defined $args->{params}->{$order_by_style} and ref($args->{params}->{$order_by_style}) eq 'ARRAY' )  {
                    push( @order_by_params, @{$args->{params}->{$order_by_style} });
                }
                else {
                    push @order_by_params, $args->{params}->{$order_by_style}
                        if defined $args->{params}->{$order_by_style};
                }
            }

            my @THE_order_by;

            foreach my $order_by_param ( @order_by_params ) {
                my $order_by;
                $order_by = [ split(/,/, $order_by_param) ]
                    if ( !reftype($order_by_param) && index(',',$order_by_param) == -1);

                if ($order_by) {
                    if ( reftype($order_by) and reftype($order_by) eq 'ARRAY' ) {
                        my @order_by = map { _build_order_atom({ string => $_, result_set => $result_set }) } @{ $order_by };
                        push( @THE_order_by, @order_by);
                    }
                    else {
                        push @THE_order_by, _build_order_atom({ string => $order_by, result_set => $result_set });
                    }
                }
            }

            $attributes->{order_by} = \@THE_order_by
                if scalar @THE_order_by > 0;

            return $attributes;
        }
    );

=head3 dbic_merge_prefetch

    $attributes = $c->dbic_merge_prefetch({ attributes => $attributes, result_set => $result_set });

Generates the DBIC prefetch attribute based on embedded relations, and merges into I<$attributes>.

=cut

    $app->helper(
        'dbic_merge_prefetch' => sub {
            my ( $c, $args ) = @_;
            my $attributes = $args->{attributes};
            my $result_set = $args->{result_set};
            my $embed = $c->stash('koha.embed');
            return unless defined $embed;

            my @prefetches;
            foreach my $key (sort keys(%{$embed})) {
                my $parsed = _parse_prefetch($key, $embed, $result_set);
                push @prefetches, $parsed if defined $parsed;
            }

            if(scalar(@prefetches)) {
                $attributes->{prefetch} = \@prefetches;
            }
        }
    );

=head3 _build_query_params_from_api

    my $params = _build_query_params_from_api( $filtered_params, $reserved_params );

Builds the params for searching on DBIC based on the selected matching algorithm.
Valid options are I<contains>, I<starts_with>, I<ends_with> and I<exact>. Default is
I<contains>. If other value is passed, a Koha::Exceptions::WrongParameter exception
is raised.

=cut

    $app->helper(
        'build_query_params' => sub {

            my ( $c, $filtered_params, $reserved_params ) = @_;

            my $params;
            my $match = $reserved_params->{_match} // 'contains';

            foreach my $param ( keys %{$filtered_params} ) {
                if ( $match eq 'contains' ) {
                    $params->{$param} =
                      { like => '%' . $filtered_params->{$param} . '%' };
                }
                elsif ( $match eq 'starts_with' ) {
                    $params->{$param} = { like => $filtered_params->{$param} . '%' };
                }
                elsif ( $match eq 'ends_with' ) {
                    $params->{$param} = { like => '%' . $filtered_params->{$param} };
                }
                elsif ( $match eq 'exact' ) {
                    $params->{$param} = $filtered_params->{$param};
                }
                else {
                    # We should never reach here, because the OpenAPI plugin should
                    # prevent invalid params to be passed
                    Koha::Exceptions::WrongParameter->throw(
                        "Invalid value for _match param ($match)");
                }
            }

            return $params;
        }
    );

=head3 merge_q_params

    $c->merge_q_params( $filtered_params, $q_params, $result_set );

Merges parameters from $q_params into $filtered_params.

=cut

    $app->helper(
        'merge_q_params' => sub {

            my ( $c, $filtered_params, $q_params, $result_set ) = @_;

            $q_params = decode_json($q_params) unless reftype $q_params;

            my $params = _parse_dbic_query($q_params, $result_set);

            return $params unless scalar(keys %{$filtered_params});
            return {'-and' => [$params, $filtered_params ]};
        }
    );

=head3 stash_embed

    $c->stash_embed();

Unwraps and stashes the x-koha-embed headers for use later query construction

=cut

    $app->helper(
        'stash_embed' => sub {

            my ( $c ) = @_;
            my $embed_header = $c->req->headers->header('x-koha-embed');
            if ($embed_header) {
                my $THE_embed = {};
                foreach my $embed_req ( split /\s*,\s*/, $embed_header ) {
                    if ( $embed_req eq '+strings' ) {    # special case
                        $c->stash( 'koha.strings' => 1 );
                    } else {
                        _merge_embed( _parse_embed($embed_req), $THE_embed );
                    }
                }

                $c->stash( 'koha.embed' => $THE_embed )
                  if $THE_embed;
            }

            return $c;
        }
    );

=head3 stash_overrides

    # Stash the overrides
    $c->stash_overrides();
    #Use it
    my $overrides = $c->stash('koha.overrides');
    if ( $overrides->{pickup_location} ) { ... }

This helper method parses 'x-koha-override' headers and stashes the passed overriders
in the for of a I<hashref> for easy use in controller methods.

FIXME: With the currently used JSON::Validator version we use, it is not possible to
use the validated and coerced data (it doesn't validate array-type headers) so this
implementation relies on manual parsing. Look at the JSON::Validator changelog for
reference: https://metacpan.org/changes/distribution/JSON-Validator#L14

=cut

    $app->helper(
        'stash_overrides' => sub {

            my ( $c ) = @_;

            my $override_header = $c->req->headers->header('x-koha-override') || q{};

            my $overrides = { map { $_ => 1 } split /\s*,\s*/, $override_header };

            $c->stash( 'koha.overrides' => $overrides );

            return $c;
        }
    );
}

=head2 Internal methods

=head3 _reserved_words

    my $reserved_words = _reserved_words();

=cut

sub _reserved_words {

    my @reserved_words = qw( _match _order_by _order_by[] _page _per_page q query x-koha-query x-koha-request-id x-koha-embed);
    return \@reserved_words;
}

=head3 _build_order_atom

    my $order_atom = _build_order_atom( $string );

Parses I<$string> and outputs data valid for using in SQL::Abstract order_by attribute
according to the following rules:

     string -> I<string>
    +string -> I<{ -asc => string }>
    -string -> I<{ -desc => string }>

=cut

sub _build_order_atom {
    my ( $args )   = @_;
    my $string     = $args->{string};
    my $result_set = $args->{result_set};

    my $param = $string;
    $param =~ s/^(\+|\-|\s)//;
    if ( $result_set ) {
        my $model_param = _from_api_param($param, $result_set);
        $param = $model_param if defined $model_param;
    }

    if ( $string =~ m/^\+/ or
         $string =~ m/^\s/ ) {
        # asc order operator present
        return { -asc => $param };
    }
    elsif ( $string =~ m/^\-/ ) {
        # desc order operator present
        return { -desc => $param };
    }
    else {
        # no order operator present
        return $param;
    }
}

=head3 _parse_embed

    my $embed = _parse_embed( $string );

Parses I<$string> and outputs data valid for passing to the Kohaa::Object(s)->to_api
method.

=cut

sub _parse_embed {
    my $string = shift;

    my $result;
    my ( $curr, $next ) = split /\s*\.\s*/, $string, 2;

    if ( $next ) {
        $result->{$curr} = { children => _parse_embed( $next ) };
    }
    else {
        if ( $curr =~ m/^(?<relation>.*)[\+|:]count/ ) {
            my $key = $+{relation} . "_count";
            $result->{$key} = { is_count => 1 };
        }
        elsif ( $curr =~ m/^(?<relation>.*)\+strings/ ) {
            my $key = $+{relation};
            $result->{$key} = { strings => 1 };
        }
        else {
            $result->{$curr} = {};
        }
    }

    return $result;
}

=head3 _merge_embed

    _merge_embed( $parsed_embed, $global_embed );

Merges the hash referenced by I<$parsed_embed> into I<$global_embed>.

=cut

sub _merge_embed {
    my ( $structure, $embed ) = @_;

    my ($root) = keys %{ $structure };

    if ( any { $root eq $_ } keys %{ $embed } ) {
        # Recurse
        _merge_embed( $structure->{$root}, $embed->{$root} );
    }
    else {
        # Embed
        $embed->{$root} = $structure->{$root};
    }
}

sub _parse_prefetch {
    my ( $key, $embed, $result_set) = @_;

    my $pref_key = $key;
    $pref_key =~ s/_count$// if $embed->{$key}->{is_count};
    return unless exists $result_set->prefetch_whitelist->{$pref_key};

    my $ko_class = $result_set->prefetch_whitelist->{$pref_key};
    return $pref_key unless defined $embed->{$key}->{children} && defined $ko_class;

    my @prefetches;
    foreach my $child (sort keys(%{$embed->{$key}->{children}})) {
        my $parsed = _parse_prefetch($child, $embed->{$key}->{children}, $ko_class->new);
        push @prefetches, $parsed if defined $parsed;
    }

    return $pref_key unless scalar(@prefetches);

    return {$pref_key => $prefetches[0]} if scalar(@prefetches) eq 1;

    return {$pref_key => \@prefetches};
}

sub _from_api_param {
    my ($key, $result_set) = @_;

    if($key =~ /\./) {

        my ($curr, $next) = split /\s*\.\s*/, $key, 2;

        return $curr.'.'._from_api_param($next, $result_set) if $curr eq 'me';

        my $ko_class = $result_set->prefetch_whitelist->{$curr};

        Koha::Exceptions::BadParameter->throw("Cannot find Koha::Object class for $curr")
            unless defined $ko_class;

        $result_set = $ko_class->new;

        if ($next =~ /\./) {
            return _from_api_param($next, $result_set);
        } else {
            return $curr.'.'.($result_set->from_api_mapping && defined $result_set->from_api_mapping->{$next} ? $result_set->from_api_mapping->{$next}:$next);
        }
    } else {
        return defined $result_set->from_api_mapping->{$key} ? $result_set->from_api_mapping->{$key} : $key;
    }
}

sub _parse_dbic_query {
    my ($q_params, $result_set) = @_;

    if(reftype($q_params) && reftype($q_params) eq 'HASH') {
        my $parsed_hash;
        foreach my $key (keys %{$q_params}) {
            if($key =~ /-?(not_?)?bool/i ) {
                $parsed_hash->{$key} = _from_api_param($q_params->{$key}, $result_set);
                next;
            }
            my $k = _from_api_param($key, $result_set);
            $parsed_hash->{$k} = _parse_dbic_query($q_params->{$key}, $result_set);
        }
        return $parsed_hash;
    } elsif (reftype($q_params) && reftype($q_params) eq 'ARRAY') {
        my @mapped = map{ _parse_dbic_query($_, $result_set) } @$q_params;
        return \@mapped;
    } else {
        return $q_params;
    }

}

1;
