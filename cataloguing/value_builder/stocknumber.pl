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
use warnings;
use C4::Context;

sub plugin_javascript {
	my ($dbh,$record,$tagslib,$field_number,$tabloop) = @_;
	my $function_name= "inventory".(int(rand(100000))+1);

	my $branchcode = C4::Context->userenv->{'branch'};

	my $query = "SELECT MAX(CAST(SUBSTRING_INDEX(stocknumber,'_',-1) AS SIGNED))+1 FROM items WHERE homebranch = ? AND stocknumber LIKE ?";
	my $sth=$dbh->prepare($query);

	$sth->execute($branchcode,$branchcode."_%");
	my ($nextnum) = $sth->fetchrow;
	$nextnum = $branchcode.'_'.$nextnum;

    my $scr = <<END_OF_JS;
if (\$('#' + id).val() == '' || force) {
    \$('#' + id).val('$nextnum');
}
END_OF_JS

    my $js  = <<END_OF_JS;
<script type="text/javascript">
//<![CDATA[

function Focus$function_name(subfield_managed, id, force) {
$scr
    return 0;
}

function Clic$function_name(id) {
    return Focus$function_name('not_relavent', id, 1);
}
//]]>
</script>
END_OF_JS
    return ($function_name, $js);
}
