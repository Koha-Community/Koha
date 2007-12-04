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
use C4::Auth;
use C4::Context;
use C4::Output;
use C4::Biblio;
use C4::Dates;

# Fixed variables
my $linecolor1='#ffffcc';
my $linecolor2='white';
my $backgroundimage="/images/background-mem.gif";
my $script_name="/cgi-bin/koha/admin/branches.pl";
my $pagepagesize=20;

#######################################################################################
# Main loop....
my $input = new CGI;
my $minlocation=$input->param('minlocation');
my $maxlocation=$input->param('maxlocation');
$maxlocation=$minlocation.'Z' unless $maxlocation;
my $datelastseen = $input->param('datelastseen');
my $offset = $input->param('offset');
my $markseen = $input->param('markseen');
$offset=0 unless $offset;
my $pagesize = $input->param('pagesize');
$pagesize=20 unless $pagesize;
my $uploadbarcodes = $input->param('uploadbarcodes');
# warn "uploadbarcodes : ".$uploadbarcodes;

my ($template, $borrowernumber, $cookie)
    = get_template_and_user({template_name => "reports/inventory.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {reports => 1},
			     debug => 1,
			     });
$template->param(minlocation => $minlocation,
				maxlocation => $maxlocation,
				offset => $offset,
				pagesize => $pagesize,
				datelastseen => $datelastseen,
				);
if ($uploadbarcodes && length($uploadbarcodes)>0){
	my $dbh=C4::Context->dbh;
	my $date = format_date($input->param('setdate')) || C4::Dates->new()->output();
# 	warn "$date";
	my $strsth="update items set (datelastseen = $date) where items.barcode =?";
	my $qupdate = $dbh->prepare($strsth);
	$strsth="select * from issues, items where items.itemnumber=issues.itemnumber and items.barcode =? and issues.returndate is null";
	my $qonloan = $dbh->prepare($strsth);
	$strsth="select * from items where items.barcode =? and issues.wthdrawn=1";
	my $qwthdrawn = $dbh->prepare($strsth);
	my @errorloop;
	my $count=0;
	while (my $barcode=<$uploadbarcodes>){
		chomp $barcode;
# 		warn "$barcode";
		if ($qwthdrawn->execute($barcode) &&$qwthdrawn->rows){
			push @errorloop, {'barcode'=>$barcode,'ERR_WTHDRAWN'=>1};
		}else{
			$qupdate->execute($barcode);
			$count += $qupdate->rows;
# 			warn "$count";
			if ($count){
				$qonloan->execute($barcode);
				if ($qonloan->rows){
					my $data = $qonloan->fetchrow_hashref;
					my ($doreturn, $messages, $iteminformation, $borrower) =AddReturn($barcode, $data->{homebranch});
					if ($doreturn){push @errorloop, {'barcode'=>$barcode,'ERR_ONLOAN_RET'=>1}}
					else {push @errorloop, {'barcode'=>$barcode,'ERR_ONLOAN_NOT_RET'=>1}}
				}
			} else {
				push @errorloop, {'barcode'=>$barcode,'ERR_BARCODE'=>1};
			}
		}
	}
	$qupdate->finish;
	$qonloan->finish;
	$qwthdrawn->finish;
	$template->param(date=>$date,Number=>$count);
# 	$template->param(errorfile=>$errorfile) if ($errorfile);
	$template->param(errorloop=>\@errorloop) if (@errorloop);
}else{
	if ($markseen) {
		foreach my $field ($input->param) {
			if ($field =~ /SEEN-(.*)/) {
				&ModDateLastSeen($1);
			}
		}
	}
	if ($minlocation) {
		my $res = C4::Circulation::Circ2::listitemsforinventory($minlocation,$maxlocation,$datelastseen,$offset,$pagesize);
		$template->param(loop =>$res,
						nextoffset => ($offset+$pagesize),
						prevoffset => ($offset?$offset-$pagesize:0),
						);
	}
}
output_html_with_http_headers $input, $cookie, $template->output;

# Local Variables:
# tab-width: 8
# End:
