package C4::Branch;

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
#use warnings; FIXME - Bug 2505
require Exporter;
use C4::Context;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

BEGIN {
	# set the version for version checking
    $VERSION = 3.07.00.049;
	@ISA    = qw(Exporter);
	@EXPORT = qw(
		&GetBranchCategory
		&GetBranchName
		&GetBranch
		&GetBranches
		&GetBranchesLoop
		&GetBranchDetail
		&get_branchinfos_of
		&ModBranch
		&CheckBranchCategorycode
		&GetBranchInfo
		&GetCategoryTypes
		&GetBranchCategories
		&GetBranchesInCategory
		&ModBranchCategoryInfo
		&DelBranch
		&DelBranchCategory
	        &CheckCategoryUnique
		&mybranch
		&GetBranchesCount
	);
    @EXPORT_OK = qw( &onlymine &mybranch );
}

=head1 NAME

C4::Branch - Koha branch module

=head1 SYNOPSIS

use C4::Branch;

=head1 DESCRIPTION

The functions in this module deal with branches.

=head1 FUNCTIONS

=head2 GetBranches

  $branches = &GetBranches();

Returns informations about ALL branches, IndependentBranches Insensitive.
GetBranchInfo() returns the same information.

Create a branch selector with the following code.

=head3 in PERL SCRIPT

    my $branches = GetBranches;
    my @branchloop;
    foreach my $thisbranch (sort keys %$branches) {
        my $selected = 1 if $thisbranch eq $branch;
        my %row =(value => $thisbranch,
                    selected => $selected,
                    branchname => $branches->{$thisbranch}->{branchname},
                );
        push @branchloop, \%row;
    }

=head3 in TEMPLATE

    <select name="branch" id="branch">
        <option value=""></option>
            [% FOREACH branchloo IN branchloop %]
                [% IF ( branchloo.selected ) %]
                    <option value="[% branchloo.value %]" selected="selected">[% branchloo.branchname %]</option>
                [% ELSE %]
                    <option value="[% branchloo.value %]" >[% branchloo.branchname %]</option>
                [% END %]
            [% END %]
    </select>

=head4 Note that you often will want to just use GetBranchesLoop, for exactly the example above.

=cut

sub GetBranches {
    my ($onlymine) = @_;

    # returns a reference to a hash of references to ALL branches...
    my %branches;
    my $dbh = C4::Context->dbh;
    my $sth;
    my $query = "SELECT * FROM branches";
    my @bind_parameters;
    if ( $onlymine && C4::Context->userenv && C4::Context->userenv->{branch} ) {
        $query .= ' WHERE branchcode = ? ';
        push @bind_parameters, C4::Context->userenv->{branch};
    }
    $query .= " ORDER BY branchname";
    $sth = $dbh->prepare($query);
    $sth->execute(@bind_parameters);

    my $relations_sth =
      $dbh->prepare("SELECT branchcode,categorycode FROM branchrelations");
    $relations_sth->execute();
    my %relations;
    while ( my $rel = $relations_sth->fetchrow_hashref ) {
        push @{ $relations{ $rel->{branchcode} } }, $rel->{categorycode};
    }

    while ( my $branch = $sth->fetchrow_hashref ) {
        foreach my $cat ( @{ $relations{ $branch->{branchcode} } } ) {
            $branch->{category}{$cat} = 1;
        }
        $branches{ $branch->{'branchcode'} } = $branch;
    }
    return ( \%branches );
}

sub onlymine {
    return
         C4::Context->preference('IndependentBranches')
      && C4::Context->userenv
      && !C4::Context->IsSuperLibrarian()
      && C4::Context->userenv->{branch};
}

# always returns a string for OK comparison via "eq" or "ne"
sub mybranch {
    C4::Context->userenv           or return '';
    return C4::Context->userenv->{branch} || '';
}

sub GetBranchesLoop {  # since this is what most pages want anyway
    my $branch   = @_ ? shift : mybranch();     # optional first argument is branchcode of "my branch", if preselection is wanted.
    my $onlymine = @_ ? shift : onlymine();
    my $branches = GetBranches($onlymine);
    my @loop;
    foreach my $branchcode ( sort { uc($branches->{$a}->{branchname}) cmp uc($branches->{$b}->{branchname}) } keys %$branches ) {
        push @loop, {
            value      => $branchcode,
            branchcode => $branchcode,
            selected   => ($branchcode eq $branch) ? 1 : 0,
            branchname => $branches->{$branchcode}->{branchname},
        };
    }
    return \@loop;
}

