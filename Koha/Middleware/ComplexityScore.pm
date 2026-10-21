package Koha::Middleware::ComplexityScore;

# Copyright 2026 ByWater Solutions and the Koha Dev Team
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

use parent qw(Plack::Middleware);

use C4::Context;

use Plack::Util::Accessor qw( enabled header_name weights );

=head1 NAME

Koha::Middleware::ComplexityScore - Plack middleware to send a per-endpoint complexity score header

=head1 SYNOPSIS

  builder {
      ...
      enable "+Koha::Middleware::ComplexityScore";
      ...
  }

=head1 DESCRIPTION

This middleware adds a response header weighting each request by how expensive the
requested endpoint is. A reverse proxy or WAF (for example Cloudflare Rate Limiting
rules) can read the header and make heavy endpoints consume more of a client's rate
limit budget, so scrapers walking the catalog get throttled on the expensive pages
without blanket-limiting normal users.

The feature is disabled unless enabled in koha-conf.xml:

  <complexity_score_header>1</complexity_score_header>
  <complexity_score_header_name>x-complexity-score</complexity_score_header_name>

complexity_score_header_name is optional and defaults to 'x-complexity-score'.

The weights are a map keyed on the request's script name.
They are based on the number of searches, database calls, etc per script.

An instance can override or extend them in koha-conf.xml without editing this module:

  <complexity_score_weights>
    <opac-search.pl>30</opac-search.pl>
    <opac-detail.pl>25</opac-detail.pl>
  </complexity_score_weights>

Any script listed there replaces its default weight; scripts that are not listed keep their default.

=cut

our %DEFAULT_WEIGHTS = (
    'opac-search.pl'            => 25,
    'opac-detail.pl'            => 20,
    'opac-browse.pl'            => 15,
    'opac-shelves.pl'           => 12,
    'opac-MARCdetail.pl'        => 10,
    'opac-ISBDdetail.pl'        => 7,
    'opac-authoritiesdetail.pl' => 6,
    'opac-export.pl'            => 4,
    'opac-imageviewer.pl'       => 2,
    'opac-browser.pl'           => 2,
    'shelfbrowser.pl'           => 2,
);

=head1 METHODS

=head2 prepare_app

Reads the koha-conf.xml configuration once at Plack startup
so it doesn't have to be re-read on every request.

=cut

sub prepare_app {
    my ($self) = @_;

    $self->enabled( C4::Context->config('complexity_score_header') ? 1 : 0 );
    $self->header_name( C4::Context->config('complexity_score_header_name') || 'x-complexity-score' );

    my $overrides = C4::Context->config('complexity_score_weights');
    $overrides = {} unless ref $overrides eq 'HASH';
    $self->weights( { %DEFAULT_WEIGHTS, %$overrides } );
}

=head2 call

When the feature is enabled, sets the complexity score response
header based on the requested endpoint.

=cut

sub call {
    my ( $self, $env ) = @_;

    return $self->app->($env) unless $self->enabled;

    my $score = $self->score_for_path( $env->{PATH_INFO} );

    my $res = $self->app->($env);

    return Plack::Util::response_cb(
        $res,
        sub {
            my $res = shift;

            # $res is an arrayref [ response code, headers arrayref, body ]
            push @{ $res->[1] }, ( $self->header_name => $score );
        }
    );
}

=head2 score_for_path

  my $score = $self->score_for_path($path);

Returns the complexity weight for a request path.
Anything not in the configured weights gets the default weight of 1.

=cut

sub score_for_path {
    my ( $self, $path ) = @_;

    return 1 unless $path;

    # Plack runs the first script in the path and passes anything after it along as path info,
    # so score that script, otherwise 'opac-search.pl/' or 'opac-search.pl/foo' would score 1
    my ($script) = $path =~ m{
        ( [^/\\]+ \.pl )    # the first path segment naming a script
        (?: [/\\] | \z )    # followed by extra path info or the end of the path
    }x;

    return 1 unless $script;
    return $self->weights->{$script} // 1;
}

=head1 AUTHORS

Kyle M Hall <kyle@bywatersolutions.com>

=cut

1;
