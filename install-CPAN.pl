# cpan_install.pl - Install prerequisites from CPAN then Koha

($ARGV[0] =~ /koha-.*z/) || die "
 Run this as the CPAN-owning user (usually root) with:
   perl $0 path/to/koha.tgz
";

# Copyright 2007 MJ Ray
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
# Current maintainer MJR http://mjr.towers.org.uk/

# Create a fake CPAN location for koha
use CPAN;
CPAN::Config->load;
$cpan = $CPAN::Config->{cpan_home};
mkdir $cpan.'/sources/authors/id';
mkdir $cpan.'/sources/authors/id/K';
mkdir $cpan.'/sources/authors/id/K/KO';
mkdir $cpan.'/sources/authors/id/K/KO/KOHA';

# Move the tarball to it
$koha = $ARGV[0];
( rename $koha,$cpan.'/sources/authors/id/K/KO/KOHA/'.$koha ) ||
die 'Cannot move koha distribution into position.
This may be due to an unconfigured CPAN or running as the wrong user.
To configure cpan, try perl -MCPAN -e shell
Installation aborted';

# Start the main CPAN install routine
CPAN::install('KOHA/'.$koha);
