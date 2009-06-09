#!/usr/bin/perl

#script to administer the categories table
#written 20/02/2002 by paul.poulain@free.fr

# ALGO :
# this script use an $op to know what to do.
# if $op is empty or none of the above values,
#	- the default screen is build (with all records, or filtered datas).
#	- the   user can clic on add, modify or delete record.
# if $op=add_form
#	- if primkey exists, this is a modification,so we read the $primkey record
#	- builds the add/modify form
# if $op=add_validate
#	- the user has just send datas, so we create/modify the record
# if $op=delete_form
#	- we show the record having primkey=$primkey and ask for deletion validation form
# if $op=delete_confirm
#	- we delete the record having primkey=$primkey


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
use C4::Auth;
use C4::Output;
use C4::Form::MessagingPreferences;

sub StringSearch  {
	my ($searchstring,$type)=@_;
	my $dbh = C4::Context->dbh;
	$searchstring=~ s/\'/\\\'/g;
	my @data=split(' ',$searchstring);
	my $count=@data;
	my $sth=$dbh->prepare("Select * from categories where (description like ?) order by category_type,description,categorycode");
	$sth->execute("$data[0]%");
	my @results;
	while (my $data=$sth->fetchrow_hashref){
	push(@results,$data);
	}
	#  $sth->execute;
	$sth->finish;
	return (scalar(@results),\@results);
}

my $input = new CGI;
my $searchfield=$input->param('description');
my $script_name="/cgi-bin/koha/admin/categorie.pl";
my $categorycode=$input->param('categorycode');
my $op = $input->param('op');

my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "admin/categorie.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {parameters => 1},
			     debug => 1,
			     });


$template->param(script_name => $script_name,
		 categorycode => $categorycode,
		 searchfield => $searchfield);


