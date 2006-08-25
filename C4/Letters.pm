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
use Mail::Sendmail;
use C4::Date;
use C4::Suggestions;
use C4::Members;
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
@EXPORT = qw(&GetLetterList &getletter &addalert &getalert &delalert &findrelatedto &sendalerts);

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

sub getletter {
	my ($module,$code) = @_;
	my $dbh = C4::Context->dbh;
	my $sth = $dbh->prepare("select * from letter where module=? and code=?");
	$sth->execute($module,$code);
	my $line = $sth->fetchrow_hashref;
	return $line;
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
	if ($type eq 'issue') {
		$sth=$dbh->prepare("select title as result from subscription left join biblio on subscription.biblionumber=biblio.biblionumber where subscriptionid=?");
	}
	if ($type eq 'borrower') {
		$sth=$dbh->prepare("select concat(firstname,' ',surname) from borrowers where borrowernumber=?");
	}
	$sth->execute($externalid);
	my ($result) = $sth->fetchrow;
	return $result;
}

=head2 sendalert
	parameters :
	- $type : the type of alert
	- $externalid : the id of the "object" to query
	- $letter : the letter to send.

	send an alert to all borrowers having put an alert on a given subject.

=cut

sub sendalerts {
	my ($type,$externalid,$letter)=@_;
	my $dbh=C4::Context->dbh;
	if ($type eq 'issue') {
# 		warn "sending issues...";
		my $letter = getletter('serial',$letter);
		# prepare the letter...
		# search the biblionumber
		my $sth=$dbh->prepare("select biblionumber from subscription where subscriptionid=?");
		$sth->execute($externalid);
		my ($biblionumber)=$sth->fetchrow;
		# parsing branch info
		my $userenv = C4::Context->userenv;
		parseletter($letter,'branches',$userenv->{branch});
		# parsing librarian name
		$letter->{content} =~ s/<<LibrarianFirstname>>/$userenv->{firstname}/g;
		$letter->{content} =~ s/<<LibrarianSurname>>/$userenv->{surname}/g;
		$letter->{content} =~ s/<<LibrarianEmailaddress>>/$userenv->{emailaddress}/g;
		# parsing biblio information
		parseletter($letter,'biblio',$biblionumber);
		parseletter($letter,'biblioitems',$biblionumber);
		# find the list of borrowers to alert
		my $alerts = getalert('','issue',$externalid);
		foreach (@$alerts) {
			# and parse borrower ...
			my $innerletter = $letter;
			my $borinfo = getmember('',$_->{'borrowernumber'});
			parseletter($innerletter,'borrowers',$_->{'borrowernumber'});
			# ... then send mail
			if ($borinfo->{emailaddress}) {
				my %mail = ( To => $borinfo->{emailaddress},
							From => $userenv->{emailaddress},
							Subject => "".$innerletter->{title},
							Message => "".$innerletter->{content},
							);
				sendmail(%mail);
# 				warn "sending to $mail{To} From $mail{From} subj $mail{Subject} Mess $mail{Message}";
			}
		}
	}
}

=head2
	parameters :
	- $letter : a hash to letter fields (title & content useful)
	- $table : the Koha table to parse.
	- $pk : the primary key to query on the $table table
	parse all fields from a table, and replace values in title & content with the appropriate value
	(not exported sub, used only internally)
=cut
sub parseletter {
	my ($letter,$table,$pk) = @_;
# 	warn "Parseletter : ($letter,$table,$pk)";
	my $dbh=C4::Context->dbh;
	my $sth;
	if ($table eq 'biblio') {
		$sth = $dbh->prepare("select * from biblio where biblionumber=?");
	} elsif ($table eq 'biblioitems') {
		$sth = $dbh->prepare("select * from biblioitems where biblionumber=?");
	} elsif ($table eq 'borrowers') {
		$sth = $dbh->prepare("select * from borrowers where borrowernumber=?");
	} elsif ($table eq 'branches') {
		$sth = $dbh->prepare("select * from branches where branchcode=?");
	}
	$sth->execute($pk);
	# store the result in an hash
	my $values = $sth->fetchrow_hashref;
	# and get all fields from the table
	$sth = $dbh->prepare("show columns from $table");
	$sth->execute;
	while ((my $field) = $sth->fetchrow_array) {
		my $replacefield="<<$table.$field>>";
		my $replacedby = $values->{$field};
# 		warn "REPLACE $replacefield by $replacedby";
		$letter->{title} =~ s/$replacefield/$replacedby/g;
		$letter->{content} =~ s/$replacefield/$replacedby/g;
	}
}

END { }       # module clean-up code here (global destructor)
