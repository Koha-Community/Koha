#!/usr/bin/perl
# $Id$

# Copyright 2006 SAN OUEST PROVENCE et Paul POULAIN
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

# pragma
use strict;

# external modules
use Date::Calc qw/Today/;
use CGI;
use HTML::Template;
use Date::Manip;
use Digest::MD5 qw(md5_base64);

# internal modules
use C4::Auth;
use C4::Context;
use C4::Output;
use C4::Interface::CGI::Output;
use C4::Search;
use C4::Members;
use C4::Koha;
use C4::Date;
use C4::Input;
use C4::Log;

my $input = new CGI;
my %data;


my $dbh = C4::Context->dbh;

my $category_type = $input->param('category_type') || die "NO CATEGORY_TYPE !"; # A, E, C, or P
my $step=$input->param('step') || 0;
my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "members/memberentry$category_type.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {borrowers => 1},
			     debug => 1,
			     });

my $borrowerid=$input->param('borrowerid');
my $guarantorid=$input->param('guarantorid');
my $borrowernumber=$input->param('borrowernumber');
my $actionType=$input->param('actionType') || '';
my $modify=$input->param('modify');
my $delete=$input->param('delete');
my $op=$input->param('op');
my $categorycode=$input->param('categorycode');
my $destination=$input->param('destination');
my $cardnumber=$input->param('cardnumber');
my $check_member=$input->param('check_member');
my $name_city=$input->param('name_city');
my $nodouble=$input->param('nodouble');
my $select_city=$input->param('select_city');
my $nok=$input->param('nok');

my @errors;

# $check_categorytype contains the value of duplicate borrowers category type to redirect in good template in step =2
my $check_categorytype=$input->param('check_categorytype');
# NOTE: Alert for ethnicity and ethnotes fields, they are unvalided in all borrowers form


#function  to automatic setup the mandatory  fields (visual with css)
my $check_BorrowerMandatoryField=C4::Context->preference("BorrowerMandatoryField");
my @field_check=split(/\|/,$check_BorrowerMandatoryField);
foreach (@field_check) {
$template->param( "mandatory$_" => 1);		
}	

$template->param( "checked" => 1) if ($nodouble eq 1);


