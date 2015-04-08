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

use constant FIXLEN_DATA_ELTS => '|| aca||aabn           | a|a     d';
use constant PREF_008 => 'MARCAuthorityControlField008';

=head1 DESCRIPTION

plugin_parameters : other parameters added when the plugin is called by the dopop function

=cut

# find today's date
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);

$year +=1900; $mon +=1;
my $dateentered = substr($year,2,2).sprintf ("%0.2d", $mon).sprintf ("%0.2d",$mday);
my $defaultval = Field008();

sub plugin_parameters {
    my ($dbh,$record,$tagslib,$i,$tabloop) = @_;
    return "";
}

sub plugin_javascript {
    my ($dbh,$record,$tagslib,$field_number,$tabloop) = @_;
    my $function_name= $field_number;
    my $res="
<script type=\"text/javascript\">
//<![CDATA[

function Focus$function_name(subfield_managed) {
    if (!document.getElementById(\"$field_number\").value) {
    var authtype=document.forms['f'].elements['authtypecode'].value;
    var fieldval='$dateentered$defaultval';
    if(authtype && (authtype == 'TOPIC_TERM' || authtype == 'GENRE/FORM' || authtype == 'CHRON_TERM')) {
      fieldval= fieldval.substr(0,14)+'b'+fieldval.substr(15);
    }
        document.getElementById(\"$field_number\").value=fieldval;
    }
    return 1;
}

function Blur$function_name(subfield_managed) {
    return 1;
}

function Clic$function_name(i) {
    var authtype=document.forms['f'].elements['authtypecode'].value;
    defaultvalue=document.getElementById(\"$field_number\").value;
    newin=window.open(\"../cataloguing/plugin_launcher.pl?plugin_name=marc21_field_008_authorities.pl&index=$field_number&result=\"+defaultvalue+\"&authtypecode=\"+authtype,\"tag_editor\",'width=1000,height=600,toolbar=false,scrollbars=yes');

}
//]]>
</script>
";

    return ($function_name,$res);
}
sub plugin {
    my ($input) = @_;
    my $index= $input->param('index');
    my $result= $input->param('result');
    my $authtype= $input->param('authtypecode')||'';
    substr($defaultval,14-6,1)='b' if $authtype=~ /TOPIC_TERM|GENRE.FORM|CHRON_TERM/;

    my $dbh = C4::Context->dbh;

    my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "cataloguing/value_builder/marc21_field_008_authorities.tt",
                 query => $input,
                 type => "intranet",
                 authnotrequired => 0,
                 flagsrequired => {editcatalogue => '*'},
                 debug => 1,
                 });
    $result = "$dateentered$defaultval" unless $result;
    my @f;
    for(0,6..17,28,29,31..33,38,39) {
        $f[$_]=substr($result,$_,$_==0?6:1);
    }
    $template->param(index => $index);

    $f[0]= $dateentered if !$f[0] || $f[0]=~/\s/;
    $template->param(f1 => $f[0]);

    for(6..17,28,29,31..33,38,39) {
        $template->param(
            "f$_" => $f[$_],
            "f$_".($f[$_] eq '|'? 'pipe': $f[$_]) => $f[$_],
        );
    }
    output_html_with_http_headers $input, $cookie, $template->output;
}

sub Field008 {
  my $pref= C4::Context->preference(PREF_008);
  if(!$pref) {
    return FIXLEN_DATA_ELTS;
  }
  elsif(length($pref)<34) {
    warn "marc21_field_008_authorities.pl: Syspref ".PREF_008." should be 34 characters long ";
    return FIXLEN_DATA_ELTS;
  }
  return substr($pref,0,34);  #ignore remainder
}

1;
