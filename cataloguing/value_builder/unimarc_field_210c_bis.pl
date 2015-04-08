#!/usr/bin/perl

# Copyright 2000-2002 Katipo Communications
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

=head1 SYNOPSIS

This plugin is used to map isbn/editor with collection.
It need :
  in thesaurus, a category named EDITORS
  in this category, datas must be entered like following :
  isbn separator editor separator collection.
  for example :
  2204 -- Cerf -- Cogitatio fidei
  2204 -- Cerf -- Le Magistere de l'Eglise
  2204 -- Cerf -- Lectio divina
  2204 -- Cerf -- Lire la Bible
  2204 -- Cerf -- Pour lire
  2204 -- Cerf -- Sources chretiennes

  when the user clic on ... on 225a line, the popup shows the list of collections from the selected editor
  if the biblio has no isbn, then the search if done on editor only
  If the biblio ha an isbn, the search is done on isbn and editor. It's faster.

=cut

use strict;

#use warnings; FIXME - Bug 2505
use C4::Auth;
use CGI;
use C4::Context;

use C4::AuthoritiesMarc;
use C4::Output;

=head1 FUNCTIONS

=head2 plugin_parameters

plugin_parameters : other parameters added when the plugin is called by the dopop function

=cut

sub plugin_parameters {
    my ( $dbh, $record, $tagslib, $i, $tabloop ) = @_;
    return "";
}

sub plugin_javascript {
    my ( $dbh, $record, $tagslib, $field_number, $tabloop ) = @_;
    my $function_name = $field_number;
    my $res           = "
    <script type=\"text/javascript\">
        function Focus$function_name(subfield_managed) {
            return 1;
        }
    
        function Blur$function_name(subfield_managed) {
            return 1;
        }
    
        function Clic$function_name(index) {
            window.open(\"../cataloguing/plugin_launcher.pl?plugin_name=unimarc_field_210c_bis.pl&index=\"+index,\"unimarc210c\",'width=500,height=400,toolbar=false,scrollbars=no');
        }
    </script>
";

    return ( $function_name, $res );
}

sub plugin {
    my ($input)      = @_;
    my $index        = $input->param('index');
    my $result       = $input->param('result');
    my $editor_found = $input->param('editor_found');
    my $AuthoritySeparator = C4::Context->preference("AuthoritySeparator");

    my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
        {   template_name   => "cataloguing/value_builder/unimarc_field_210c_bis.tt",
            query           => $input,
            type            => "intranet",
            authnotrequired => 0,
            flagsrequired   => { editcatalogue => '*' },
            debug           => 1,
        }
    );

   $template->param(
        index      => $index,
    );
    output_html_with_http_headers $input, $cookie, $template->output;
}

1;