# if a add or modify is requested => check validity of data.
if ($op eq 'add' or $op eq 'modify') {
	my @names=$input->param;
	foreach my $key (@names){
		$data{$key}=$input->param($key)||'';
		$data{$key}=~ s/\'/\\\'/g;
		$data{$key}=~ s/\"/\\\"/g;
	}

	#############test for member being unique #############
	if ($op eq 'add' && $step eq 2){
		(my $category_type_send=$category_type ) if ($category_type eq 'I'); 
 		my $check_category; # recover the category code of the doublon suspect borrowers
	   ($check_member,$check_category)= checkuniquemember($category_type_send,$data{'surname'},$data{'firstname'},format_date_in_iso($data{'dateofbirth'}));
# 	recover the category type if the borrowers is a duplicate
	($check_categorytype,undef)=getcategorytype($check_category);
	}

# CHECKS step by step
# STEP 1
	if ($step eq 1) {
		###############test to take the right zipcode and city name ##############
		if ($category_type ne 'I' and $guarantorid){
			my ($borrower_city,$borrower_zipcode)=&getzipnamecity($select_city);
			$data{'city'}= $borrower_city;
			$data{'zipcode'}=$borrower_zipcode;
		}
		if ($category_type eq 'C' and $guarantorid){
			my $guarantordata=getguarantordata($guarantorid);
			if (($data{'contactname'} eq '' or $data{'contactname'} ne $guarantordata->{'surname'})) {
				$data{'contactfirstname'}=$guarantordata->{'firstname'};	
				$data{'contactname'}=$guarantordata->{'surname'};
				$data{'contacttitle'}=$guarantordata->{'title'};
				$data{'streetnumber'}=$guarantordata->{'streetnumber'};
				$data{'address'}=$guarantordata->{'address'};
				$data{'streettype'}=$guarantordata->{'streettype'};
				$data{'address2'}=$guarantordata->{'address2'};
				$data{'zipcode'}=$guarantordata->{'zipcode'};
				$data{'city'}=$guarantordata->{'city'};
				$data{'phone'}=$guarantordata->{'phone'};
				$data{'phonepro'}=$guarantordata->{'phonepro'};
				$data{'mobile'}=$guarantordata->{'mobile'};
				$data{'fax'}=$guarantordata->{'fax'};
				$data{'email'}=$guarantordata->{'email'};
				$data{'emailpro'}=$guarantordata->{'emailpro'};
			}
                    }
                if ($categorycode ne 'I') {
                    # is the age of the borrower compatible with age limitations of
                    # the borrower category
                    my $query = '
SELECT upperagelimit,
       dateofbirthrequired
  FROM categories
  WHERE categorycode = ?
';
                    my $sth=$dbh->prepare($query);
                    $sth->execute($categorycode);
                    my $category_info = $sth->fetchrow_hashref;

                    my $age = get_age(format_date_in_iso($data{dateofbirth}));

                    if ($age > $category_info->{upperagelimit}
                            or $age < $category_info->{dateofbirthrequired}
                        ) {
                        push @errors, 'ERROR_age_limitations';
                        $nok = 1;
                    }
                }
	}
# STEP 2
	if ($step eq 2) {
			if ( ($data{'login'} eq '')){
				my $onefirstnameletter=substr($data{'firstname'},0,1);
				my $fivesurnameletter=substr($data{'surname'},0,5);
				$data{'login'}=lc($onefirstnameletter.$fivesurnameletter);
			}
			if ($op eq 'add' and $data{'dateenrolled'} eq ''){
				my $today=today();
				#insert ,in field "dateenrolled" , the current date
				$data{'dateenrolled'}=$today;
				#if date expiry is null u must calculate the value only in this case
				$data{'dateexpiry'} = calcexpirydate($data{'categorycode'},$today);
			}
			if ($op eq 'modify' ){
			my $today=today();
# 			if date expiry is null u must calculate the value only in this case
			if ($data{'dateexpiry'} eq ''){
			$data{'dateexpiry'} = calcexpirydate($data{'categorycode'},$today);
 			}
		}
	}
# STEP 3
	if ($step eq 3) {
		# this value show if the login and password are been used
		my $loginexist=checkuserpassword($borrowerid,$data{'login'},$data{'password'});
		# test to know if u must save or create the borrowers
		if ($op eq 'modify'){
			# test to know if another user have the same password and same login		
			if ($loginexist eq 0) {
				&modmember(%data);		
				logaction($loggedinuser,"MEMBERS","modify member", $borrowerid, "");
			}
			else {
				push @errors, "ERROR_login_exist";
				$nok=1;
			}
 		}else{
			# test to know if another user have the same password and same login	 
			if ($loginexist) {
				push @errors, "ERROR_login_exist";
				$nok=1;
			} else {
				$borrowerid = &newmember(%data);
			        if ($data{'organisations'}){
				    # need to add the members organisations
				    add_member_orgs($borrowerid,$data{'organisations'});
				 }
				logaction($loggedinuser,"MEMBERS","add member", $borrowerid, "");
			}
 		}

		unless ($nok) {
			if($destination eq "circ"){
				print $input->redirect("/cgi-bin/koha/circ/circulation.pl?findborrower=$data{'cardnumber'}");
			} else {
				if ($loginexist == 0) {
				print $input->redirect("/cgi-bin/koha/members/moremember.pl?bornum=$borrowerid");
				}
			}
		}
	}
	if (C4::Context->preference("IndependantBranches")) {
		my $userenv = C4::Context->userenv;
		if ($userenv->{flags} != 1){
			unless ($userenv->{branch} eq $data{'branchcode'}){
				push @errors, "ERROR_branch";
				$nok=1;
			}
		}
	}
}

