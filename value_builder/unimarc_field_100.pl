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

sub plugin_javascript {
my ($dbh,$record,$tagslib,$field_number,$tabloop) = @_;
my $function_name= "100".(int(rand(100000))+1);
my $res="
<script>
function Focus$function_name(subfield_managed) {
return 1;
}

function Blur$function_name(subfield_managed) {
	return 1;
}

function Clic$function_name(i) {
	defaultvalue=document.forms[0].field_value[i].value;
	newin=window.open(\"../plugin_launcher.pl?plugin_name=unimarc_field_100.pl&index=\"+i+\"&result=\"+defaultvalue,\"unimarc field 100\",'width=500,height=400,toolbar=false,scrollbars=yes');

}
</script>
";

return ($function_name,$res);
}
sub plugin {
my ($input) = @_;
	my %env;

#	my $input = new CGI;
	my $index= $input->param('index');
	my $result= $input->param('result');


	my $dbh = C4::Context->dbh;

my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "value_builder/unimarc_field_100.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {parameters => 1},
			     debug => 1,
			     });
	my $f1 = substr($result,0,8);
	my $f2 = substr($result,8,1);
	my $f3 = substr($result,9,4);
	my $f4 = substr($result,13,4);
	$template->param(index => $index,
							f1 => $f1,
							f3 => $f3,
							"f2$f2" => $f2,
							f4 => $f4);
	print $input->header(-cookie => $cookie),$template->output;
}

1;
