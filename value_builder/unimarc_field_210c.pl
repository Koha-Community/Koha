#!/usr/bin/perl

# $Id$

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

use strict;
use C4::Auth;
use CGI;
use C4::Context;
use HTML::Template;
use C4::Search;
use C4::Output;

=head1

plugin_parameters : other parameters added when the plugin is called by the dopop function

=cut
sub plugin_parameters {
my ($dbh,$record,$tagslib,$i,$tabloop) = @_;
return "";
}

=head1

plugin_javascript : the javascript function called when the user enters the subfield.
contain 3 javascript functions :
* one called when the field is entered (OnFocus). Named FocusXXX
* one called when the field is leaved (onBlur). Named BlurXXX
* one called when the ... link is clicked (<a href="javascript:function">) named ClicXXX

returns :
* XXX
* a variable containing the 3 scripts.
the 3 scripts are inserted after the <input> in the html code

=cut
sub plugin_javascript {
my ($dbh,$record,$tagslib,$field_number,$tabloop) = @_;
my $function_name= "210c".(int(rand(100000))+1);
#---- build editors list.
#---- the editor list is built from the "EDITORS" thesaurus
#---- this thesaurus category must be filled as follow :
#---- isbn_identifier authorityseparator editor authorityseparator collection
#---- sample : 2224 -- Cerf -- Sources chrétiennes
my $sth = $dbh->prepare("select father,stdlib from bibliothesaurus where category='EDITORS' and level=2");
$sth->execute;
my @editors;
my $authoritysep = C4::Context->preference("authoritysep");
while (my ($father,$stdlib) = $sth->fetchrow) {
	push(@editors,"$father $stdlib");
}
my $res  = "
<script>
function Focus$function_name(index) {
var isbn_array = [ ";
foreach my $editor (@editors) {
	my @arr = split (/ $authoritysep /,$editor);
	$res .='["'.$arr[0].'","'.$arr[1].'","'.$arr[2].'"],';
}
chop $res;
$res .= "
];
	// search isbn subfield. it''s 010a
	var isbn_found;
	for (i=0 ; i<document.f.field_value.length ; i++) {
		if (document.f.tag[i].value == '010' && document.f.subfield[i].value == 'a') {
			isbn_found=document.f.field_value[i].value;
		}
	}
	for (i=0;i<=isbn_array.length;i++) {
		if (isbn_found.substr(0,isbn_array[i][0].length) == isbn_array[i][0]) {
			document.f.field_value[index].value =isbn_array[i][1];
		}
	}
}

function Blur$function_name(subfield_managed) {
	return 1;
}

function Clic$function_name(subfield_managed) {
	defaultvalue=escape(document.forms[0].field_value[subfield_managed].value);
	newin=window.open(\"../plugin_launcher.pl?plugin_name=unimarc_field_210c.pl&result=\"+defaultvalue+\"&index=$field_number\",\"value builder\",'width=500,height=400,toolbar=false,scrollbars=yes');

}
</script>
";
return ($function_name,$res);
}

=head1

plugin : the true value_builded. The screen that is open in the popup window.

=cut

sub plugin {
my ($input) = @_;
	my $index = $input->param("index");
	my $result =  $input->param("result");
	$result=~s/ /&nbsp;/g;
	$result=~s/"/&quot;/g;
	print "Content-Type: text/html\n\n<META HTTP-EQUIV=Refresh CONTENT=\"0; URL=thesaurus_popup.pl?category=EDITORS&nohierarchy=1&index=$index&result=$result\"></html>";
	exit;
}

1;
