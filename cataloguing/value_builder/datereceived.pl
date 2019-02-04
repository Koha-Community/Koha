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
use C4::Biblio qw/GetMarcFromKohaField/;
use Koha::DateUtils;

my $builder = sub {
    my ( $params ) = @_;
    my $function_name = $params->{id};

    my $date = output_pref({ dt => dt_from_string, dateformat => 'iso', dateonly => 1 });

	# find the tag/subfield mapped to items.dateaccessioned
	my ($tag,$subfield) =  GetMarcFromKohaField("items.dateaccessioned","");
	my $res  = <<END_OF_JS;
<script type="text/javascript">
//<![CDATA[
//  
// from: cataloguing/value_builder/datereceived.pl

function Focus$function_name(event) {
    set_to_today(event.data.id);
}

function Click$function_name(event) {
    set_to_today(event.data.id);
    return false; // prevent page scroll
}

function set_to_today( id ) {
    if (! id) { alert(_("Bad id ") + id + _(" sent to set_to_today()")); return 0; }
    if (\$("#" + id).val() == '' || \$("#" + id).val() == '0000-00-00' ) {
        \$("#" + id).val("$date");
    }
}
//]]>
</script>
END_OF_JS
    return $res;
};

return { builder => $builder };
