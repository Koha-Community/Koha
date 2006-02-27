#!/usr/bin/perl

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
use CGI;
use C4::Context;
use C4::Output;
use C4::Database;
use C4::Auth;
use C4::Output;
use C4::Koha;
use C4::Interface::CGI::Output;
use HTML::Template;

my $input = new CGI;
my $dbh = C4::Context->dbh;

my $type=$input->param('type');
my $branch = $input->param('branch');
$branch="" unless $branch;
my $op = $input->param('op');

# my $flagsrequired;
# $flagsrequired->{circulation}=1;
my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "tools/overduerules.tmpl",
                             query => $input,
                             type => "intranet",
                             authnotrequired => 0,
 			     flagsrequired => {parameters => 1, management => 1},
			      debug => 1,
                             });
# save the values entered
if ($op eq 'save') {
	my @names=$input->param();
	my $sth_search = $dbh->prepare("select count(*) as total from overduerules where branchcode=? and categorycode=?");

	my $sth_insert = $dbh->prepare("insert into overduerules (branchcode,categorycode, delay1,letter1,debarred1, delay2,letter2,debarred2, delay3,letter3,debarred3) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?)");
	my $sth_update=$dbh->prepare("Update overduerules set delay1=?, letter1=?, debarred1=?, delay2=?, letter2=?, debarred2=?, delay3=?, letter3=?, debarred3=? where branchcode=? and categorycode=?");
	my $sth_delete=$dbh->prepare("delete from overduerules where branchcode=? and categorycode=?");
	my %temphash;
	foreach my $key (@names){
		# ISSUES
		if ($key =~ /(.*)([1-3])-(.*)/) {
			my $type = $1; # data type
			my $num = $2; # From 1 to 3
			my $bor = $3; # borrower category
			$temphash{$bor}->{"$type$num"}=$input->param("$key");
		}
	}
	foreach my $bor (keys %temphash){
		$sth_search->execute($branch,$bor);
		my $res = $sth_search->fetchrow_hashref();
		if ($res->{'total'}>0) {
					$sth_update->execute(
						($temphash{$bor}->{"delay1"}?$temphash{$bor}->{"delay1"}:0),
						($temphash{$bor}->{"letter1"}?$temphash{$bor}->{"letter1"}:""),
						($temphash{$bor}->{"debarred1"}?$temphash{$bor}->{"debarred1"}:0),
						($temphash{$bor}->{"delay2"}?$temphash{$bor}->{"delay2"}:0),
						($temphash{$bor}->{"letter2"}?$temphash{$bor}->{"letter2"}:""),
						($temphash{$bor}->{"debarred2"}?$temphash{$bor}->{"debarred2"}:0),
						($temphash{$bor}->{"delay3"}?$temphash{$bor}->{"delay3"}:0),
						($temphash{$bor}->{"letter3"}?$temphash{$bor}->{"letter3"}:""),
						($temphash{$bor}->{"debarred3"}?$temphash{$bor}->{"debarred3"}:0),
						$branch ,$bor
						);
				} else {
# 					warn "insert  overduenotice1: $data[0],delay1: $data[1], letter1 : $data[2],debarred1 : $data[3], notice2 : $data[4], delay2 : $data[5], letter2 : $data[6],debarred2 : $data[7], 3 : $data[8],3 : $data[9],3 : $data[10],3 : $data[11], $br ,$bor ";
					$sth_insert->execute($branch,$bor,
						($temphash{$bor}->{"delay1"}?$temphash{$bor}->{"delay1"}:0),
						($temphash{$bor}->{"letter1"}?$temphash{$bor}->{"letter1"}:""),
						($temphash{$bor}->{"debarred1"}?$temphash{$bor}->{"debarred1"}:0),
						($temphash{$bor}->{"delay2"}?$temphash{$bor}->{"delay2"}:0),
						($temphash{$bor}->{"letter2"}?$temphash{$bor}->{"letter2"}:""),
						($temphash{$bor}->{"debarred2"}?$temphash{$bor}->{"debarred2"}:0),
						($temphash{$bor}->{"delay3"}?$temphash{$bor}->{"delay3"}:0),
						($temphash{$bor}->{"letter3"}?$temphash{$bor}->{"letter3"}:""),
						($temphash{$bor}->{"debarred3"}?$temphash{$bor}->{"debarred3"}:0)
						);
				}
	}

}
my $branches = getbranches;
my @branchloop;
foreach my $thisbranch (keys %$branches) {
	my $selected = 1 if $thisbranch eq $branch;
	my %row =(value => $thisbranch,
				selected => $selected,
				branchname => $branches->{$thisbranch}->{'branchname'},
			);
	push @branchloop, \%row;
}

my ($countletters,$letters) = getletters("circulation");

my $sth=$dbh->prepare("Select description,categorycode from categories where overduenoticerequired>0 order by description");
$sth->execute;
my @line_loop;
my $toggle= 1;
# my $i=0;
while (my $data=$sth->fetchrow_hashref){
	if ( $toggle eq 1 ) {
		$toggle = 0;
	} else {
		$toggle = 1;
	}
	my %row = ( overduename => $data->{'categorycode'},
				toggle => $toggle,
				line => $data->{'description'}
				);
	my $sth2=$dbh->prepare("SELECT * from overduerules WHERE branchcode=? and categorycode=?");
	$sth2->execute($branch,$data->{'categorycode'});
	my $dat=$sth2->fetchrow_hashref;
# 	foreach my $test (keys %$dat){
# 		warn "$test : ".$dat->{$test};
# 	}
	for (my $i=1;$i<=3;$i++){
		if ($countletters){
			my @letterloop;
			foreach my $thisletter (keys %$letters) {
				my $selected = 1 if $thisletter eq $dat->{"letter$i"};
				my %letterrow =(value => $thisletter,
							selected => $selected,
							lettername => $letters->{$thisletter},
						);
				push @letterloop, \%letterrow;
			}
			$row{"letterloop$i"}=\@letterloop;
		} else {
			$row{"noletter"}=1;
			if ($dat->{"letter$i"}){$row{"letter$i"}=$dat->{"letter$i"};}
		}
		if ($dat->{"delay$i"}){$row{"delay$i"}=$dat->{"delay$i"};}
		if ($dat->{"debarred$i"}){$row{"debarred$i"}=$dat->{"debarred$i"};}
	}
	$sth2->finish;
	push @line_loop,\%row;
}
$sth->finish;

$template->param(table=> \@line_loop,
						branchloop => \@branchloop,
						branch => $branch);
output_html_with_http_headers $input, $cookie, $template->output;
