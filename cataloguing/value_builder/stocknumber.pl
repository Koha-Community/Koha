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
use C4::Context;

my $builder = sub {
    my ( $params ) = @_;
    my $function_name = $params->{id};
    my $dbh = $params->{dbh};

	my $branchcode = C4::Context->userenv->{'branch'};

	my $query = "SELECT MAX(CAST(SUBSTRING_INDEX(stocknumber,'_',-1) AS SIGNED))+1 FROM items WHERE homebranch = ? AND stocknumber LIKE ?";
	my $sth=$dbh->prepare($query);

	$sth->execute($branchcode,$branchcode."_%");
	my ($nextnum) = $sth->fetchrow;
	$nextnum = $branchcode.'_'.$nextnum;

    my $js  = <<END_OF_JS;
<script>

function set_stocknumber(id, force) {
    if (\$('#' + id).val() == '' || force) {
        \$('#' + id).val('$nextnum');
    }
}

function Focus$function_name(event) {
    set_stocknumber(event.data.id, false);
}

function Click$function_name(event) {
    event.preventDefault();
    set_stocknumber(event.data.id, true);
}
</script>
END_OF_JS
    return $js;
};

return { builder => $builder };
