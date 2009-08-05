#!/usr/bin/perl


# Copyright 2000-2002 Katipo Communications
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA

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

=over 2

=cut

use strict;
use C4::Auth;
use CGI;
use C4::Context;

use C4::AuthoritiesMarc;
use C4::Output;

=head1

plugin_parameters : other parameters added when the plugin is called by the dopop function

=cut

sub plugin_parameters {
    my ( $dbh, $record, $tagslib, $i, $tabloop ) = @_;
    return "";
}

sub plugin_javascript {
    my ( $dbh, $record, $tagslib, $field_number, $tabloop ) = @_;
    my $function_name = $field_number;
    my $res = "
    <script type=\"text/javascript\">
        function Focus$function_name(subfield_managed) {
            return 1;
        }
    
        function Blur$function_name(subfield_managed) {
            return 1;
        }
    
        function Clic$function_name(index) {
        // find the 010a value and the 210c. it will be used in the popup to find possibles collections
            var isbn_found   = 0;
            var editor_found = 0;
            
            var inputs = document.getElementsByTagName('input');
            
            for(var i=0 , len=inputs.length ; i \< len ; i++ ){
                if(inputs[i].id.match(/^tag_210_subfield_c_.*/)){
                    editor_found = inputs[i].value;
                }
                if(editor_found && isbn_found){
                    break;
                }
            }
                    
            defaultvalue = document.getElementById(\"$field_number\").value;
            window.open(\"../cataloguing/plugin_launcher.pl?plugin_name=unimarc_field_225a.pl&index=\"+index+\"&result=\"+defaultvalue+\"&editor_found=\"+editor_found,\"unimarc225a\",'width=500,height=200,toolbar=false,scrollbars=no');
    
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
    my $authoritysep = C4::Context->preference("authoritysep");
    
    my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
        {
            template_name =>
              "cataloguing/value_builder/unimarc_field_225a.tmpl",
            query           => $input,
            type            => "intranet",
            authnotrequired => 0,
            flagsrequired   => { editcatalogue => 1 },
            debug           => 1,
        }
    );

# builds collection list : search isbn and editor, in parent, then load collections from bibliothesaurus table
# if there is an isbn, complete search
    my @collections;
    
    my @value     = ($editor_found,"","");
    my @tags      = ("mainentry","","");
    my @and_or    = ('and','','');
    my @operator  = ('is','','');
    my @excluding = ('','','');
    
    
    my ($results,$total) = SearchAuthorities( \@tags,\@and_or,
                                            \@excluding, \@operator, \@value,
                                            0, 20,"EDITORS", "HeadingAsc");
    foreach my $editor (@$results){
        my $authority = GetAuthority($editor->{authid});
        foreach my $col ($authority->subfield('200','c')){
            push @collections, $col;
        }
            
    }

    #	my @collections = ["test"];
    my $collection = CGI::scrolling_list(
        -name     => 'f1',
        -values   => \@collections,
        -default  => "$result",
        -size     => 1,
        -multiple => 0,
    );
    $template->param(
        index      => $index,
        collection => $collection
    );
    output_html_with_http_headers $input, $cookie, $template->output;
}

1;
