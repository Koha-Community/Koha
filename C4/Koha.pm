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

# $Id$

use strict;
require Exporter;
use C4::Context;
use C4::Biblio;
use vars qw($VERSION @ISA @EXPORT);

$VERSION = do { my @v = '$Revision$' =~ /\d+/g; shift(@v) . "." . join("_", map {sprintf "%03d", $_ } @v); };

=head1 NAME

C4::Koha - Perl Module containing convenience functions for Koha scripts

=head1 SYNOPSIS

  use C4::Koha;


=head1 DESCRIPTION

Koha.pm provides many functions for Koha scripts.

=head1 FUNCTIONS

=over 2

=cut

@ISA = qw(Exporter);
@EXPORT = qw(
            &subfield_is_koha_internal_p
            &GetBranches &getbranch &getbranchdetail
            &getprinters &getprinter
            &GetItemTypes &getitemtypeinfo &ItemType
                        get_itemtypeinfos_of
            &getframeworks &getframeworkinfo
            &getauthtypes &getauthtype
            &getallthemes &getalllanguages
            &getallbranches &getletters
            &getbranchname
                        getnbpages
                        getitemtypeimagedir
                        getitemtypeimagesrc
                        getitemtypeimagesrcfromurl
            &getcities
            &getroadtypes
                        get_branchinfos_of
                        get_notforloan_label_of
                        get_infos_of
            $DEBUG);

use vars qw();

my $DEBUG = 0;

# FIXME.. this should be moved to a MARC-specific module
sub subfield_is_koha_internal_p ($) {
    my($subfield) = @_;

    # We could match on 'lib' and 'tab' (and 'mandatory', & more to come!)
    # But real MARC subfields are always single-character
    # so it really is safer just to check the length

    return length $subfield != 1;
}

=head2 GetBranches

  $branches = &GetBranches();
  returns informations about branches.
  Create a branch selector with the following code
  Is branchIndependant sensitive
   When IndependantBranches is set AND user is not superlibrarian, displays only user's branch
  
=head3 in PERL SCRIPT

