#!/usr/bin/perl

# Copyright 2000-2002 Katipo Communications
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

use strict;
use warnings;

use CGI;
use C4::Auth;
use C4::Branch;
use C4::Context;
use C4::Koha;
use C4::Output;


sub AuthorizedValuesForCategory {
    my ($searchstring) = shift or return;
    my $dbh = C4::Context->dbh;
    $searchstring=~ s/\'/\\\'/g;
    my @data=split(' ',$searchstring);
    my $sth=$dbh->prepare('
          SELECT  id, category, authorised_value, lib, lib_opac, imageurl
            FROM  authorised_values
           WHERE  (category = ?)
        ORDER BY  category, authorised_value
    ');
    $sth->execute("$data[0]");
    return $sth->fetchall_arrayref({});
}

my $input = new CGI;
my $id          = $input->param('id');
my $op          = $input->param('op')     || '';
our $offset      = $input->param('offset') || 0;
our $searchfield = $input->param('searchfield');
$searchfield = '' unless defined $searchfield;
$searchfield =~ s/\,//g;
our $script_name = "/cgi-bin/koha/admin/authorised_values.pl";
our $dbh = C4::Context->dbh;

our ($template, $borrowernumber, $cookie)= get_template_and_user({
    template_name => "admin/authorised_values.tt",
    authnotrequired => 0,
    flagsrequired => {parameters => 'parameters_remaining_permissions'},
    query => $input,
    type => "intranet",
    debug => 1,
});

$template->param(  script_name => $script_name,
                 ($op||'else') => 1 );
################## ADD_FORM ##################################
# called by default. Used to create form to add or  modify a record
if ($op eq 'add_form') {
	my $data;
    my @selected_branches;
	if ($id) {
		my $sth=$dbh->prepare("select id, category, authorised_value, lib, lib_opac, imageurl from authorised_values where id=?");
		$sth->execute($id);
		$data=$sth->fetchrow_hashref;
        $sth = $dbh->prepare("SELECT b.branchcode, b.branchname FROM authorised_values_branches AS avb, branches AS b WHERE avb.branchcode = b.branchcode AND avb.av_id = ?;");
        $sth->execute( $id );
        while ( my $branch = $sth->fetchrow_hashref ) {
            push @selected_branches, $branch;
        }
	} else {
		$data->{'category'} = $input->param('category');
	}

    my $branches = GetBranches;
    my @branches_loop;

    foreach my $branchcode ( sort { uc($branches->{$a}->{branchname}) cmp uc($branches->{$b}->{branchname}) } keys %$branches ) {
        my $selected = ( grep {$_->{branchcode} eq $branchcode} @selected_branches ) ? 1 : 0;
        push @branches_loop, {
            branchcode => $branchcode,
            branchname => $branches->{$branchcode}->{branchname},
            selected => $selected,
        };
    }

	if ($id) {
		$template->param(action_modify => 1);
		$template->param('heading_modify_authorized_value_p' => 1);
	} elsif ( ! $data->{'category'} ) {
		$template->param(action_add_category => 1);
		$template->param('heading_add_new_category_p' => 1);
	} else {
		$template->param(action_add_value => 1);
		$template->param('heading_add_authorized_value_p' => 1);
	}
	$template->param('use_heading_flags_p' => 1);
	$template->param( category        => $data->{'category'},
                         authorised_value => $data->{'authorised_value'},
                         lib              => $data->{'lib'},
                         lib_opac         => $data->{'lib_opac'},
                         id               => $data->{'id'},
                         imagesets        => C4::Koha::getImageSets( checked => $data->{'imageurl'} ),
                         offset           => $offset,
                         branches_loop    => \@branches_loop,
                     );
                          
################## ADD_VALIDATE ##################################
# called by add_form, used to insert/modify data in DB
} elsif ($op eq 'add_validate') {
    my $new_authorised_value = $input->param('authorised_value');
    my $new_category = $input->param('category');
    my $imageurl     = $input->param( 'imageurl' ) || '';
	$imageurl = '' if $imageurl =~ /removeImage/;
    my $duplicate_entry = 0;
    my @branches = $input->param('branches');

    if ( $id ) { # Update
        my $sth = $dbh->prepare( "SELECT category, authorised_value FROM authorised_values WHERE id = ? ");
        $sth->execute($id);
        my ($category, $authorised_value) = $sth->fetchrow_array();
        if ( $authorised_value ne $new_authorised_value ) {
            my $sth = $dbh->prepare_cached( "SELECT COUNT(*) FROM authorised_values " .
                "WHERE category = ? AND authorised_value = ? and id <> ? ");
            $sth->execute($new_category, $new_authorised_value, $id);
            ($duplicate_entry) = $sth->fetchrow_array();
        }
        unless ( $duplicate_entry ) {
            my $sth=$dbh->prepare( 'UPDATE authorised_values
                                      SET category         = ?,
                                          authorised_value = ?,
                                          lib              = ?,
                                          lib_opac         = ?,
                                          imageurl         = ?
                                      WHERE id=?' );
            my $lib = $input->param('lib');
            my $lib_opac = $input->param('lib_opac');
            undef $lib if ($lib eq ""); # to insert NULL instead of a blank string
            undef $lib_opac if ($lib_opac eq ""); # to insert NULL instead of a blank string
            $sth->execute($new_category, $new_authorised_value, $lib, $lib_opac, $imageurl, $id);
            if ( @branches ) {
                $sth = $dbh->prepare("DELETE FROM authorised_values_branches WHERE av_id = ?");
                $sth->execute( $id );
                $sth = $dbh->prepare(
                    "INSERT INTO authorised_values_branches
                                ( av_id, branchcode )
                                VALUES ( ?, ? )"
                );
                for my $branchcode ( @branches ) {
                    next if not $branchcode;
                    $sth->execute($id, $branchcode);
                }
            }
            $sth->finish;
            print "Content-Type: text/html\n\n<META HTTP-EQUIV=Refresh CONTENT=\"0; URL=authorised_values.pl?searchfield=".$new_category."&offset=$offset\"></html>";
            exit;
        }
    }
    else { # Insert
        my $sth = $dbh->prepare_cached( "SELECT COUNT(*) FROM authorised_values " .
            "WHERE category = ? AND authorised_value = ? ");
        $sth->execute($new_category, $new_authorised_value);
        ($duplicate_entry) = $sth->fetchrow_array();
        unless ( $duplicate_entry ) {
            my $sth=$dbh->prepare( 'INSERT INTO authorised_values
                                    ( category, authorised_value, lib, lib_opac, imageurl )
                                    values (?, ?, ?, ?, ?)' );
    	    my $lib = $input->param('lib');
    	    my $lib_opac = $input->param('lib_opac');
    	    undef $lib if ($lib eq ""); # to insert NULL instead of a blank string
    	    undef $lib_opac if ($lib_opac eq ""); # to insert NULL instead of a blank string
            $sth->execute( $new_category, $new_authorised_value, $lib, $lib_opac, $imageurl );
            $id = $dbh->{'mysql_insertid'};
            if ( @branches ) {
                $sth = $dbh->prepare(
                    "INSERT INTO authorised_values_branches
                                ( av_id, branchcode )
                                VALUES ( ?, ? )"
                );
                for my $branchcode ( @branches ) {
                    next if not $branchcode;
                    $sth->execute($id, $branchcode);
                }
            }
    	    print "Content-Type: text/html\n\n<META HTTP-EQUIV=Refresh CONTENT=\"0; URL=authorised_values.pl?searchfield=".$input->param('category')."&offset=$offset\"></html>";
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
	my $sth=$dbh->prepare("select category,authorised_value,lib,lib_opac from authorised_values where id=?");
	$sth->execute($id);
	my $data=$sth->fetchrow_hashref;
	$id = $input->param('id') unless $id;
	$template->param(searchfield => $searchfield,
							Tlib => $data->{'lib'},
							Tlib_opac => $data->{'lib_opac'},
							Tvalue => $data->{'authorised_value'},
							id =>$id,
							);

													# END $OP eq DELETE_CONFIRM
################## DELETE_CONFIRMED ##################################
# called by delete_confirm, used to effectively confirm deletion of data in DB
} elsif ($op eq 'delete_confirmed') {
	my $id = $input->param('id');
	my $sth=$dbh->prepare("delete from authorised_values where id=?");
	$sth->execute($id);
	print "Content-Type: text/html\n\n<META HTTP-EQUIV=Refresh CONTENT=\"0; URL=authorised_values.pl?searchfield=$searchfield&offset=$offset\"></html>";
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
    my $category_list = C4::Koha::GetAuthorisedValueCategories();
    my @category_list = @{$category_list};
    my %categories;    # a hash, to check that some hardcoded categories exist.
    for my $category ( @category_list ) {
        $categories{$category} = 1;
    }

    # push koha system categories
    foreach (qw(Asort1 Asort2 Bsort1 Bsort2 SUGGEST DAMAGED LOST REPORT_GROUP REPORT_SUBGROUP DEPARTMENT TERM SUGGEST_STATUS)) {
        push @category_list, $_ unless $categories{$_};
    }

	#reorder the list
    @category_list = sort {lc($a) cmp lc($b)} @category_list;
	if (!$searchfield) {
		$searchfield=$category_list[0];
	}
    my $tab_list = {
        values  => \@category_list,
        default => $searchfield,
    };
    my ($results) = AuthorizedValuesForCategory($searchfield);
    my $count = scalar(@$results);
	my @loop_data = ();
	# builds value list
    my $sth = $dbh->prepare("SELECT b.branchcode, b.branchname FROM authorised_values_branches AS avb, branches AS b WHERE avb.branchcode = b.branchcode AND avb.av_id = ?");
	for (my $i=0; $i < $count; $i++){
        $sth->execute( $results->[$i]{id} );
        my @selected_branches;
        while ( my $branch = $sth->fetchrow_hashref ) {
            push @selected_branches, $branch;
        }
		my %row_data;  # get a fresh hash for the row data
		$row_data{category}              = $results->[$i]{'category'};
		$row_data{authorised_value}      = $results->[$i]{'authorised_value'};
		$row_data{lib}                   = $results->[$i]{'lib'};
		$row_data{lib_opac}              = $results->[$i]{'lib_opac'};
		$row_data{imageurl}              = getitemtypeimagelocation( 'intranet', $results->[$i]{'imageurl'} );
		$row_data{edit}                  = "$script_name?op=add_form&amp;id=".$results->[$i]{'id'}."&amp;offset=$offset";
		$row_data{delete}                = "$script_name?op=delete_confirm&amp;searchfield=$searchfield&amp;id=".$results->[$i]{'id'}."&amp;offset=$offset";
        $row_data{branches}              = \@selected_branches;
		push(@loop_data, \%row_data);
	}

    $template->param(
            loop     => \@loop_data,
            tab_list => $tab_list,
            category => $searchfield,
    );
}

