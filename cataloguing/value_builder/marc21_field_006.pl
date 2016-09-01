#!/usr/bin/perl

# Converted to new plugin style (Bug 13437)

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

use Modern::Perl;
use C4::Auth;
use CGI qw ( -utf8 );
use C4::Context;

use C4::Search;
use C4::Output;

use XML::LibXML;

my $builder = sub {
    my ( $params ) = @_;
    my $function_name = $params->{id};
    my $res           = "
<script type=\"text/javascript\">
//<![CDATA[

function Click$function_name(event) {
    defaultvalue=document.getElementById(event.data.id).value;
    newin=window.open(\"../cataloguing/plugin_launcher.pl?plugin_name=marc21_field_006.pl&index=\"+ event.data.id +\"&result=\"+defaultvalue,\"tag_editor\",'width=1000,height=600,toolbar=false,scrollbars=yes');

}
//]]>
</script>
";

    return $res;
};

my $launcher = sub {
    my ( $params ) = @_;
    my $input = $params->{cgi};
    my $index   = $input->param('index');
    my $result  = $input->param('result');

    my $dbh = C4::Context->dbh;

    my ($template, $loggedinuser, $cookie) = get_template_and_user(
        {   template_name   => "cataloguing/value_builder/marc21_field_006.tt",
            query           => $input,
            type            => "intranet",
            authnotrequired => 0,
            flagsrequired   => { editcatalogue => '*' },
            debug           => 1,
        }
    );
    $result = "a|||||r|||| 00| 0 " unless $result;
    my $material_form_mapping = {
        a => 'BKS', t => 'BKS',
        c => 'MU', d => 'MU', i => 'MU', j => 'MU',
        e => 'MP', f => 'MP',
        g => 'VM', k => 'VM', o => 'VM', r => 'VM',
        m => 'CF',
        p => 'MX',
        s => 'CR',
    };
    my $material_code = substr(($result // ' '), 0, 1);
    my $material_configuration = $material_form_mapping->{$material_code};

    my $errorXml = '';
    # Check if the xml, xsd exists and is validated
    my $dir = C4::Context->config('intrahtdocs') . '/prog/' . $template->{lang} . '/data/';
    if (-r $dir . 'marc21_field_006.xml') {
        my $doc = XML::LibXML->new->parse_file($dir . 'marc21_field_006.xml');
        if (-r $dir . 'marc21_field_CF.xsd') {
            my $xmlschema = XML::LibXML::Schema->new(location => $dir . 'marc21_field_CF.xsd');
            eval {
                $xmlschema->validate( $doc );
            };
            $errorXml = 'Can\'t validate the xml data from ' . $dir . 'marc21_field_006.xml' if ($@);
        }
    } else {
        $errorXml = 'Can\'t read the xml file ' . $dir . 'marc21_field_006.xml';
    }
    $template->param(tagfield => '006',
            index => $index,
            result => $result,
            errorXml => $errorXml,
            material_configuration => $material_configuration,
    );
    output_html_with_http_headers $input, $cookie, $template->output;
};

return { builder => $builder, launcher => $launcher };