my $branches = GetBranches;
my @branchloop;
foreach my $thisbranch (sort keys %$branches) {
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

sub GetBranches {
# returns a reference to a hash of references to branches...
    my ($type) = @_;
    my %branches;
    my $branch;
    my $dbh = C4::Context->dbh;
    my $sth;
    if (C4::Context->preference("IndependantBranches") && (C4::Context->userenv->{flags}!=1)){
        my $strsth ="Select * from branches ";
        $strsth.= " WHERE branchcode = ".$dbh->quote(C4::Context->userenv->{branch});
        $strsth.= " order by branchname";
        $sth=$dbh->prepare($strsth);
    } else {
        $sth = $dbh->prepare("Select * from branches order by branchname");
    }
    $sth->execute;
    while ($branch=$sth->fetchrow_hashref) {
        my $nsth = $dbh->prepare("select categorycode from branchrelations where branchcode = ?");
            if ($type){
            $nsth = $dbh->prepare("select categorycode from branchrelations where branchcode = ? and categorycode = ?");
            $nsth->execute($branch->{'branchcode'},$type);
      	  } else {
	            $nsth = $dbh->prepare("select categorycode from branchrelations where branchcode = ? ");
 
            $nsth->execute($branch->{'branchcode'});
      	  }
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

sub getbranchname {
    my ($branchcode)=@_;
    my $dbh = C4::Context->dbh;
    my $sth;
       $sth = $dbh->prepare("Select branchname from branches where branchcode=?");
    $sth->execute($branchcode);
    my $branchname = $sth->fetchrow_array;
    $sth->finish;
    
    return($branchname);
}

=head2 getallbranches

  $branches = &getallbranches();
  returns informations about ALL branches.
  Create a branch selector with the following code
  IndependantBranches Insensitive...
  
=head3 in PERL SCRIPT

my $branches = getallbranches;
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


sub getallbranches {
# returns a reference to a hash of references to ALL branches...
    my %branches;
    my $dbh = C4::Context->dbh;
    my $sth;
       $sth = $dbh->prepare("Select * from branches order by branchname");
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

=head2 getletters

  $letters = &getletters($category);
  returns informations about letters.
  if needed, $category filters for letters given category
  Create a letter selector with the following code
  
=head3 in PERL SCRIPT

my $letters = getletters($cat);
my @letterloop;
foreach my $thisletter (keys %$letters) {
    my $selected = 1 if $thisletter eq $letter;
    my %row =(value => $thisletter,
                selected => $selected,
                lettername => $letters->{$thisletter},
            );
    push @letterloop, \%row;
}


=head3 in TEMPLATE  
            <select name="letter">
                <option value="">Default</option>
            <!-- TMPL_LOOP name="letterloop" -->
                <option value="<!-- TMPL_VAR name="value" -->" <!-- TMPL_IF name="selected" -->selected<!-- /TMPL_IF -->><!-- TMPL_VAR name="lettername" --></option>
            <!-- /TMPL_LOOP -->
            </select>

=cut

sub getletters {
# returns a reference to a hash of references to ALL letters...
    my $cat =@_;
    my %letters;
    my $dbh = C4::Context->dbh;
    my $sth;
       if ($cat ne ""){
        $sth = $dbh->prepare("Select * from letter where module = \'".$cat."\' order by name");
    } else {
        $sth = $dbh->prepare("Select * from letter order by name");
    }
    $sth->execute;
    my $count;
    while (my $letter=$sth->fetchrow_hashref) {
            $letters{$letter->{'code'}}=$letter->{'name'};
            $count++;
    }
    return ($count,\%letters);
}

=head2 GetItemTypes

  $itemtypes = &GetItemTypes();

Returns information about existing itemtypes.

build a HTML select with the following code :

=head3 in PERL SCRIPT

my $itemtypes = GetItemTypes;
my @itemtypesloop;
foreach my $thisitemtype (sort keys %$itemtypes) {
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

sub GetItemTypes {
# returns a reference to a hash of references to branches...
    my %itemtypes;
    my $dbh = C4::Context->dbh;
    my $query = qq|
        SELECT *
        FROM   itemtypes
    |;
    my $sth=$dbh->prepare($query);
    $sth->execute;
    while (my $IT=$sth->fetchrow_hashref) {
            $itemtypes{$IT->{'itemtype'}}=$IT;
    }
    return (\%itemtypes);
}

# FIXME this function is better and should replace GetItemTypes everywhere
sub get_itemtypeinfos_of {
    my @itemtypes = @_;

    my $query = '
SELECT itemtype,
       description,
       notforloan
  FROM itemtypes
  WHERE itemtype IN ('.join(',', map({"'".$_."'"} @itemtypes)).')
';

    return get_infos_of($query, 'itemtype');
}

sub ItemType {
  my ($type)=@_;
  my $dbh = C4::Context->dbh;
  my $sth=$dbh->prepare("select description from itemtypes where itemtype=?");
  $sth->execute($type);
  my $dat=$sth->fetchrow_hashref;
  $sth->finish;
  return ($dat->{'description'});
}
=head2 getauthtypes

  $authtypes = &getauthtypes();

Returns information about existing authtypes.

build a HTML select with the following code :

=head3 in PERL SCRIPT

my $authtypes = getauthtypes;
my @authtypesloop;
foreach my $thisauthtype (keys %$authtypes) {
    my $selected = 1 if $thisauthtype eq $authtype;
    my %row =(value => $thisauthtype,
                selected => $selected,
                authtypetext => $authtypes->{$thisauthtype}->{'authtypetext'},
            );
    push @authtypesloop, \%row;
}
$template->param(itemtypeloop => \@itemtypesloop);

=head3 in TEMPLATE

<form action='<!-- TMPL_VAR name="script_name" -->' method=post>
    <select name="authtype">
    <!-- TMPL_LOOP name="authtypeloop" -->
        <option value="<!-- TMPL_VAR name="value" -->" <!-- TMPL_IF name="selected" -->selected<!-- /TMPL_IF -->><!-- TMPL_VAR name="authtypetext" --></option>
    <!-- /TMPL_LOOP -->
    </select>
    <input type=text name=searchfield value="<!-- TMPL_VAR name="searchfield" -->">
    <input type="submit" value="OK" class="button">
</form>


=cut

sub getauthtypes {
# returns a reference to a hash of references to authtypes...
    my %authtypes;
    my $dbh = C4::Context->dbh;
    my $sth=$dbh->prepare("select * from auth_types order by authtypetext");
    $sth->execute;
    while (my $IT=$sth->fetchrow_hashref) {
            $authtypes{$IT->{'authtypecode'}}=$IT;
    }
    return (\%authtypes);
}

sub getauthtype {
    my ($authtypecode) = @_;
# returns a reference to a hash of references to authtypes...
    my %authtypes;
    my $dbh = C4::Context->dbh;
    my $sth=$dbh->prepare("select * from auth_types where authtypecode=?");
    $sth->execute($authtypecode);
    my $res=$sth->fetchrow_hashref;
    return $res;
}

=head2 getframework

  $frameworks = &getframework();

Returns information about existing frameworks

build a HTML select with the following code :

=head3 in PERL SCRIPT

my $frameworks = frameworks();
my @frameworkloop;
foreach my $thisframework (keys %$frameworks) {
    my $selected = 1 if $thisframework eq $frameworkcode;
    my %row =(value => $thisframework,
                selected => $selected,
                description => $frameworks->{$thisframework}->{'frameworktext'},
            );
    push @frameworksloop, \%row;
}
$template->param(frameworkloop => \@frameworksloop);

=head3 in TEMPLATE

<form action='<!-- TMPL_VAR name="script_name" -->' method=post>
    <select name="frameworkcode">
        <option value="">Default</option>
    <!-- TMPL_LOOP name="frameworkloop" -->
        <option value="<!-- TMPL_VAR name="value" -->" <!-- TMPL_IF name="selected" -->selected<!-- /TMPL_IF -->><!-- TMPL_VAR name="frameworktext" --></option>
    <!-- /TMPL_LOOP -->
    </select>
    <input type=text name=searchfield value="<!-- TMPL_VAR name="searchfield" -->">
    <input type="submit" value="OK" class="button">
</form>


=cut

sub getframeworks {
# returns a reference to a hash of references to branches...
    my %itemtypes;
    my $dbh = C4::Context->dbh;
    my $sth=$dbh->prepare("select * from biblios_framework");
    $sth->execute;
    while (my $IT=$sth->fetchrow_hashref) {
            $itemtypes{$IT->{'frameworkcode'}}=$IT;
    }
    return (\%itemtypes);
}
=head2 getframeworkinfo

  $frameworkinfo = &getframeworkinfo($frameworkcode);

Returns information about an frameworkcode.

=cut

sub getframeworkinfo {
    my ($frameworkcode) = @_;
    my $dbh = C4::Context->dbh;
    my $sth=$dbh->prepare("select * from biblios_framework where frameworkcode=?");
    $sth->execute($frameworkcode);
    my $res = $sth->fetchrow_hashref;
    return $res;
}


=head2 getitemtypeinfo

  $itemtype = &getitemtype($itemtype);

Returns information about an itemtype.

=cut

sub getitemtypeinfo {
    my ($itemtype) = @_;
    my $dbh = C4::Context->dbh;
    my $sth=$dbh->prepare("select * from itemtypes where itemtype=?");
    $sth->execute($itemtype);
    my $res = $sth->fetchrow_hashref;

        $res->{imageurl} = getitemtypeimagesrcfromurl($res->{imageurl});

    return $res;
}

sub getitemtypeimagesrcfromurl {
    my ($imageurl) = @_;

    if (defined $imageurl and $imageurl !~ m/^http/) {
        $imageurl =
            getitemtypeimagesrc()
            .'/'.$imageurl
            ;
    }

    return $imageurl;
}

sub getitemtypeimagedir {
    return
        C4::Context->intrahtdocs
        .'/'.C4::Context->preference('template')
        .'/itemtypeimg'
        ;
}

sub getitemtypeimagesrc {
    return
        '/intranet-tmpl'
        .'/'.C4::Context->preference('template')
        .'/itemtypeimg'
        ;
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

=item getbranchdetail

  $branchname = &getbranchdetail($branchcode);

Given the branch code, the function returns the corresponding
branch name for a comprehensive information display

=cut

sub getbranchdetail
{
    my ($branchcode) = @_;
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("SELECT * FROM branches WHERE branchcode = ?");
    $sth->execute($branchcode);
    my $branchname = $sth->fetchrow_hashref();
    $sth->finish();
    return $branchname;
} # sub getbranchname


sub getprinter ($$) {
    my($query, $printers) = @_; # get printer for this query from printers
    my $printer = $query->param('printer');
    ($printer) || ($printer = $query->cookie('printer')) || ($printer='');
    ($printers->{$printer}) || ($printer = (keys %$printers)[0]);
    return $printer;
}

=item getalllanguages

  (@languages) = &getalllanguages($type);
  (@languages) = &getalllanguages($type,$theme);

Returns an array of all available languages.

=cut

sub getalllanguages {
    my $type=shift;
    my $theme=shift;
    my $htdocs;
    my @languages;
    if ($type eq 'opac') {
        $htdocs=C4::Context->config('opachtdocs');
        if ($theme and -d "$htdocs/$theme") {
            opendir D, "$htdocs/$theme";
            foreach my $language (readdir D) {
                next if $language=~/^\./;
                next if $language eq 'all';
                next if $language=~ /png$/;
                next if $language=~ /css$/;
                next if $language=~ /CVS$/;
                next if $language=~ /itemtypeimg$/;
		next if $language=~ /\.txt$/i; #Don't read the readme.txt !
                push @languages, $language;
            }
            return sort @languages;
        } else {
            my $lang;
            foreach my $theme (getallthemes('opac')) {
                opendir D, "$htdocs/$theme";
                foreach my $language (readdir D) {
                    next if $language=~/^\./;
                    next if $language eq 'all';
                    next if $language=~ /png$/;
                    next if $language=~ /css$/;
                    next if $language=~ /CVS$/;
                    next if $language=~ /itemtypeimg$/;
		    next if $language=~ /\.txt$/i; #Don't read the readme.txt !
                    $lang->{$language}=1;
                }
            }
            @languages=keys %$lang;
            return sort @languages;
        }
    } elsif ($type eq 'intranet') {
        $htdocs=C4::Context->config('intrahtdocs');
        if ($theme and -d "$htdocs/$theme") {
            opendir D, "$htdocs/$theme";
            foreach my $language (readdir D) {
                next if $language=~/^\./;
                next if $language eq 'all';
                next if $language=~ /png$/;
                next if $language=~ /css$/;
                next if $language=~ /CVS$/;
                next if $language=~ /itemtypeimg$/;
                next if $language=~ /\.txt$/i; #Don't read the readme.txt !
                push @languages, $language;
            }
            return sort @languages;
        } else {
            my $lang;
            foreach my $theme (getallthemes('opac')) {
                opendir D, "$htdocs/$theme";
                foreach my $language (readdir D) {
                    next if $language=~/^\./;
                    next if $language eq 'all';
                    next if $language=~ /png$/;
                    next if $language=~ /css$/;
                    next if $language=~ /CVS$/;
                    next if $language=~ /itemtypeimg$/;
		    next if $language=~ /\.txt$/i; #Don't read the readme.txt !
                    $lang->{$language}=1;
                }
            }
            @languages=keys %$lang;
            return sort @languages;
        }
    } else {
        my $lang;
        my $htdocs=C4::Context->config('intrahtdocs');
        foreach my $theme (getallthemes('intranet')) {
            opendir D, "$htdocs/$theme";
            foreach my $language (readdir D) {
                next if $language=~/^\./;
                next if $language eq 'all';
                next if $language=~ /png$/;
                next if $language=~ /css$/;
                next if $language=~ /CVS$/;
                next if $language=~ /itemtypeimg$/;
		next if $language=~ /\.txt$/i; #Don't read the readme.txt !
                $lang->{$language}=1;
            }
        }
        $htdocs=C4::Context->config('opachtdocs');
        foreach my $theme (getallthemes('opac')) {
        opendir D, "$htdocs/$theme";
        foreach my $language (readdir D) {
            next if $language=~/^\./;
            next if $language eq 'all';
            next if $language=~ /png$/;
            next if $language=~ /css$/;
            next if $language=~ /CVS$/;
            next if $language=~ /itemtypeimg$/;
	    next if $language=~ /\.txt$/i; #Don't read the readme.txt !
            $lang->{$language}=1;
            }
        }
        @languages=keys %$lang;
        return sort @languages;
    }
}

=item getallthemes

  (@themes) = &getallthemes('opac');
  (@themes) = &getallthemes('intranet');

Returns an array of all available themes.

=cut

sub getallthemes {
    my $type=shift;
    my $htdocs;
    my @themes;
    if ($type eq 'intranet') {
    $htdocs=C4::Context->config('intrahtdocs');
    } else {
    $htdocs=C4::Context->config('opachtdocs');
    }
    opendir D, "$htdocs";
    my @dirlist=readdir D;
    foreach my $directory (@dirlist) {
    -d "$htdocs/$directory/en" and push @themes, $directory;
    }
    return @themes;
}

=item getnbpages

Returns the number of pages to display in a pagination bar, given the number
of items and the number of items per page.

=cut

sub getnbpages {
    my ($nb_items, $nb_items_per_page) = @_;

    return int(($nb_items - 1) / $nb_items_per_page) + 1;
}


=head2 getcities (OUEST-PROVENCE)

  ($id_cityarrayref, $city_hashref) = &getcities();

Looks up the different city and zip in the database. Returns two
elements: a reference-to-array, which lists the zip city
codes, and a reference-to-hash, which maps the name of the city.
WHERE =>OUEST PROVENCE OR EXTERIEUR

=cut
sub getcities {
    #my ($type_city) = @_;
    my $dbh = C4::Context->dbh;
    my $sth=$dbh->prepare("Select cityid,city_name from cities order by cityid  ");
    #$sth->execute($type_city);
    $sth->execute();    
    my %city;
    my @id;
#    insert empty value to create a empty choice in cgi popup 
    
while (my $data=$sth->fetchrow_hashref){
      
    push @id,$data->{'cityid'};
      $city{$data->{'cityid'}}=$data->{'city_name'};
    }
    
    #test to know if the table contain some records if no the function return nothing
    my $id=@id;
    $sth->finish;
    if ($id eq 0)
    {
    return();
    }
    else{
    unshift (@id ,"");
    return(\@id,\%city);
    }
}


=head2 getroadtypes (OUEST-PROVENCE)

  ($idroadtypearrayref, $roadttype_hashref) = &getroadtypes();

Looks up the different road type . Returns two
elements: a reference-to-array, which lists the id_roadtype
codes, and a reference-to-hash, which maps the road type of the road .


=cut
sub getroadtypes {
    my $dbh = C4::Context->dbh;
    my $sth=$dbh->prepare("Select roadtypeid,road_type from roadtype order by road_type  ");
    $sth->execute();
    my %roadtype;
    my @id;
#    insert empty value to create a empty choice in cgi popup 
while (my $data=$sth->fetchrow_hashref){
    push @id,$data->{'roadtypeid'};
      $roadtype{$data->{'roadtypeid'}}=$data->{'road_type'};
    }
    #test to know if the table contain some records if no the function return nothing
    my $id=@id;
    $sth->finish;
    if ($id eq 0)
    {
    return();
    }
    else{
        unshift (@id ,"");
        return(\@id,\%roadtype);
    }
}

=head2 get_branchinfos_of

  my $branchinfos_of = get_branchinfos_of(@branchcodes);

Associates a list of branchcodes to the information of the branch, taken in
branches table.

Returns a href where keys are branchcodes and values are href where keys are
branch information key.

  print 'branchname is ', $branchinfos_of->{$code}->{branchname};

=cut
sub get_branchinfos_of {
    my @branchcodes = @_;

    my $query = '
SELECT branchcode,
       branchname
  FROM branches
  WHERE branchcode IN ('.join(',', map({"'".$_."'"} @branchcodes)).')
';
    return get_infos_of($query, 'branchcode');
}

=head2 get_notforloan_label_of

  my $notforloan_label_of = get_notforloan_label_of();

Each authorised value of notforloan (information available in items and
itemtypes) is link to a single label.

Returns a href where keys are authorised values and values are corresponding
labels.

  foreach my $authorised_value (keys %{$notforloan_label_of}) {
    printf(
        "authorised_value: %s => %s\n",
        $authorised_value,
        $notforloan_label_of->{$authorised_value}
    );
  }

=cut
sub get_notforloan_label_of {
    my $dbh = C4::Context->dbh;
my($tagfield,$tagsubfield)=MARCfind_marc_from_kohafield("notforloan","holdings");
    my $query = '
SELECT authorised_value
  FROM holdings_subfield_structure
  WHERE tagfield =$tagfield and tagsubfield=$tagsubfield
  LIMIT 0, 1
';
    my $sth = $dbh->prepare($query);
    $sth->execute();
    my ($statuscode) = $sth->fetchrow_array();

    $query = '
SELECT lib,
       authorised_value
  FROM authorised_values
  WHERE category = ?
';
    $sth = $dbh->prepare($query);
    $sth->execute($statuscode);
    my %notforloan_label_of;
    while (my $row = $sth->fetchrow_hashref) {
        $notforloan_label_of{ $row->{authorised_value} } = $row->{lib};
    }
    $sth->finish;

    return \%notforloan_label_of;
}

=head2 get_infos_of

Return a href where a key is associated to a href. You give a query, the
name of the key among the fields returned by the query. If you also give as
third argument the name of the value, the function returns a href of scalar.

  my $query = '
SELECT itemnumber,
       notforloan,
       barcode
  FROM items
';

  # generic href of any information on the item, href of href.
  my $iteminfos_of = get_infos_of($query, 'itemnumber');
  print $iteminfos_of->{$itemnumber}{barcode};

  # specific information, href of scalar
  my $barcode_of_item = get_infos_of($query, 'itemnumber', 'barcode');
  print $barcode_of_item->{$itemnumber};

=cut
sub get_infos_of {
    my ($query, $key_name, $value_name) = @_;

    my $dbh = C4::Context->dbh;

    my $sth = $dbh->prepare($query);
    $sth->execute();

    my %infos_of;
    while (my $row = $sth->fetchrow_hashref) {
        if (defined $value_name) {
            $infos_of{ $row->{$key_name} } = $row->{$value_name};
        }
        else {
            $infos_of{ $row->{$key_name} } = $row;
        }
    }
    $sth->finish;

    return \%infos_of;
}

1;
__END__

=back

=head1 AUTHOR

Koha Team

=cut
