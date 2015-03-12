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

use Modern::Perl;
use Koha::DateUtils;
no warnings 'redefine';

sub plugin_javascript {
	# my ($dbh,$record,$tagslib,$field_number,$tabloop) = @_;
	my $function_name = "dateaccessioned".(int(rand(100000))+1);

    my $date = output_pref({ dt => dt_from_string, dateformat => 'iso', dateonly => 1 });

	# find the tag/subfield mapped to items.dateaccessioned
	my ($tag,$subfield) =  GetMarcFromKohaField("items.dateaccessioned","");
	my $res  = <<END_OF_JS;
<script type="text/javascript">
//<![CDATA[
//  
// from: cataloguing/value_builder/dateaccessioned.pl

function Focus$function_name(subfield_managed, id, force) {
    //var summary = "";
    //for (i=0 ; i<document.f.field_value.length ; i++) {
    //  summary += i + ": " + document.f.tag[i].value + " " + document.f.subfield[i].value + ": " + document.f.field_value[i].value + "\\n"; 
    //}
    //alert("Got focus, subfieldmanaged: " + subfield_managed + "\\n" + summary);
    set_to_today(id);
    return 0;
}

function Clic$function_name(id) {
    set_to_today(id, 1);
    return 0;
}

function set_to_today(id, force) {
    if (! id) { alert(_("Bad id ") + id + _(" sent to set_to_today()")); return 0; }
    if (\$("#" + id).val() == '' || \$("#" + id).val() == '0000-00-00' || force) {
        \$("#" + id).val("$date");
    }
}
//]]>
</script>
END_OF_JS
	return ($function_name, $res);
}