=head2 GetBranchName

=cut

sub GetBranchName {
    my ($branchcode) = @_;
    my $dbh = C4::Context->dbh;
    my $sth;
    $sth = $dbh->prepare("Select branchname from branches where branchcode=?");
    $sth->execute($branchcode);
    my $branchname = $sth->fetchrow_array;
    return ($branchname);
}

=head2 ModBranch

$error = &ModBranch($newvalue);

This function modify an existing branch

C<$newvalue> is a ref to an array wich is containt all the column from branches table.

=cut

sub ModBranch {
    my ($data) = @_;
    
    my $dbh    = C4::Context->dbh;
    if ($data->{add}) {
        my $query  = "
            INSERT INTO branches
            (branchcode,branchname,branchaddress1,
            branchaddress2,branchaddress3,branchzip,branchcity,branchstate,
            branchcountry,branchphone,branchfax,branchemail,
            branchurl,branchip,branchprinter,branchnotes,opac_info,
            branchreplyto, branchreturnpath)
            VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)
        ";
        my $sth    = $dbh->prepare($query);
        $sth->execute(
            $data->{'branchcode'},       $data->{'branchname'},
            $data->{'branchaddress1'},   $data->{'branchaddress2'},
            $data->{'branchaddress3'},   $data->{'branchzip'},
            $data->{'branchcity'},       $data->{'branchstate'},
            $data->{'branchcountry'},
            $data->{'branchphone'},      $data->{'branchfax'},
            $data->{'branchemail'},      $data->{'branchurl'},
            $data->{'branchip'},         $data->{'branchprinter'},
            $data->{'branchnotes'},      $data->{opac_info},
            $data->{'branchreplyto'},    $data->{'branchreturnpath'}
        );
        return 1 if $dbh->err;
    } else {
        my $query  = "
            UPDATE branches
            SET branchname=?,branchaddress1=?,
                branchaddress2=?,branchaddress3=?,branchzip=?,
                branchcity=?,branchstate=?,branchcountry=?,branchphone=?,
                branchfax=?,branchemail=?,branchurl=?,branchip=?,
                branchprinter=?,branchnotes=?,opac_info=?,
                branchreplyto=?, branchreturnpath=?
            WHERE branchcode=?
        ";
        my $sth    = $dbh->prepare($query);
        $sth->execute(
            $data->{'branchname'},
            $data->{'branchaddress1'},   $data->{'branchaddress2'},
            $data->{'branchaddress3'},   $data->{'branchzip'},
            $data->{'branchcity'},       $data->{'branchstate'},       
            $data->{'branchcountry'},
            $data->{'branchphone'},      $data->{'branchfax'},
            $data->{'branchemail'},      $data->{'branchurl'},
            $data->{'branchip'},         $data->{'branchprinter'},
            $data->{'branchnotes'},      $data->{opac_info},
            $data->{'branchreplyto'},    $data->{'branchreturnpath'},
            $data->{'branchcode'},
        );
    }
    # sort out the categories....
    my @checkedcats;
    my $cats = GetBranchCategories();
    foreach my $cat (@$cats) {
        my $code = $cat->{'categorycode'};
        if ( $data->{$code} ) {
            push( @checkedcats, $code );
        }
    }
    my $branchcode = uc( $data->{'branchcode'} );
    my $branch     = GetBranchInfo($branchcode);
    $branch = $branch->[0];
    my $branchcats = $branch->{'categories'};
    my @addcats;
    my @removecats;
    foreach my $bcat (@$branchcats) {

        unless ( grep { /^$bcat$/ } @checkedcats ) {
            push( @removecats, $bcat );
        }
    }
    foreach my $ccat (@checkedcats) {
        unless ( grep { /^$ccat$/ } @$branchcats ) {
            push( @addcats, $ccat );
        }
    }
    foreach my $cat (@addcats) {
        my $sth =
          $dbh->prepare(
"insert into branchrelations (branchcode, categorycode) values(?, ?)"
          );
        $sth->execute( $branchcode, $cat );
    }
    foreach my $cat (@removecats) {
        my $sth =
          $dbh->prepare(
            "delete from branchrelations where branchcode=? and categorycode=?"
          );
        $sth->execute( $branchcode, $cat );
    }
}

=head2 GetBranchCategory

$results = GetBranchCategory($categorycode);

C<$results> is an hashref

=cut

sub GetBranchCategory {
    my ($catcode) = @_;
    return unless $catcode;

    my $dbh = C4::Context->dbh;
    my $sth;

    $sth = $dbh->prepare(q{
        SELECT *
        FROM branchcategories
        WHERE categorycode = ?
    });
    $sth->execute( $catcode );
    return $sth->fetchrow_hashref;
}

=head2 GetBranchCategories

  my $categories = GetBranchCategories($categorytype,$show_in_pulldown,$selected_in_pulldown);

Returns a list ref of anon hashrefs with keys eq columns of branchcategories table,
i.e. categorydescription, categorytype, categoryname.

=cut

sub GetBranchCategories {
    my ( $categorytype, $show_in_pulldown, $selected_in_pulldown ) = @_;
    my $dbh = C4::Context->dbh();

    my $query = "SELECT * FROM branchcategories ";

    my ( @where, @bind );
    if ( $categorytype ) {
        push @where, " categorytype = ? ";
        push @bind, $categorytype;
    }

    if ( defined( $show_in_pulldown ) ) {
        push( @where, " show_in_pulldown = ? " );
        push( @bind, $show_in_pulldown );
    }

    $query .= " WHERE " . join(" AND ", @where) if(@where);
    $query .= " ORDER BY categorytype, categorycode";
    my $sth=$dbh->prepare( $query);
    $sth->execute(@bind);

    my $branchcats = $sth->fetchall_arrayref({});

    if ( $selected_in_pulldown ) {
        foreach my $bc ( @$branchcats ) {
            $bc->{selected} = 1 if $bc->{categorycode} eq $selected_in_pulldown;
        }
    }

    return $branchcats;
}

=head2 GetCategoryTypes

$categorytypes = GetCategoryTypes;
returns a list of category types.
Currently these types are HARDCODED.
type: 'searchdomain' defines a group of agencies that the calling library may search in.
Other usage of agency categories falls under type: 'properties'.
	to allow for other uses of categories.
The searchdomain bit may be better implemented as a separate module, but
the categories were already here, and minimally used.
=cut

	#TODO  manage category types.  rename possibly to 'agency domains' ? as borrowergroups are called categories.
sub GetCategoryTypes {
	return ( 'searchdomain','properties');
}

=head2 GetBranch

$branch = GetBranch( $query, $branches );

=cut

sub GetBranch {
    my ( $query, $branches ) = @_;    # get branch for this query from branches
    my $branch = $query->param('branch');
    my %cookie = $query->cookie('userenv');
    ($branch)                || ($branch = $cookie{'branchname'});
    ( $branches->{$branch} ) || ( $branch = ( keys %$branches )[0] );
    return $branch;
}

=head2 GetBranchDetail

    $branch = &GetBranchDetail($branchcode);

Given the branch code, the function returns a
hashref for the corresponding row in the branches table.

=cut

sub GetBranchDetail {
    my ($branchcode) = shift or return;
    my $sth = C4::Context->dbh->prepare("SELECT * FROM branches WHERE branchcode = ?");
    $sth->execute($branchcode);
    return $sth->fetchrow_hashref();
}

=head2 GetBranchesInCategory

  my $branches = GetBranchesInCategory($categorycode);

Returns a href:  keys %$branches eq (branchcode,branchname) .

=cut

sub GetBranchesInCategory {
    my ($categorycode) = @_;
	my @branches;
	my $dbh = C4::Context->dbh();
	my $sth=$dbh->prepare( "SELECT b.branchcode FROM branchrelations r, branches b 
							where r.branchcode=b.branchcode and r.categorycode=?");
    $sth->execute($categorycode);
	while (my $branch = $sth->fetchrow) {
		push @branches, $branch;
	}
	return( \@branches );
}

=head2 GetBranchInfo

$results = GetBranchInfo($branchcode);

returns C<$results>, a reference to an array of hashes containing branches.
if $branchcode, just this branch, with associated categories.
if ! $branchcode && $categorytype, all branches in the category.
=cut

sub GetBranchInfo {
    my ($branchcode,$categorytype) = @_;
    my $dbh = C4::Context->dbh;
    my $sth;


	if ($branchcode) {
        $sth =
          $dbh->prepare(
            "Select * from branches where branchcode = ? order by branchcode");
        $sth->execute($branchcode);
    }
    else {
        $sth = $dbh->prepare("Select * from branches order by branchcode");
        $sth->execute();
    }
    my @results;
    while ( my $data = $sth->fetchrow_hashref ) {
		my @bind = ($data->{'branchcode'});
        my $query= "select r.categorycode from branchrelations r";
		$query .= ", branchcategories c " if($categorytype);
		$query .= " where  branchcode=? ";
		if($categorytype) { 
			$query .= " and c.categorytype=? and r.categorycode=c.categorycode";
			push @bind, $categorytype;
		}
        my $nsth=$dbh->prepare($query);
		$nsth->execute( @bind );
        my @cats = ();
        while ( my ($cat) = $nsth->fetchrow_array ) {
            push( @cats, $cat );
        }
        $data->{'categories'} = \@cats;
        push( @results, $data );
    }
    return \@results;
}

=head2 DelBranch

&DelBranch($branchcode);

=cut

sub DelBranch {
    my ($branchcode) = @_;
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("delete from branches where branchcode = ?");
    $sth->execute($branchcode);
}

=head2 ModBranchCategoryInfo

&ModBranchCategoryInfo($data);
sets the data from the editbranch form, and writes to the database...

=cut

sub ModBranchCategoryInfo {
    my ($data) = @_;
    my $dbh    = C4::Context->dbh;
    if ($data->{'add'}){
	# we are doing an insert
  my $sth   = $dbh->prepare("INSERT INTO branchcategories (categorycode,categoryname,codedescription,categorytype,show_in_pulldown) VALUES (?,?,?,?,?)");
        $sth->execute(uc( $data->{'categorycode'} ),$data->{'categoryname'}, $data->{'codedescription'},$data->{'categorytype'},$data->{'show_in_pulldown'} );
    }
    else {
	# modifying
        my $sth = $dbh->prepare("UPDATE branchcategories SET categoryname=?,codedescription=?,categorytype=?,show_in_pulldown=? WHERE categorycode=?");
        $sth->execute($data->{'categoryname'}, $data->{'codedescription'},$data->{'categorytype'},$data->{'show_in_pulldown'},uc( $data->{'categorycode'} ) );
    }
}

=head2 CheckCategoryUnique

if (CheckCategoryUnique($categorycode)){
  # do something
}

=cut

sub CheckCategoryUnique {
    my $categorycode = shift;
    my $dbh    = C4::Context->dbh;
    my $sth = $dbh->prepare("SELECT categorycode FROM branchcategories WHERE categorycode = ?");
    $sth->execute(uc( $categorycode) );
    if (my $data = $sth->fetchrow_hashref){
	return 0;
    }
    else {
	return 1;
    }
}

    
=head2 DeleteBranchCategory

DeleteBranchCategory($categorycode);

=cut

sub DelBranchCategory {
    my ($categorycode) = @_;
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("delete from branchcategories where categorycode = ?");
    $sth->execute($categorycode);
}

=head2 CheckBranchCategorycode

$number_rows_affected = CheckBranchCategorycode($categorycode);

=cut

sub CheckBranchCategorycode {

    # check to see if the branchcode is being used in the database somewhere....
    my ($categorycode) = @_;
    my $dbh            = C4::Context->dbh;
    my $sth            =
      $dbh->prepare(
        "select count(*) from branchrelations where categorycode=?");
    $sth->execute($categorycode);
    my ($total) = $sth->fetchrow_array;
    return $total;
}

sub GetBranchesCount {
    my $dbh = C4::Context->dbh();
    my $query = "SELECT COUNT(*) AS branches_count FROM branches";
    my $sth = $dbh->prepare( $query );
    $sth->execute();
    my $row = $sth->fetchrow_hashref();
    return $row->{'branches_count'};
}

1;
__END__

=head1 AUTHOR

Koha Development Team <http://koha-community.org/>

=cut
