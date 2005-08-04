package C4::Letters;


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
use C4::Date;
use Date::Manip;
use C4::Suggestions;
require Exporter;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

# set the version for version checking
$VERSION = 0.01;

=head1 NAME

C4::Letters - Give functions for Letters management

=head1 SYNOPSIS

  use C4::Letters;

=head1 DESCRIPTION

  "Letters" is the tool used in Koha to manage informations sent to the patrons and/or the library. This include some cron jobs like
  late issues, as well as other tasks like sending a mail to users that have subscribed to a "serial issue alert" (= being warned every time a new issue has arrived at the library)
  
  Letters are managed through "alerts" sent by Koha on some events. All "alert" related functions are in this module too.

=cut

@ISA = qw(Exporter);
@EXPORT = qw(&GetLetterList &addalert &getalert &delalert &findrelatedto);

=head2 GetLetterList

	parameter : $module : the name of the module
	This sub returns an array of hashes with all letters from a given module
	Each hash entry contains :
	- module : the module name
	- code : the code of the letter, char(20)
	- name : the complete name of the letter, char(200)
	- title : the title that will be used as "subject" in mails, char(200)
	- content : the content of the letter. Each field to be replaced by a value at runtime is enclosed in << and >>. The fields usually have the same name as in the DB 

=cut

sub GetLetterList {
	my ($module) = @_;
	my $dbh = C4::Context->dbh;
	my $sth = $dbh->prepare("select * from letter where module=?");
	$sth->execute($module);
	my @result;
	while (my $line = $sth->fetchrow_hashref) {
		push @result,$line;
	}
	return @result;
}

=head2 addalert

	parameters : 
	- $borrowernumber : the number of the borrower subscribing to the alert
	- $type : the type of alert.
	- externalid : the primary key of the object to put alert on. For issues, the alert is made on subscriptionid.

	create an alert and return the alertid (primary key)
	
=cut

sub addalert {
	my ($borrowernumber,$type,$externalid) = @_;
	my $dbh=C4::Context->dbh;
	my $sth = $dbh->prepare("insert into alert (borrowernumber, type, externalid) values (?,?,?)");
	$sth->execute($borrowernumber,$type,$externalid);
	# get the alert number newly created and return it
	my $alertid = $dbh->{'mysql_insertid'};
	return $alertid;
}

=head2 delalert
	parameters :
	- alertid : the alert id
	deletes the alert
=cut

sub delalert {
	my ($alertid)=@_;
# 	warn "ALERTID : $alertid";
	my $dbh = C4::Context->dbh;
	my $sth = $dbh->prepare("delete from alert where alertid=?");
	$sth->execute($alertid);
}

=head2 getalert

	parameters :
	- $borrowernumber : the number of the borrower subscribing to the alert
	- $type : the type of alert.
	- externalid : the primary key of the object to put alert on. For issues, the alert is made on subscriptionid.
	all parameters NON mandatory. If a parameter is omitted, the query is done without the corresponding parameter. For example, without $externalid, returns all alerts for a borrower on a topic.
	
=cut

sub getalert {
	my ($borrowernumber,$type,$externalid) = @_;
	my $dbh=C4::Context->dbh;
	my $query = "select * from alert where";
	my @bind;
	if ($borrowernumber) {
		$query .= " borrowernumber=? and";
		push @bind,$borrowernumber;
	}
	if ($type) {
		$query .= " type=? and";
		push @bind,$type;
	}
	if ($externalid) {
		$query .= " externalid=? and";
		push @bind,$externalid;
	}
	$query =~ s/ and$//;
# 	warn "Q : $query";
	my $sth = $dbh->prepare($query);
	$sth->execute(@bind);
	my @result;
	while (my $line = $sth->fetchrow_hashref) {
		push @result,$line;
	}
	return \@result if $#result >=0; # return only if there is one result.
	return;
}
=head2 findrelatedto
	parameters :
	- $type : the type of alert
	- $externalid : the id of the "object" to query
	
	In the table alert, a "id" is stored in the externalid field. This "id" is related to another table, depending on the type of the alert.
	When type=issue, the id is related to a subscriptionid and this sub returns the name of the biblio.
	When type=virtual, the id is related to a virtual shelf and this sub returns the name of the sub
=cut
sub findrelatedto {
	my ($type,$externalid) = @_;
	my $dbh=C4::Context->dbh;
	my $sth;
	if ($type eq "issue") {
		$sth=$dbh->prepare("select title as result from subscription left join biblio on subscription.biblionumber=biblio.biblionumber where subscriptionid=?");
	}
	$sth->execute($externalid);
	my ($result) = $sth->fetchrow;
	return $result;
}

END { }       # module clean-up code here (global destructor)