if ($delete){
	print $input->redirect("/cgi-bin/koha/deletemem.pl?member=$borrowerid");
	print $input->redirect("/cgi-bin/koha/deletemem.pl?member=$borrowernumber");
} else {  # this else goes down the whole script
	# retrieve previous values : either in DB or in CGI, in case of errors in values
	my $data;
# test to now if u add or modify a borrower (modify =>to take all carateristic of the borrowers)
	if (!$op and !$data{'surname'}) {
		$data=borrdata('',$borrowerid);
		%data=%$data;
	}
	if (C4::Context->preference("IndependantBranches")) {
		my $userenv = C4::Context->userenv;
		if ($userenv->{flags} != 1 && $data{branchcode}){
			unless ($userenv->{branch} eq $data{'branchcode'}){
				print $input->redirect("/cgi-bin/koha/members/members-home.pl");
			}
		}
	}
	if ($op eq 'add'){
		$template->param( updtype => 'I');
	} else {
		$template->param( updtype => 'M');
	}
	my $cardnumber=$data{'cardnumber'};
	$cardnumber=fixup_cardnumber($data{'cardnumber'}) if $op eq 'add';
	if ($data{'sex'} eq 'F'){
		$template->param(female => 1);
	}
	my ($categories,$labels)=ethnicitycategories();
	my $ethnicitycategoriescount=$#{$categories};
	my $ethcatpopup;
	if ($ethnicitycategoriescount>=0) {
		$ethcatpopup = CGI::popup_menu(-name=>'ethnicity',
					-id => 'ethnicity',
					-values=>$categories,
					-default=>$data{'ethnicity'},
					-labels=>$labels);
		$template->param(ethcatpopup => $ethcatpopup); # bad style, has to be fixed
	}
	
	
	($categories,$labels)=borrowercategories($category_type,$op);
	
	#if u modify the borrowers u must have the right value for is category code
	
	(my $default_category=$data{'categorycode'}) if ($op  eq '');
	my $catcodepopup = CGI::popup_menu(-name=>'categorycode',
 					-id => 'categorycode',
 					-values=>$categories,
  					-default=>$default_category,
 					-labels=>$labels);
	#test in city
	my $default_city;
 	if ($op eq ''){
	(my $selectcity=&getidcity($data{'city'})) if ($select_city eq '');
	$default_city=$selectcity;
	}
	my($cityid,$name_city)=getcities();
	$template->param( city_cgipopup => 1) if ($cityid );
	my $citypopup = CGI::popup_menu(-name=>'select_city',
					-id => 'select_city',
					-values=>$cityid,
					-labels=>$name_city,
#   					-override => 1,
					-default=>$default_city
					);	
	
 	my $default_roadtype;
 	$default_roadtype=$data{'streettype'} ;
	my($roadtypeid,$road_type)=getroadtypes();
  	$template->param( road_cgipopup => 1) if ($roadtypeid );
	my $roadpopup = CGI::popup_menu(-name=>'streettype',
					-id => 'streettype',
					-values=>$roadtypeid,
  					-labels=>$road_type,
   					-override => 1,
					-default=>$default_roadtype
					);	

	
	my @relationships = split /,|\|/,C4::Context->preference('BorrowerRelationship');
	my @relshipdata;
	while (@relationships) {
		my $relship = shift @relationships || '';
		my %row = ('relationship' => $relship);
		if ($data{'relationship'} eq $relship) {
			$row{'selected'}=' selected';
		} else {
			$row{'selected'}='';
		}
		push(@relshipdata, \%row);
	}
	my %flags = ( 'gonenoaddress' => ['gonenoaddress', 'Adresse érronée'],
		      'lost'          => ['lost', 'Carte Perdue'],
		      'debarred'      => ['debarred', 'Lecteur exclu']);

	my @flagdata;
	foreach (keys(%flags)) {
	my $key = $_;
	my %row =  ('key'   => $key,
			'name'  => $flags{$key}[0],
			'html'  => $flags{$key}[1]);
	if ($data{$key}) {
		$row{'yes'}=' checked';
		$row{'no'}='';
	} else {
		$row{'yes'}='';
		$row{'no'}=' checked';
	}
	push(@flagdata, \%row);
	}

	if ($modify){
	$template->param( modify => 1 );
	}

	#Convert dateofbirth to correct format
	$data{'dateofbirth'} = format_date($data{'dateofbirth'});
	my @branches;
	my @select_branch;
	my %select_branches;
	my $branches=getbranches();
	my $default;
	# -----------------------------------------------------
	#  the value of ip from the branches hash table
		my $select_ip;
	# $ip is the ip of user when is connect to koha 
		my $ip = $ENV{'REMOTE_ADDR'};
	# -----------------------------------------------------
	foreach my $branch (keys %$branches) {
		if ((not C4::Context->preference("IndependantBranches")) || (C4::Context->userenv->{'flags'} == 1)) {
			push @select_branch, $branch;
			$select_branches{$branch} = $branches->{$branch}->{'branchname'};
# 		 take the ip number from branches "op"
			$select_ip = $branches->{$branch}->{'branchip'} || '';
				
# 		test $select_ip equal $ip to attribute the default value for the scrolling list
			if ($select_ip eq $ip)  {
						$default = $branches->{$branch}->{'branchcode'};
						}
			} else {
				push @select_branch, $branch if ($branch eq C4::Context->userenv->{'branch'});
				$select_branches{$branch} = $branches->{$branch}->{'branchname'} if ($branch eq C4::Context->userenv->{'branch'});
					
 				$default = C4::Context->userenv->{'branch'};
					
				}
	}
# --------------------------------------------------------------------------------------------------------
 	my $CGIbranch = CGI::scrolling_list(-id    => 'branchcode',
					   -name   => 'branchcode',
					   -values => \@select_branch,
					   -labels => \%select_branches,
					   -size   => 1,
				           -multiple =>0,
					   -override => 1,	
 					   -default => $default,
					);
       my $CGIorganisations;
       my $member_of_institution;
       if (C4::Context->preference("memberofinstitution")){
	   my $organisations=get_institutions();
	   my @orgs;
	   my %org_labels;
	   foreach my $organisation (keys %$organisations) {
	       push @orgs,$organisation;
	       $org_labels{$organisation}=$organisations->{$organisation}->{'surname'};
	   }
	   $member_of_institution=1;
	   
	   $CGIorganisations = CGI::scrolling_list( -id => 'organisations',
	       -name     => 'organisations',
	       -labels   => \%org_labels,
	       -values   => \@orgs,
	       -size     => 5,
	       -multiple => 'true'

	       
	   );
       }


# --------------------------------------------------------------------------------------------------------
	
	my $CGIsort1 = buildCGIsort("Bsort1","sort1",$data{'sort1'});
	if ($CGIsort1) {
		$template->param(CGIsort1 => $CGIsort1);
		$template->param( sort1 => $data{'sort1'});
	} else {
		$template->param( sort1 => $data{'sort1'});
	}
	
	my $CGIsort2 = buildCGIsort("Bsort2","sort2",$data{'sort2'});
	if ($CGIsort2) {
		$template->param(CGIsort2 =>$CGIsort2);
	} else {
		$template->param( sort2 => $data{'sort2'});
	}

	
 	$data{'opacnotes'} =~ s/\\//g;
	$data{'borrowernotes'} =~ s/\\//g;

	# increase step to see next page
        if ($nok) {
            foreach my $error (@errors) {
                $template->param( $error => 1);
            }
            $template->param(nok => 1);
        }
        else {
            $step++;
        }

	warn "CITY".$data{city};
	$template->param(
		BorrowerMandatoryField => C4::Context->preference("BorrowerMandatoryField"),#field to test with javascript
		category_type	=> $category_type,#to know the category type of the borrower
		select_city	=> $select_city,
		"step_$step" 	=> 1,# associate with step to know where u are
		step		=> $step,
		destination 	=> $destination,#to know wher u come from and wher u must go in redirect
		check_member    => $check_member,#to know if the borrower already exist(=>1) or not (=>0) 
# 				flags		=>$data{'flags'},		
		"op$op" 	=> 1,
# 		op			=> $op,
		nodouble	=> $nodouble,
		borrowerid 	=> $borrowerid,#register number
		cardnumber	=> $data{'cardnumber'},
		surname         => uc($data{'surname'}),
		firstname       => ucfirst($data{'firstname'}),
		"title_".$data{'title'}   => " SELECTED ",
		title 		=> $data{'title'},
		othernames	=> $data{'othernames'},
		initials	=> $data{'initials'},
		streetnumber	=> $data{'streetnumber'},
		streettype	=>$data{'streettype'},
		address  	 => $data{'address'},
		address2 	=> $data{'address2'},	
		city	 	=> $data{'city'},
		zipcode 	=> $data{'zipcode'},
		email    	=> $data{'email'},
		phone           => $data{'phone'},
		mobile          => $data{'mobile'},
		fax		=> $data{'fax'},
		phonepro        => $data{'phonepro'},
		emailpro	=> $data{'emailpro'},
		b_address   	=> $data{'b_address'},
		b_city     	=> $data{'b_city'},
		b_zipcode 	=> $data{'b_zipcode'},
		b_email		=> $data{'b_email'},
		b_phone        => $data{'b_phone'},
		dateofbirth	=> $data{'dateofbirth'},
		branchcode      => $data{'branchcode'},
		catcodepopup	=> $catcodepopup,
		categorycode 	=> $data{'categorycode'},
		dateenrolled 	=> format_date($data{'dateenrolled'}),
		dateexpiry		=> format_date($data{'dateexpiry'}),
		debarred        => $data{'debarred'},
		gonenoaddress 	=> $data{'gonenoaddress'}, 
		lost 	=> $data{'lost'},
		contactname     => uc($data{'contactname'}),
		contactfirstname=> ucfirst($data{'contactfirstname'}),
		"contacttitle_".$data{'contacttitle'} => "SELECTED" ,
		contacttitle	=> $data{'contacttitle'},
		guarantorid	=> $guarantorid,
		ethcatpopup	=> $ethcatpopup,
		sex		=> $data{'sex'},
		login 		=> $data{'login'},	
		password 	=> $data{'password'},	
		opacnotes   	=> $data{'opacnotes'},	
		contactnotes	=> $data{'contactnotes'},
		borrowernotes	=> $data{'borrowernotes'},
		relshiploop	=> \@relshipdata,
		relationship	=> $data{'relationship'},
		citypopup	=> $citypopup,
		roadpopup	=> $roadpopup,	
		contacttype	=> $data{'contacttype'},
	        organisations   => $data{'organisations'},
		flagloop	=> \@flagdata,
# 				"contacttype_".$data{'contacttype'} =>" SELECTED ",
		dateformat      => display_date_format(),
		check_categorytype =>$check_categorytype,#to recover the category type with checkcategorytype function
			modify          => $modify,
# 				city_choice       => $city_choice ,#check if the city was selected
		nok 		=> $nok,#flag to konw if an error 
		CGIbranch => $CGIbranch,
	        memberofinstution => $member_of_institution,
	        CGIorganisations => $CGIorganisations,
		);
	#$template->param(Institution => 1) if ($categorycode eq "I");
	output_html_with_http_headers $input, $cookie, $template->output;
}

sub get_age {
    my ($date, $date_ref) = @_;

    if (not defined $date_ref) {
        $date_ref = sprintf('%04d-%02d-%02d', Today());
    }

    my ($year1, $month1, $day1) = split /-/, $date;
    my ($year2, $month2, $day2) = split /-/, $date_ref;

    my $age = $year2 - $year1;
    if ($month1.$day1 > $month2.$day2) {
        $age--;
    }

    return $age;
}

# Local Variables:
# tab-width: 8
# End:
