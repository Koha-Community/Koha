package C4::Koha;

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
require Exporter;
use C4::Context;

use vars qw($VERSION @ISA @EXPORT);

$VERSION = 0.01;

=head1 NAME

C4::Koha - Perl Module containing convenience functions for Koha scripts

=head1 SYNOPSIS

  use C4::Koha;


  $date = slashifyDate("01-01-2002")
  $ethnicity = fixEthnicity('asian');
  ($categories, $labels) = borrowercategories();
  ($categories, $labels) = ethnicitycategories();

=head1 DESCRIPTION

Koha.pm provides many functions for Koha scripts.

=head1 FUNCTIONS

=over 2

=cut

@ISA = qw(Exporter);
@EXPORT = qw(&slashifyDate
			&fixEthnicity
			&borrowercategories
			&ethnicitycategories
			&subfield_is_koha_internal_p
			&getbranches &getbranch
			&getprinters &getprinter
			&getitemtypes &getitemtypeinfo
			$DEBUG);

use vars qw();

my $DEBUG = 0;

=head2 slashifyDate

  $slash_date = &slashifyDate($dash_date);

Takes a string of the form "DD-MM-YYYY" (or anything separated by
dashes), converts it to the form "YYYY/MM/DD", and returns the result.

=cut

sub slashifyDate {
    # accepts a date of the form xx-xx-xx[xx] and returns it in the
    # form xx/xx/xx[xx]
    my @dateOut = split('-', shift);
    return("$dateOut[2]/$dateOut[1]/$dateOut[0]")
}

=head2 fixEthnicity

  $ethn_name = &fixEthnicity($ethn_code);

Takes an ethnicity code (e.g., "european" or "pi") and returns the
corresponding descriptive name from the C<ethnicity> table in the
Koha database ("European" or "Pacific Islander").

=cut
#'

sub fixEthnicity($) {

    my $ethnicity = shift;
    my $dbh = C4::Context->dbh;
    my $sth=$dbh->prepare("Select name from ethnicity where code = ?");
    $sth->execute($ethnicity);
    my $data=$sth->fetchrow_hashref;
    $sth->finish;
    return $data->{'name'};
}

=head2 borrowercategories

  ($codes_arrayref, $labels_hashref) = &borrowercategories();

Looks up the different types of borrowers in the database. Returns two
elements: a reference-to-array, which lists the borrower category
codes, and a reference-to-hash, which maps the borrower category codes
to category descriptions.

=cut
#'

sub borrowercategories {
    my $dbh = C4::Context->dbh;
    my $sth=$dbh->prepare("Select categorycode,description from categories order by description");
    $sth->execute;
    my %labels;
    my @codes;
    while (my $data=$sth->fetchrow_hashref){
      push @codes,$data->{'categorycode'};
      $labels{$data->{'categorycode'}}=$data->{'description'};
    }
    $sth->finish;
    return(\@codes,\%labels);
}

=head2 ethnicitycategories

  ($codes_arrayref, $labels_hashref) = &ethnicitycategories();

Looks up the different ethnic types in the database. Returns two
elements: a reference-to-array, which lists the ethnicity codes, and a
reference-to-hash, which maps the ethnicity codes to ethnicity
descriptions.

=cut
#'

sub ethnicitycategories {
    my $dbh = C4::Context->dbh;
    my $sth=$dbh->prepare("Select code,name from ethnicity order by name");
    $sth->execute;
    my %labels;
    my @codes;
    while (my $data=$sth->fetchrow_hashref){
      push @codes,$data->{'code'};
      $labels{$data->{'code'}}=$data->{'name'};
    }
    $sth->finish;
    return(\@codes,\%labels);
}

# FIXME.. this should be moved to a MARC-specific module
sub subfield_is_koha_internal_p ($) {
    my($subfield) = @_;

    # We could match on 'lib' and 'tab' (and 'mandatory', & more to come!)
    # But real MARC subfields are always single-character
    # so it really is safer just to check the length

    return length $subfield != 1;
}

=head2 getbranches

  $branches = &getbranches();
  returns informations about branches.
  Create a branch selector with the following code
  
=head3 in PERL SCRIPT

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


=head3 in TEMPLATE  
			<select name="branch">
				<option value="">Default</option>
			<!-- TMPL_LOOP name="branchloop" -->
				<option value="<!-- TMPL_VAR name="value" -->" <!-- TMPL_IF name="selected" -->selected<!-- /TMPL_IF -->><!-- TMPL_VAR name="branchname" --></option>
			<!-- /TMPL_LOOP -->
			</select>

=cut

sub getbranches {
# returns a reference to a hash of references to branches...
	my %branches;
	my $dbh = C4::Context->dbh;
	my $sth=$dbh->prepare("select * from branches");
	$sth->execute;
	while (my $branch=$sth->fetchrow_hashref) {
		my $nsth = $dbh->prepare("select categorycode from branchrelations where branchcode = ?");
		$nsth->execute($branch->{'branchcode'});
		while (my ($cat) = $nsth->fetchrow_array) {
			# FIXME - This seems wrong. It ought to be
			# $branch->{categorycodes}{$cat} = 1;
			# otherwise, there's a namespace collision if there's a
			# category with the same name as a field in the 'branches'
			# table (i.e., don't create a category called "issuing").
			# In addition, the current structure doesn't really allow
			# you to list the categories that a branch belongs to:
			# you'd have to list keys %$branch, and remove those keys
			# that aren't fields in the "branches" table.
			$branch->{$cat} = 1;
			}
			$branches{$branch->{'branchcode'}}=$branch;
	}
	return (\%branches);
}

=head2 itemtypes

  $itemtypes = &getitemtypes();

Returns information about existing itemtypes.

build a HTML select with the following code :

=head3 in PERL SCRIPT

my $itemtypes = getitemtypes;
my @itemtypesloop;
foreach my $thisitemtype (keys %$itemtypes) {
	my $selected = 1 if $thisitemtype eq $itemtype;
	my %row =(value => $thisitemtype,
				selected => $selected,
				description => $itemtypes->{$thisitemtype}->{'description'},
			);
	push @itemtypesloop, \%row;
}
$template->param(itemtypeloop => \@itemtypesloop);

=head3 in TEMPLATE

<form action='<!-- TMPL_VAR name="script_name" -->' method=post>
	<select name="itemtype">
		<option value="">Default</option>
	<!-- TMPL_LOOP name="itemtypeloop" -->
		<option value="<!-- TMPL_VAR name="value" -->" <!-- TMPL_IF name="selected" -->selected<!-- /TMPL_IF -->><!-- TMPL_VAR name="description" --></option>
	<!-- /TMPL_LOOP -->
	</select>
	<input type=text name=searchfield value="<!-- TMPL_VAR name="searchfield" -->">
	<input type="submit" value="OK" class="button">
</form>


=cut

sub getitemtypes {
# returns a reference to a hash of references to branches...
	my %itemtypes;
	my $dbh = C4::Context->dbh;
	my $sth=$dbh->prepare("select * from itemtypes");
	$sth->execute;
	while (my $IT=$sth->fetchrow_hashref) {
			$itemtypes{$IT->{'itemtype'}}=$IT;
	}
	return (\%itemtypes);
}


=head2 itemtypes

  $itemtype = &getitemtype($itemtype);

Returns information about an itemtype.

=cut

sub getitemtypeinfo {
	my ($itemtype) = @_;
	my $dbh = C4::Context->dbh;
	my $sth=$dbh->prepare("select * from itemtypes where itemtype=?");
	$sth->execute($itemtype);
	my $res = $sth->fetchrow_hashref;
	return $res;
}

=head2 getprinters

  $printers = &getprinters($env);
  @queues = keys %$printers;

Returns information about existing printer queues.

C<$env> is ignored.

C<$printers> is a reference-to-hash whose keys are the print queues
defined in the printers table of the Koha database. The values are
references-to-hash, whose keys are the fields in the printers table.

=cut

sub getprinters {
    my ($env) = @_;
    my %printers;
    my $dbh = C4::Context->dbh;
    my $sth=$dbh->prepare("select * from printers");
    $sth->execute;
    while (my $printer=$sth->fetchrow_hashref) {
	$printers{$printer->{'printqueue'}}=$printer;
    }
    return (\%printers);
}
sub getbranch ($$) {
    my($query, $branches) = @_; # get branch for this query from branches
    my $branch = $query->param('branch');
    ($branch) || ($branch = $query->cookie('branch'));
    ($branches->{$branch}) || ($branch=(keys %$branches)[0]);
    return $branch;
}

sub getprinter ($$) {
    my($query, $printers) = @_; # get printer for this query from printers
    my $printer = $query->param('printer');
    ($printer) || ($printer = $query->cookie('printer'));
    ($printers->{$printer}) || ($printer = (keys %$printers)[0]);
    return $printer;
}


1;
__END__

=back

=head1 AUTHOR

Koha Team

=cut
