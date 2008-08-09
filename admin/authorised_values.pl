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
use C4::Koha;
use C4::Output;


sub AuthorizedValuesForCategory  {
    my ($searchstring,$type)=@_;
    my $dbh = C4::Context->dbh;
    $searchstring=~ s/\'/\\\'/g;
    my @data=split(' ',$searchstring);
    my $count=@data;
    my $sth=$dbh->prepare( 'Select id, category, authorised_value, lib, imageurl
                              from authorised_values
                              where (category = ?)
                              order by category,authorised_value' );
    $sth->execute("$data[0]");
    my @results;
    my $cnt=0;
    while (my $data=$sth->fetchrow_hashref){
	push(@results,$data);
	$cnt ++;
    }
    $sth->finish;
    return ($cnt,\@results);
}

my $input = new CGI;
my $searchfield=$input->param('searchfield');
$searchfield=~ s/\,//g;
my $id = $input->param('id');
my $offset=$input->param('offset');
my $script_name="/cgi-bin/koha/admin/authorised_values.pl";
my $dbh = C4::Context->dbh;

my ($template, $borrowernumber, $cookie)
    = get_template_and_user({template_name => "admin/authorised_values.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {parameters => 1},
			     debug => 1,
			     });
my $pagesize=20;
my $op = $input->param('op');

if ($op) {
$template->param(script_name => $script_name,
						$op              => 1); # we show only the TMPL_VAR names $op
} else {
$template->param(script_name => $script_name,
						else              => 1); # we show only the TMPL_VAR names $op
}
################## ADD_FORM ##################################
# called by default. Used to create form to add or  modify a record
if ($op eq 'add_form') {
	my $data;
	if ($id) {
		my $dbh = C4::Context->dbh;
		my $sth=$dbh->prepare("select id, category, authorised_value, lib, imageurl from authorised_values where id=?");
		$sth->execute($id);
		$data=$sth->fetchrow_hashref;
		$sth->finish;
	} else {
		$data->{'category'} = $input->param('category');
	}
	if ($id) {
		$template->param(action_modify => 1);
		$template->param('heading-modify-authorized-value-p' => 1);
	} elsif ( ! $data->{'category'} ) {
		$template->param(action_add_category => 1);
		$template->param('heading-add-new-category-p' => 1);
	} else {
		$template->param(action_add_value => 1);
		$template->param('heading-add-authorized-value-p' => 1);
	}
	$template->param('use-heading-flags-p' => 1);
	$template->param( category        => $data->{'category'},
                         authorised_value => $data->{'authorised_value'},
                         lib              => $data->{'lib'},
                         id               => $data->{'id'},
                         imagesets        => C4::Koha::getImageSets( checked => $data->{'imageurl'} )
                     );
                          
################## ADD_VALIDATE ##################################
# called by add_form, used to insert/modify data in DB
} elsif ($op eq 'add_validate') {
	my $dbh = C4::Context->dbh;
    my $new_category = $input->param('category');
    my $new_authorised_value = $input->param('authorised_value');
    my $imageurl=$input->param( 'imageurl' )|'';   
	$imageurl = '' if $imageurl =~ /removeImage/;
    my $duplicate_entry = 0;

    if ( $id ) { # Update
        my $sth = $dbh->prepare( "SELECT category, authorised_value FROM authorised_values WHERE id='$id' ");
        $sth->execute();
        my ($category, $authorised_value) = $sth->fetchrow_array();
        $sth->finish;
        if ( $authorised_value ne $new_authorised_value ) {
            my $sth = $dbh->prepare_cached( "SELECT COUNT(*) FROM authorised_values " .
                "WHERE category = '$new_category' AND authorised_value = '$new_authorised_value' and id<>$id");
            $sth->execute();
            ($duplicate_entry) = $sth->fetchrow_array();
            warn "**** duplicate_entry = $duplicate_entry";
        }
        unless ( $duplicate_entry ) {
            my $sth=$dbh->prepare( 'UPDATE authorised_values
                                      SET category         = ?,
                                          authorised_value = ?,
                                          lib              = ?,
                                          imageurl         = ?
                                      WHERE id=?' );
            my $lib = $input->param('lib');
            undef $lib if ($lib eq ""); # to insert NULL instead of a blank string
            $sth->execute($new_category, $new_authorised_value, $lib, $imageurl, $id);          
            print "Content-Type: text/html\n\n<META HTTP-EQUIV=Refresh CONTENT=\"0; URL=authorised_values.pl?searchfield=".$new_category."\"></html>";
            exit;
        }
    }
    else { # Insert
        my $sth = $dbh->prepare_cached( "SELECT COUNT(*) FROM authorised_values " .
            "WHERE category = '$new_category' AND authorised_value = '$new_authorised_value' ");
        $sth->execute();
        ($duplicate_entry) = $sth->fetchrow_array();
        $sth->finish();
        unless ( $duplicate_entry ) {
            my $sth=$dbh->prepare( 'INSERT INTO authorised_values
                                    ( id, category, authorised_value, lib, imageurl )
                                    values (?, ?, ?, ?, ?)' );
    	    my $lib = $input->param('lib');
    	    undef $lib if ($lib eq ""); # to insert NULL instead of a blank string
    	    $sth->execute($id, $new_category, $new_authorised_value, $lib, $imageurl );
    	    $sth->finish;
    	    print "Content-Type: text/html\n\n<META HTTP-EQUIV=Refresh CONTENT=\"0; URL=authorised_values.pl?searchfield=".$input->param('category')."\"></html>";
    	    exit;
        }
    }
    if ( $duplicate_entry ) {       
        $template->param(duplicate_category => $new_category,
                         duplicate_value =>  $new_authorised_value,
                         else => 1);
        default_form();
     }           
	
################## DELETE_CONFIRM ##################################
# called by default form, used to confirm deletion of data in DB
} elsif ($op eq 'delete_confirm') {
	my $dbh = C4::Context->dbh;
	my $sth=$dbh->prepare("select category,authorised_value,lib from authorised_values where id=?");
	$sth->execute($id);
	my $data=$sth->fetchrow_hashref;
	$sth->finish;
	$id = $input->param('id') unless $id;
	$template->param(searchfield => $searchfield,
							Tlib => $data->{'lib'},
							Tvalue => $data->{'authorised_value'},
							id =>$id,
							);

													# END $OP eq DELETE_CONFIRM
################## DELETE_CONFIRMED ##################################
# called by delete_confirm, used to effectively confirm deletion of data in DB
} elsif ($op eq 'delete_confirmed') {
	my $dbh = C4::Context->dbh;
	my $id = $input->param('id');
	my $sth=$dbh->prepare("delete from authorised_values where id=?");
	$sth->execute($id);
	$sth->finish;
	print "Content-Type: text/html\n\n<META HTTP-EQUIV=Refresh CONTENT=\"0; URL=authorised_values.pl?searchfield=$searchfield\"></html>";
	exit;

													# END $OP eq DELETE_CONFIRMED
################## DEFAULT ##################################
} else { # DEFAULT
    default_form();
} #---- END $OP eq DEFAULT
output_html_with_http_headers $input, $cookie, $template->output;

exit 0;

sub default_form {
	# build categories list
	my $sth = $dbh->prepare("select distinct category from authorised_values");
	$sth->execute;
	# the list
	my @category_list;
	# a hash, to check that some hardcoded categories exist.
	my %categories;
	while ( my ($category) = $sth->fetchrow_array) {
		push(@category_list,$category);
		$categories{$category} = 1;
	}
	# push koha system categories
	push @category_list, 'Asort1' unless $categories{'Asort1'};
	push @category_list, 'Asort2' unless $categories{'Asort2'};
	push @category_list, 'Bsort1' unless $categories{'Bsort1'};
	push @category_list, 'Bsort2' unless $categories{'Bsort2'};
	push @category_list, 'SUGGEST' unless $categories{'SUGGEST'};
	push @category_list, 'DAMAGED' unless $categories{'DAMAGED'};
	push @category_list, 'LOST' unless $categories{'LOST'};
	#reorder the list
	@category_list = sort {$a cmp $b} @category_list;
	my $tab_list = CGI::scrolling_list(-name=>'searchfield',
	        -id=>'searchfield',
			-values=> \@category_list,
			-default=>"",
			-size=>1,
 			-tabindex=>'',
			-multiple=>0,
			);
	if (!$searchfield) {
		$searchfield=$category_list[0];
	}
	my ($count,$results)=AuthorizedValuesForCategory($searchfield,'web');
	my $toggle=1;
	my @loop_data = ();
	# builds value list
	for (my $i=$offset; $i < ($offset+$pagesize<$count?$offset+$pagesize:$count); $i++){
	  	if ($toggle eq 1){
			$toggle=1;
	  	} else {
			$toggle=0;
	  	}
		my %row_data;  # get a fresh hash for the row data
		$row_data{category}         = $results->[$i]{'category'};
		$row_data{authorised_value} = $results->[$i]{'authorised_value'};
		$row_data{lib}              = $results->[$i]{'lib'};
		$row_data{imageurl}         =  getitemtypeimagesrc('intranet') . '/' . $results->[$i]{'imageurl'};
		$row_data{edit}             = "$script_name?op=add_form&amp;id=".$results->[$i]{'id'};
		$row_data{delete}           = "$script_name?op=delete_confirm&amp;searchfield=$searchfield&amp;id=".$results->[$i]{'id'};
		push(@loop_data, \%row_data);
	}

	$template->param( loop     => \@loop_data,
                          tab_list => $tab_list,
                          category => $searchfield );

	if ($offset>0) {
		my $prevpage = $offset-$pagesize;
		$template->param(isprevpage => $offset,
						prevpage=> $prevpage,
						searchfield => $searchfield,
						script_name => $script_name,
		 );
	}
	if ($offset+$pagesize<$count) {
		my $nextpage =$offset+$pagesize;
		$template->param(nextpage =>$nextpage,
						searchfield => $searchfield,
						script_name => $script_name,
		);
	}
}

