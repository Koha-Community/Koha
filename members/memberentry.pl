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
use Digest::MD5 qw(md5_base64);

# internal modules
use C4::Auth;
use C4::Context;
use C4::Output;
use C4::Members;
use C4::Koha;
use C4::Date;
use C4::Input;
use C4::Log;
use C4::Branch; # GetBranches

my $input = new CGI;
my %data;

my $dbh = C4::Context->dbh;

my $categorycode=$input->param('categorycode');
my $category_type;
$category_type = $input->param('category_type');
unless ($category_type or !($categorycode)){
  my $borrowercategory= GetBorrowercategory($categorycode);
  $category_type = $borrowercategory->{'category_type'};
}

die "NO CATEGORY TYPE !" unless $category_type; # FIXME we should display a error message instead of a 500 error !

my $step=$input->param('step') || 0;
my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "members/memberentry$category_type.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {borrowers => 1},
			     debug => 1,
			     });
my $guarantorid=$input->param('guarantorid');
my $borrowernumber=$input->param('borrowernumber');
my $actionType=$input->param('actionType') || '';
my $modify=$input->param('modify');
my $delete=$input->param('delete');
my $op=$input->param('op');
my $destination=$input->param('destination');
my $cardnumber=$input->param('cardnumber');
my $check_member=$input->param('check_member');
my $name_city=$input->param('name_city');
my $nodouble=$input->param('nodouble');
my $select_city=$input->param('select_city');
my $nok=$input->param('nok');
my $guarantorinfo=$input->param('guarantorinfo');
my @errors;
my $default_city;
# $check_categorytype contains the value of duplicate borrowers category type to redirect in good template in step =2
my $check_categorytype=$input->param('check_categorytype');
# NOTE: Alert for ethnicity and ethnotes fields, they are unvalided in all borrowers form
my $borrower_data;


$template->param("uppercasesurnames" => C4::Context->preference('uppercasesurnames'));

#function  to automatic setup the mandatory  fields (visual with css)
my $check_BorrowerMandatoryField=C4::Context->preference("BorrowerMandatoryField");
my @field_check=split(/\|/,$check_BorrowerMandatoryField);
foreach (@field_check) {
$template->param( "mandatory$_" => 1);		
}
$template->param("add"=>1) if ($op eq 'add');
$template->param( "checked" => 1) if ($nodouble eq 1);
($borrower_data=GetMember($borrowernumber,'borrowernumber')) if($op eq 'modify');

# if a add or modify is requested => check validity of data.
if ($step eq 0){
    foreach my $column (keys %$borrower_data){
	$data{$column}=$borrower_data->{$column};
    }
   }

