package C4::Csv;

# Copyright 2008 BibLibre
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
#
#

#use strict;
#use warnings; FIXME - Bug 2505

use C4::Context;
use vars qw(@ISA @EXPORT);


@ISA = qw(Exporter);

# only export API methods

@EXPORT = qw(
  &GetCsvProfile
  &GetMarcFieldsForCsv
);


# Returns all informations about a given csv profile
sub GetCsvProfile {
    my ($id) = @_;
    my $dbh = C4::Context->dbh;
    my $query = "SELECT * FROM export_format WHERE export_format_id=?";

    $sth = $dbh->prepare($query);
    $sth->execute($id);

    return ($sth->fetchrow_hashref);
}

# Returns fields to extract for the given csv profile
sub GetMarcFieldsForCsv {

    my ($id) = @_;
    my $dbh = C4::Context->dbh;
    my $query = "SELECT content FROM export_format WHERE export_format_id=?";

    $sth = $dbh->prepare($query);
    $sth->execute($id);

    return ($sth->fetchrow_hashref)->{content};
    
 
}


1;
