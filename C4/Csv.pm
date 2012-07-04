package C4::Csv;

# Copyright 2008 BibLibre
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
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#
#

#use strict;
#use warnings; FIXME - Bug 2505

use C4::Context;
use vars qw($VERSION @ISA @EXPORT);

# set the version for version checking
$VERSION = 3.07.00.049;

@ISA = qw(Exporter);

# only export API methods

@EXPORT = qw(
  &GetCsvProfiles
  &GetCsvProfile
  &GetCsvProfileId
  &GetCsvProfilesLoop
  &GetMarcFieldsForCsv
);


# Returns all informations about csv profiles
sub GetCsvProfiles {
    my $dbh = C4::Context->dbh;
    my $query = "SELECT * FROM export_format";

    $sth = $dbh->prepare($query);
    $sth->execute;

    $sth->fetchall_arrayref({});

}

# Returns all informations about a given csv profile
sub GetCsvProfile {
    my ($id) = @_;
    my $dbh = C4::Context->dbh;
    my $query = "SELECT * FROM export_format WHERE export_format_id=?";

    $sth = $dbh->prepare($query);
    $sth->execute($id);

    return ($sth->fetchrow_hashref);
}

# Returns id of csv profile about a given csv profile name
sub GetCsvProfileId {
    my ($name)  = @_;
    my $dbh   = C4::Context->dbh;
    my $query = "SELECT export_format_id FROM export_format WHERE profile=?";

    $sth = $dbh->prepare($query);
    $sth->execute($name);

    return ( $sth->fetchrow );
}

# Returns fields to extract for the given csv profile
sub GetMarcFieldsForCsv {

    my ($id) = @_;
    my $dbh = C4::Context->dbh;
    my $query = "SELECT marcfields FROM export_format WHERE export_format_id=?";

    $sth = $dbh->prepare($query);
    $sth->execute($id);

    return ($sth->fetchrow_hashref)->{marcfields};
    
 
}

# Returns informations aboout csv profiles suitable for html templates
sub GetCsvProfilesLoop {
   # List of existing profiles
    my $dbh = C4::Context->dbh;
    my $sth;
    my $query = "SELECT export_format_id, profile FROM export_format";
    $sth = $dbh->prepare($query);
    $sth->execute();
    return $sth->fetchall_arrayref({});

}



1;