if ($op eq 'add' or $op eq 'modify') {
	my @names=$input->param;
	foreach my $key (@names){
		$data{$key}=$input->param($key)||'';
 		$data{$key}=~ s/\"/&quot;/gg unless $key eq 'borrowernotes' or $key eq 'opacnote';
	}

	# WARN : some tests must be done whatever the step, because the librarian can click on any tab.
	#############test for member being unique #############
	if ($op eq 'add'){
          my $category_type_send=$category_type if ($category_type eq 'I'); 
          my $check_category; # recover the category code of the doublon suspect borrowers
          ($check_member,$check_category)= checkuniquemember($category_type_send,$data{'surname'},$data{'firstname'},format_date_in_iso($data{'dateofbirth'}));
          
  # 	recover the category type if the borrowers is a doublon	
          my $tmpborrowercategory=GetBorrowercategory($check_category);
          $check_categorytype=$tmpborrowercategory->{'category_type'};
          
	}

#recover all data from guarantor address phone ,fax... 
if ($category_type eq 'C' and $guarantorid ne '' ){
			my $guarantordata=GetMember($guarantorid);
			$guarantorinfo=$guarantordata->{'surname'}." , ".$guarantordata->{'firstname'};
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

	# CHECKS step by step
# STEP 1
    if ($step eq 1) {
		if ($op eq 'add' && checkcardnumber($cardnumber)){ 
			push @errors, 'ERROR_cardnumber';
			$nok = 1;
		} 
        ###############test to take the right zipcode and city name ##############
        if ( $guarantorid eq ''){
          if ($select_city){
            my ($borrower_city,$borrower_zipcode)=&getzipnamecity($select_city);
            $data{'city'}= $borrower_city;
            $data{'zipcode'}=$borrower_zipcode;
            }
        }
        my $dateofbirthmandatory=0;
        map {$dateofbirthmandatory=1 if $_ eq "dateofbirth"} @field_check;
        if ($category_type ne 'I' && $data{dateofbirth} && $dateofbirthmandatory) {
          my $age = GetAge(format_date_in_iso($data{dateofbirth}));
          my $borrowercategory=GetBorrowercategory($data{'categorycode'});   
          if (($age > $borrowercategory->{'upperagelimit'}) or ($age < $borrowercategory->{'dateofbirthrequired'})) {
            push @errors, 'ERROR_age_limitations';
            $nok = 1;
          }
        }
	}

# STEP 2
	if ($step eq 2) {
            if ( ($data{'userid'} eq '')){
              my $onefirstnameletter=substr($data{'firstname'},0,1);
              my $fivesurnameletter=substr($data{'surname'},0,5);
              $data{'userid'}=lc($onefirstnameletter.$fivesurnameletter);
            }
            if ($op eq 'add' and $data{'dateenrolled'} eq ''){
              my $today= sprintf('%04d-%02d-%02d', Today());
              #insert ,in field "dateenrolled" , the current date
              $data{'dateenrolled'}=$today;
              $data{'dateexpiry'} = GetExpiryDate($data{'categorycode'},$today);
            }
            if ($op eq 'modify' ){
              unless ($data{'dateexpiry'}){
                my $today= sprintf('%04d-%02d-%02d', Today());
                $data{'dateexpiry'} = GetExpiryDate($data{'categorycode'},$today);
              }
            }
	}
# STEP 3
	if ($step eq 3) {
		# this value show if the login and password are been used
		my $loginexist=checkuserpassword($borrowernumber,$data{'userid'},$data{'password'});
		# test to know if u must save or create the borrowers
		if ($op eq 'modify'){
			# test to know if another user have the same password and same login		
			if ($loginexist eq 0) {
				&ModMember(%data);		
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
				$borrowernumber = &AddMember(%data);
			        if ($data{'organisations'}){				    
				    # need to add the members organisations
				    my @orgs=split(/\|/,$data{'organisations'});
				    add_member_orgs($borrowernumber,\@orgs);
				 }
			}
 		}

		unless ($nok) {
			if($destination eq "circ"){
				print $input->redirect("/cgi-bin/koha/circ/circulation.pl?findborrower=$data{'cardnumber'}");
			} else {
				if ($loginexist == 0) {
				print $input->redirect("/cgi-bin/koha/members/moremember.pl?borrowernumber=$borrowernumber");
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
	print $input->redirect("/cgi-bin/koha/deletemem.pl?member=$borrowernumber");
} else {  # this else goes down the whole script
	# retrieve previous values : either in DB or in CGI, in case of errors in values
	my $data;
# test to now if u add or modify a borrower (modify =>to take all carateristic of the borrowers)
	if (!$op and !$data{'surname'}) {
		$data=GetMember($borrowernumber,'borrowernumber');
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
#	my $cardnumber=$data{'cardnumber'};
	$data{'cardnumber'}=fixup_cardnumber($data{'cardnumber'}) if $op eq 'add';
	if ($data{'sex'} eq 'F'){
		$template->param(female => 1);
	}
	my ($categories,$labels)=ethnicitycategories();
    
	my $ethnicitycategoriescount=$#{$categories};
	my $ethcatpopup;
	if ($ethnicitycategoriescount>=0) {
		$ethcatpopup = CGI::popup_menu(-name=>'ethnicity',
					-id => 'ethnicity',
		 			-tabindex=>'',
					-values=>$categories,
					-default=>$data{'ethnicity'},
					-labels=>$labels);
		$template->param(ethcatpopup => $ethcatpopup); # bad style, has to be fixed
	}
	
	
	my $action="WHERE category_type=?";
	($categories,$labels)=GetborCatFromCatType($category_type,$action);
	
	if(scalar(@$categories)){
	    #if you modify the borrowers you must have the right value for his category code
	(my $default_category=$data{'categorycode'}) if ($op  eq 'modify');
	    my $catcodepopup = CGI::popup_menu(
	        -name=>'categorycode',
 			-id => 'categorycode',
 			-values=>$categories,
  			-labels=>$labels,
			-default=>$default_category
 	    );
 	    $template->param(catcodepopup=>$catcodepopup);
 	}
	#test in city
	$select_city=getidcity($data{'city'}) if ($guarantorid ne '0');
	($default_city=$select_city) if ($step eq 0);
 	if ($select_city eq '' ){
 	my $selectcity=&getidcity($data{'city'});
 	$default_city=$selectcity;
 	}
	my($cityid,$name_city)=GetCities();
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
 	my($roadtypeid,$road_type)=GetRoadTypes();
  	$template->param( road_cgipopup => 1) if ($roadtypeid );
	my $roadpopup = CGI::popup_menu(-name=>'streettype',
					-id => 'streettype',
					-values=>$roadtypeid,
  					-labels=>$road_type,
   					-override => 1,
					-default=>$default_roadtype
					);	

	my $default_borrowertitle;
	$default_borrowertitle=$data{'title'} ;
 	my($borrowertitle)=GetTitles();
	my $borrotitlepopup = CGI::popup_menu(-name=>'title',
					      -id => 'title',
					      -values=>$borrowertitle,
					      -override => 1,
					      -default=>$default_borrowertitle
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
	my %flags = ( 'gonenoaddress' => ['gonenoaddress', 'Gone no address '],
		      'lost'          => ['lost', 'Lost'],
		      'debarred'      => ['debarred', 'Debarred']);

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
	my $branches=GetBranches();
	my $default;
	# -----------------------------------------------------
	#  the value of ip from the branches hash table
# 		my $select_ip;
	# $ip is the ip of user when is connect to koha 
# 		my $ip = $ENV{'REMOTE_ADDR'};
	
	# -----------------------------------------------------
	foreach my $branch (keys %$branches) {
		if ((not C4::Context->preference("IndependantBranches")) || (C4::Context->userenv->{'flags'} == 1)) {
			push @select_branch, $branch;
			$select_branches{$branch} = $branches->{$branch}->{'branchname'};
 			$default=C4::Context->userenv->{'branch'};
		} else {
			push @select_branch,$branch if ($branch eq C4::Context->userenv->{'branch'});
			$select_branches{$branch} = $branches->{$branch}->{'branchname'} if ($branch eq C4::Context->userenv->{'branch'});
			$default = C4::Context->userenv->{'branch'};
		}
	}
# --------------------------------------------------------------------------------------------------------
 	#in modify mod :default value from $CGIbranch comes from borrowers table
	#in add mod: default value come from branches table (ip correspendence)
	$default=$data{'branchcode'}  if ($op eq 'modify');
	my $CGIbranch = CGI::scrolling_list(-id    => 'branchcode',
					   -name   => 'branchcode',
					   -values => \@select_branch,
					   -labels => \%select_branches,
					   -size   => 1,
					   -override => 1,	
				           -multiple =>0,
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
	$template->param(
		BorrowerMandatoryField => C4::Context->preference("BorrowerMandatoryField"),#field to test with javascript
		category_type	=> $category_type,#to know the category type of the borrower
        DHTMLcalendar_dateformat => get_date_format_string_for_DHTMLcalendar(),
		select_city	=> $select_city,
		"step_$step" 	=> 1,# associate with step to know where u are
		step		=> $step,
		destination 	=> $destination,#to know wher u come from and wher u must go in redirect
		check_member    => $check_member,#to know if the borrower already exist(=>1) or not (=>0) 
# 				flags		=>$data{'flags'},		
		"op$op" 	=> 1,
# 		op			=> $op,
		nodouble	=> $nodouble,
		borrowernumber 	=> $borrowernumber,#register number
		cardnumber	=> $data{'cardnumber'},
		surname         => uc($data{'surname'}),
		firstname       => ucfirst(lc $data{'firstname'}),
		title 		=> $data{'title'},
		othernames	=> $data{'othernames'},
		initials	=> $data{'initials'},
		streetnumber	=> $data{'streetnumber'},
		streettype	=>$data{'streettype'},
		address  	=> $data{'address'},
		address2 	=> $data{'address2'},	
		city	 	=> $data{'city'},
		zipcode 	=> $data{'zipcode'},
		email    	=> $data{'email'},
		phone           => $data{'phone'},
		mobile          => $data{'mobile'},
		fax		=> $data{'fax'},
		phonepro        => $data{'phonepro'},
		emailpro	=> $data{'emailpro'},
		B_address   	=> $data{'B_address'},
		B_city     	=> $data{'B_city'},
		B_zipcode 	=> $data{'B_zipcode'},
		B_email		=> $data{'B_email'},
		B_phone        => $data{'B_phone'},
		dateofbirth	=> $data{'dateofbirth'},
		branchcode      => $data{'branchcode'},
		categorycode 	=> $data{'categorycode'},
		dateenrolled 	=> format_date($data{'dateenrolled'}),
		dateexpiry	=> format_date($data{'dateexpiry'}),
		debarred        => $data{'debarred'},
		gonenoaddress 	=> $data{'gonenoaddress'}, 
		lost 	=> $data{'lost'},
		contactname     => uc($data{'contactname'}),
		contactfirstname=> ucfirst( lc $data{'contactfirstname'}),
		"contacttitle_".$data{'contacttitle'} => "SELECTED" ,
		contacttitle	=> $data{'contacttitle'},
		guarantorid	=> $guarantorid,
		ethcatpopup	=> $ethcatpopup,
		sex		=> $data{'sex'},
		userid 		=> $data{'userid'},	
		password 	=> $data{'password'},	
		opacnote   	=> $data{'opacnote'},	
		contactnote	=> $data{'contactnote'},
		borrowernotes	=> $data{'borrowernotes'},
		relshiploop	=> \@relshipdata,
		relationship	=> $data{'relationship'},
		citypopup	=> $citypopup,
		roadpopup	=> $roadpopup,	
		borrotitlepopup => $borrotitlepopup,
		contacttype	=> $data{'contacttype'},
	        organisations   => $data{'organisations'},
		guarantorinfo   => $guarantorinfo,
		flagloop	=> \@flagdata,
# 		"contacttype_".$data{'contacttype'} =>" SELECTED ",
		dateformat      => display_date_format(),
		check_categorytype =>$check_categorytype,#to recover the category type with checkcategorytype function
		modify          => $modify,
# 		city_choice       => $city_choice ,#check if the city was selected
		nok 		=> $nok,#flag to konw if an error 
		CGIbranch => $CGIbranch,
	        memberofinstution => $member_of_institution,
	        CGIorganisations => $CGIorganisations,
		);
	#$template->param(Institution => 1) if ($categorycode eq "I");
	output_html_with_http_headers $input, $cookie, $template->output;
}

# Local Variables:
# tab-width: 8
# End:
