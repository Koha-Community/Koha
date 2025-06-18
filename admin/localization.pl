#!/usr/bin/perl

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

use C4::Auth   qw( get_template_and_user );
use C4::Output qw( output_html_with_http_headers );

use Koha::Localization;
use Koha::Localizations;

use CGI qw( -utf8 );

my $query = CGI->new;

my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name => "admin/localization.tt",
        flagsrequired => { parameters => 'manage_itemtypes' },
        query         => $query,
        type          => "intranet",
    }
);

my $entity = $query->param('entity');
my $code   = $query->param('code');
my $rs     = Koha::Localizations->search( { entity => $entity, code => $code } );
my @translations;
while ( my $s = $rs->next ) {
    push @translations,
        {
        id          => $s->localization_id,
        entity      => $s->entity,
        code        => $s->code,
        lang        => $s->lang,
        translation => $s->translation,
        };
}

my $translated_languages = C4::Languages::getTranslatedLanguages();    # opac and intranet

$template->param(
    translations => \@translations,
    languages    => $translated_languages,
    entity       => $entity,
    code         => $code,
);

output_html_with_http_headers $query, $cookie, $template->output;
