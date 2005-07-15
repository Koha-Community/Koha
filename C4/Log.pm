package C4::Log; #assumes C4/Log

#package to deal with Logging Actions in DB


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
use C4::Context;

require Exporter;

use vars qw($VERSION @ISA @EXPORT);

# set the version for version checking
$VERSION = 0.01;

=head1 NAME

C4::Log - Koha Log Facility functions

=head1 SYNOPSIS

  use C4::Log;

=head1 DESCRIPTION

The functions in this module perform various functions in order to log all the operations done on the Database, including deleting and undeleting books, adding/editing members, etc.

=head1 FUNCTIONS

=over 2

=cut

@ISA = qw(Exporter);
@EXPORT = qw(&logaction &logstatus);

=item logaction

  &logaction($usernumber, $modulename, $actionname, $infos);

Adds a record into action_logs table to report the different changes upon the database

=cut
#'
sub logaction{
  my ($usernumber,$modulename, $actionname, $infos)=@_;
	my $dbh = C4::Context->dbh;
	my $sth=$dbh->prepare("Insert into action_logs (timestamp,user,module,action,info) values (now(),?,?,?,?)");
	$sth->execute($usernumber,$modulename,$actionname,$infos);
	$sth->finish;
}

=item logstatus

  &logstatus;

returns True If Activate_Log variable is equal to On
Activate_Log is a system preference Variable
=cut
#'
sub logstatus{
  my ($usernumber,$modulename, $actionname, $infos)=@_;
	my $dbh = C4::Context->dbh;
	my $sth=$dbh->prepare("select value from systempreferences where variable='Activate_Log'");
	$sth->execute;
	my ($var)=$sth->fetchrow;
	$sth->finish;
	return ($var eq "On"?"True":"")
}

END { }       # module clean-up code here (global destructor)

1;
__END__

=back

=head1 AUTHOR

Koha Developement team <info@koha.org>

=cut