################## ADD_FORM ##################################
# called by default. Used to create form to add or  modify a record
if ($op eq 'add_form') {
	$template->param(add_form => 1);
	
	#---- if primkey exists, it's a modify action, so read values to modify...
	my $data;
	if ($categorycode) {
		my $dbh = C4::Context->dbh;
		my $sth=$dbh->prepare("select categorycode,description,enrolmentperiod,upperagelimit,dateofbirthrequired,enrolmentfee,issuelimit,reservefee,overduenoticerequired,category_type from categories where categorycode=?");
		$sth->execute($categorycode);
		$data=$sth->fetchrow_hashref;
		$sth->finish;
	}

	$template->param(description        => $data->{'description'},
				enrolmentperiod         => $data->{'enrolmentperiod'},
				upperagelimit           => $data->{'upperagelimit'},
				dateofbirthrequired     => $data->{'dateofbirthrequired'},
				enrolmentfee            => sprintf("%.2f",$data->{'enrolmentfee'}),
				overduenoticerequired   => $data->{'overduenoticerequired'},
				issuelimit              => $data->{'issuelimit'},
				reservefee              => sprintf("%.2f",$data->{'reservefee'}),
				category_type           => $data->{'category_type'},
				"type_".$data->{'category_type'} => 1,
				);
    if (C4::Context->preference('EnhancedMessagingPreferences')) {
        C4::Form::MessagingPreferences::set_form_values({ categorycode => $categorycode } , $template);
    }
													# END $OP eq ADD_FORM
################## ADD_VALIDATE ##################################
# called by add_form, used to insert/modify data in DB
} elsif ($op eq 'add_validate') {
	$template->param(add_validate => 1);
	my $is_a_modif = $input->param("is_a_modif");
	my $dbh = C4::Context->dbh;
	if ($is_a_modif) {
            my $sth=$dbh->prepare("UPDATE categories SET description=?,enrolmentperiod=?,upperagelimit=?,dateofbirthrequired=?,enrolmentfee=?,reservefee=?,overduenoticerequired=?,category_type=? WHERE categorycode=?");
            $sth->execute(map { $input->param($_) } ('description','enrolmentperiod','upperagelimit','dateofbirthrequired','enrolmentfee','reservefee','overduenoticerequired','category_type','categorycode'));
            $sth->finish;
        } else {
            my $sth=$dbh->prepare("INSERT INTO categories  (categorycode,description,enrolmentperiod,upperagelimit,dateofbirthrequired,enrolmentfee,reservefee,overduenoticerequired,category_type) values (?,?,?,?,?,?,?,?,?)");
            $sth->execute(map { $input->param($_) } ('categorycode','description','enrolmentperiod','upperagelimit','dateofbirthrequired','enrolmentfee','reservefee','overduenoticerequired','category_type'));
            $sth->finish;
        }
    if (C4::Context->preference('EnhancedMessagingPreferences')) {
        C4::Form::MessagingPreferences::handle_form_action($input, 
                                                           { categorycode => $input->param('categorycode') }, $template);
    }
	print "Content-Type: text/html\n\n<META HTTP-EQUIV=Refresh CONTENT=\"0; URL=categorie.pl\"></html>";
	exit;

													# END $OP eq ADD_VALIDATE
################## DELETE_CONFIRM ##################################
# called by default form, used to confirm deletion of data in DB
} elsif ($op eq 'delete_confirm') {
	$template->param(delete_confirm => 1);

	my $dbh = C4::Context->dbh;
	my $sth=$dbh->prepare("select count(*) as total from borrowers where categorycode=?");
	$sth->execute($categorycode);
	my $total = $sth->fetchrow_hashref;
	$sth->finish;
	$template->param(total => $total->{'total'});
	
	my $sth2=$dbh->prepare("select categorycode,description,enrolmentperiod,upperagelimit,dateofbirthrequired,enrolmentfee,issuelimit,reservefee,overduenoticerequired,category_type from categories where categorycode=?");
	$sth2->execute($categorycode);
	my $data=$sth2->fetchrow_hashref;
	$sth2->finish;
	if ($total->{'total'} >0) {
		$template->param(totalgtzero => 1);
	}

        $template->param(description             => $data->{'description'},
                                enrolmentperiod         => $data->{'enrolmentperiod'},
                                upperagelimit           => $data->{'upperagelimit'},
                                dateofbirthrequired     => $data->{'dateofbirthrequired'},
                                enrolmentfee            =>  sprintf("%.2f",$data->{'enrolmentfee'}),
                                overduenoticerequired   => $data->{'overduenoticerequired'},
                                issuelimit              => $data->{'issuelimit'},
                                reservefee              =>  sprintf("%.2f",$data->{'reservefee'}),
                                category_type           => $data->{'category_type'},
                                );
													# END $OP eq DELETE_CONFIRM
################## DELETE_CONFIRMED ##################################
# called by delete_confirm, used to effectively confirm deletion of data in DB
} elsif ($op eq 'delete_confirmed') {
	$template->param(delete_confirmed => 1);
	my $dbh = C4::Context->dbh;
	my $categorycode=uc($input->param('categorycode'));
	my $sth=$dbh->prepare("delete from categories where categorycode=?");
	$sth->execute($categorycode);
	$sth->finish;
	print "Content-Type: text/html\n\n<META HTTP-EQUIV=Refresh CONTENT=\"0; URL=categorie.pl\"></html>";
	exit;

													# END $OP eq DELETE_CONFIRMED
} else { # DEFAULT
	$template->param(else => 1);
	my @loop;
	my ($count,$results)=StringSearch($searchfield,'web');
	for (my $i=0; $i < $count; $i++){
		my %row = (categorycode => $results->[$i]{'categorycode'},
				description => $results->[$i]{'description'},
				enrolmentperiod => $results->[$i]{'enrolmentperiod'},
				upperagelimit => $results->[$i]{'upperagelimit'},
				dateofbirthrequired => $results->[$i]{'dateofbirthrequired'},
				enrolmentfee => sprintf("%.2f",$results->[$i]{'enrolmentfee'}),
				overduenoticerequired => $results->[$i]{'overduenoticerequired'},
				issuelimit => $results->[$i]{'issuelimit'},
				reservefee => sprintf("%.2f",$results->[$i]{'reservefee'}),
				category_type => $results->[$i]{'category_type'},
				"type_".$results->[$i]{'category_type'} => 1);
        if (C4::Context->preference('EnhancedMessagingPreferences')) {
            my $brief_prefs = _get_brief_messaging_prefs($results->[$i]{'categorycode'});
            $row{messaging_prefs} = $brief_prefs if @$brief_prefs;
        }
		push @loop, \%row;
	}
	$template->param(loop => \@loop);
	# check that I (institution) and C (child) exists. otherwise => warning to the user
	my $dbh = C4::Context->dbh;
	my $sth=$dbh->prepare("select category_type from categories where category_type='C'");
	$sth->execute;
	my ($categoryChild) = $sth->fetchrow;
	$template->param(categoryChild => $categoryChild);
	$sth=$dbh->prepare("select category_type from categories where category_type='I'");
	$sth->execute;
	my ($categoryInstitution) = $sth->fetchrow;
	$template->param(categoryInstitution => $categoryInstitution);
	$sth->finish;


} #---- END $OP eq DEFAULT
output_html_with_http_headers $input, $cookie, $template->output;

exit 0;

sub _get_brief_messaging_prefs {
    my $categorycode = shift;
    my $messaging_options = C4::Members::Messaging::GetMessagingOptions();
    my $results = [];
    PREF: foreach my $option ( @$messaging_options ) {
        my $pref = C4::Members::Messaging::GetMessagingPreferences( { categorycode => $categorycode,
                                                                    message_name       => $option->{'message_name'} } );
        next unless  @{$pref->{'transports'}};
        my $brief_pref = { message_attribute_id => $option->{'message_attribute_id'},
                           message_name => $option->{'message_name'},
                         };
        foreach my $transport ( @{$pref->{'transports'}} ) {
            push @{ $brief_pref->{'transports'} }, { transport => $transport };
        }
        push @$results, $brief_pref;
    }
    return $results;
}
