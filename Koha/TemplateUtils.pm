package Koha::TemplateUtils;

# Copyright ByWater Solutions 2023
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

use Modern::Perl;

use Carp qw( croak );
use Try::Tiny;
use Template;

use C4::Context;

use vars qw(@ISA @EXPORT_OK);

BEGIN {
    require Exporter;
    @ISA       = qw(Exporter);
    @EXPORT_OK = qw( process_tt );
}

=head1 NAME

Koha::TemplateUtils

A module to centralize and standardize processing of template toolkit syntax
for uses other than slips and notices.

=head1 DESCRIPTION

Koha has evolved to use Template Toolkit for many uses outside of generating slips and notices for patrons. Historically, each of these areas processed template toolkit in a slightly different way. This module is meant to allow Template Toolkit syntax to be processed in a standard and generic way such that all non-notice TT syntax is handled and processed the consistently.

=head2 process_tt

$processed = process_tt($template, $vars);

Process the given Template Toolkit string, passing the given hashref of vars to the template, returning the processed string.

=cut

sub process_tt {
    my ( $template, $vars ) = @_;

    if ( index( $template, '[%' ) != -1 ) {    # Much faster than regex
        my $use_template_cache = C4::Context->config('template_cache_dir')
            && defined $ENV{GATEWAY_INTERFACE};

        my $tt = Template->new(
            {
                EVAL_PERL   => 1,
                ABSOLUTE    => 1,
                PLUGIN_BASE => 'Koha::Template::Plugin',
                COMPILE_EXT => $use_template_cache ? '.ttc'                                    : '',
                COMPILE_DIR => $use_template_cache ? C4::Context->config('template_cache_dir') : '',
                FILTERS     => {},
                ENCODING    => 'UTF-8',
            }
        ) or die Template->error();

        my $schema = Koha::Database->new->schema;
        my $output;

        $schema->txn_begin;
        try {
            $tt->process( \$template, $vars, \$output );
        } catch {
            croak "ERROR PROCESSING TEMPLATE: $_ :: " . $template->error();
        } finally {
            $schema->txn_rollback;
        };

        return $output;
    } else {
        return $template;
    }
}

=head1 AUTHOR

Kyle M Hall <kyle@bywatersolutions.com>

=cut

1;
