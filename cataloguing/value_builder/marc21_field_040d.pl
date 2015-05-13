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
use C4::Context;

sub plugin_javascript {
    my ($dbh,$record,$tagslib,$field_number,$tabloop) = @_;
    my $function_name = $field_number;

    my $org = C4::Context->preference('MARCOrgCode');
    my $res  = "
<script type=\"text/javascript\">
//<![CDATA[

function Focus$function_name(subfield_managed) {
    document.getElementById(\"$field_number\").value='$org';
    return 0;
}

//]]>
</script>
";
    return ($function_name,$res);
}
