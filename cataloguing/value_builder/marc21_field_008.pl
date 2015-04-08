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

use strict;
#use warnings; FIXME - Bug 2505
use C4::Auth;
use CGI;
use C4::Context;

use C4::Search;
use C4::Output;

use XML::LibXML;

=head1 DESCRIPTION

plugin_parameters : other parameters added when the plugin is called by the dopop function

=cut

# find today's date
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime(time);

$year += 1900;
$mon  += 1;
my $dateentered = substr($year, 2, 2) . sprintf("%0.2d", $mon) . sprintf("%0.2d", $mday);

sub plugin_parameters {
    my ($dbh, $record, $tagslib, $i, $tabloop) = @_;
    return "";
}

sub plugin_javascript {
    my $lang = C4::Context->preference('DefaultLanguageField008' );
    $lang = "eng" unless $lang;
    $lang = pack("A3", $lang);

    my ($dbh, $record, $tagslib, $field_number, $tabloop) = @_;
    my $function_name = $field_number;
    my $res           = "
<script type=\"text/javascript\">
//<![CDATA[

function Focus$function_name(subfield_managed) {
	if ( document.getElementById(\"$field_number\").value ) {
	}
	else {
        document.getElementById(\"$field_number\").value='$dateentered' + 'b        xxu||||| |||| 00| 0 $lang d';
	}
    return 1;
}

function Blur$function_name(subfield_managed) {
	return 1;
}

function Clic$function_name(i) {
	defaultvalue=document.getElementById(\"$field_number\").value;
    //Retrieve full leader string and pass it to the 008 tag editor
    var leader_value = \$(\"input[id^='tag_000']\").val();
    var leader_parameter = \"\";
    if (leader_value){
        //Only add the parameter to the URL if there is a value to add
        leader_parameter = \"&leader=\"+leader_value;
    }
    newin=window.open(\"../cataloguing/plugin_launcher.pl?plugin_name=marc21_field_008.pl&index=$field_number&result=\"+defaultvalue+leader_parameter,\"tag_editor\",'width=1000,height=600,toolbar=false,scrollbars=yes');

}
//]]>
</script>
";

    return ($function_name, $res);
}

sub plugin {
    my $lang = C4::Context->preference('DefaultLanguageField008' );
    $lang = "eng" unless $lang;
    $lang = pack("A3", $lang);

    my ($input) = @_;
    my $index   = $input->param('index');
    my $result  = $input->param('result');
    my $leader  = $input->param('leader');

    my $material_configuration;
    if ($leader && length($leader) == '24') {
        #MARC 21 Material Type Configuration
        #Field 008/18-34 Configuration
        #If Leader/06 = a and Leader/07 = a, c, d, or m: Books
        #If Leader/06 = a and Leader/07 = b, i, or s: Continuing Resources
        #If Leader/06 = t: Books
        #If Leader/06 = c, d, i, or j: Music
        #If Leader/06 = e, or f: Maps
        #If Leader/06 = g, k, o, or r: Visual Materials
        #If Leader/06 = m: Computer Files
        #If Leader/06 = p: Mixed Materials
        #http://www.loc.gov/marc/bibliographic/bdleader.html
        my $material_configuration_mapping = {
            a => {
                a => 'BKS',
                c => 'BKS',
                d => 'BKS',
                m => 'BKS',
                b => 'CR',
                i => 'CR',
                s => 'CR',
            },
            t => 'BKS',
            c => 'MU',
            d => 'MU',
            i => 'MU',
            j => 'MU',
            e => 'MP',
            f => 'MP',
            g => 'VM',
            k => 'VM',
            o => 'VM',
            r => 'VM',
            m => 'CF',
            p => 'MX',
        };
        my $leader06 = substr($leader, 6, 1);
        my $leader07 = substr($leader, 7, 1);
        #Retrieve material type using leader06
        $material_configuration = $material_configuration_mapping->{$leader06};
        #If the value returned is a ref (i.e. leader06 is 'a'), then use leader07 to get the actual material type
        if ( ($material_configuration) && (ref($material_configuration) eq 'HASH') ){
            $material_configuration = $material_configuration->{$leader07};
        }
    }

    my $dbh = C4::Context->dbh;

    my ($template, $loggedinuser, $cookie) = get_template_and_user(
        {   template_name   => "cataloguing/value_builder/marc21_field_008.tt",
            query           => $input,
            type            => "intranet",
            authnotrequired => 0,
            flagsrequired   => { editcatalogue => '*' },
            debug           => 1,
        }
    );

    $result = "$dateentered" . "b        xxu||||| |||| 00| 0 $lang d" unless $result;
    my $errorXml = '';
    # Check if the xml, xsd exists and is validated
    my $dir = C4::Context->config('intrahtdocs') . '/prog/' . $template->{lang} . '/data/';
    if (-r $dir . 'marc21_field_008.xml') {
        my $doc = XML::LibXML->new->parse_file($dir . 'marc21_field_008.xml');
        if (-r $dir . 'marc21_field_CF.xsd') {
            my $xmlschema = XML::LibXML::Schema->new(location => $dir . 'marc21_field_CF.xsd');
            eval {
                $xmlschema->validate( $doc );
            };
            $errorXml = 'Can\'t validate the xml data from ' . $dir . 'marc21_field_008.xml' if ($@);
        }
    } else {
        $errorXml = 'Can\'t read the xml file ' . $dir . 'marc21_field_008.xml';
    }
    $template->param(tagfield => '008',
            index => $index,
            result => $result,
            errorXml => $errorXml,
            material_configuration => $material_configuration,
    );
    output_html_with_http_headers $input, $cookie, $template->output;
}

1;
