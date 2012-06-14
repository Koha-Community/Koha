package C4::Maintainance; #assumes C4/Maintainance

#package to deal with marking up output


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
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use strict;
#use warnings; FIXME - Bug 2505
use C4::Context;

require Exporter;

use vars qw($VERSION @ISA @EXPORT);

# set the version for version checking
$VERSION = 3.08.01.002;

=head1 NAME

C4::Maintenance - Koha catalog maintenance functions

=head1 SYNOPSIS

  use C4::Maintenance;

=head1 DESCRIPTION

The functions in this module perform various catalog-maintenance
functions, including deleting and undeleting books, fixing
miscategorized items, etc.

=head1 FUNCTIONS

=cut

@ISA = qw(Exporter);
@EXPORT = qw(&listsubjects &shiftgroup &deletedbib &undeletebib
&updatetype &logaction);

=head2 listsubjects

  ($count, $results) = &listsubjects($subject, $n, $offset);

Finds the subjects that begin with C<$subject> in the bibliosubject
table of the Koha database.

C<&listsubjects> returns a two-element array. C<$results> is a
reference-to-array, in which each element is a reference-to-hash
giving information about the given subject. C<$count> is the number of
elements in C<@{$results}>.

Probably the only interesting field in C<$results->[$i]> is
C<subject>, the subject in question.

C<&listsubject> returns up to C<$n> items, starting at C<$offset>. If
C<$n> is 0, it will return all matching subjects.

=cut

#'
# FIXME - This API is bogus. The way it's currently used, it should
# just return a list of strings.
sub listsubjects {
  my ($sub,$num,$offset)=@_;
  my $dbh = C4::Context->dbh;
  my $query="Select * from bibliosubject where subject like ? group by subject";
  my @bind = ("$sub%");
  # FIXME - Make $num and $offset optional.
  # If $num was given, make sure $offset was, too.
  if ($num != 0){
    $query.=" limit ?,?";
    push(@bind,$offset,$num);
  }
  my $sth=$dbh->prepare($query);
#  print $query;
  $sth->execute(@bind);
  my @results;
  my $i=0;
  while (my $data=$sth->fetchrow_hashref){
    $results[$i]=$data;
    $i++;
  }
  $sth->finish;
  return($i,\@results);
}

=head2 shiftgroup

  &shiftgroup($biblionumber, $biblioitemnumber);

Changes the biblionumber associated with a given biblioitem.
C<$biblioitemnumber> is the number of the biblioitem to change.
C<$biblionumber> is the biblionumber to associate it with.

=cut

#'
sub shiftgroup{
  my ($biblionumber,$bi)=@_;
  my $dbh = C4::Context->dbh;
  my $sth=$dbh->prepare("update biblioitems set biblionumber=? where biblioitemnumber=?");
  $sth->execute($biblionumber,$bi);
  $sth->finish;
  $sth=$dbh->prepare("update items set biblionumber=? where biblioitemnumber=?");
  $sth->execute($biblionumber,$bi);
  $sth->finish;
}

=head2 deletedbib

  ($count, $results) = &deletedbib($title);

Looks up deleted books whose title begins with C<$title>.

C<&deletedbib> returns a two-element list. C<$results> is a
reference-to-array; each element is a reference-to-hash whose keys are
the fields of the deletedbiblio table in the Koha database. C<$count>
is the number of elements in C<$results>.

=cut

#'
sub deletedbib{
  my ($title)=@_;
  my $dbh = C4::Context->dbh;
  my $sth=$dbh->prepare("Select * from deletedbiblio where title like ? order by title");
  $sth->execute("$title%");
  my @results;
  my $i=0;
  while (my $data=$sth->fetchrow_hashref){
    $results[$i]=$data;
    $i++;
  }
  $sth->finish;
  return($i,\@results);
}

=head2 undeletebib

  &undeletebib($biblionumber);

Undeletes a book. C<&undeletebib> looks up the book with the given
biblionumber in the deletedbiblio table of the Koha database, and
moves its entry to the biblio table.

=cut

#'
sub undeletebib{
  my ($biblionumber)=@_;
  my $dbh = C4::Context->dbh;
  my $sth=$dbh->prepare("select * from deletedbiblio where biblionumber=?");
  $sth->execute($biblionumber);
  if (my @data=$sth->fetchrow_array){
    $sth->finish;
    # FIXME - Doesn't this keep the same biblionumber? Isn't this
    # forbidden by the definition of 'biblio'? Or doesn't it matter?
    my $query="INSERT INTO biblio VALUES (";
   my $count = @data;
    $query .= ("?," x $count);
    $query=~ s/\,$/\)/;
    #   print $query;
    $sth=$dbh->prepare($query);
    $sth->execute(@data);
    $sth->finish;
  }
  $sth=$dbh->prepare("DELETE FROM deletedbiblio WHERE biblionumber=?");
  $sth->execute($biblionumber);
  $sth->finish;
}

=head2 updatetype

  &updatetype($biblioitemnumber, $itemtype);

Changes the type of the item with the given biblioitemnumber to be
C<$itemtype>.

=cut

#'
sub updatetype{
  my ($bi,$type)=@_;
  my $dbh = C4::Context->dbh;
  my $sth=$dbh->prepare("Update biblioitems set itemtype=? where biblioitemnumber=?");
  $sth->execute($type,$bi);
  $sth->finish;
}

END { }       # module clean-up code here (global destructor)

1;
__END__

=head1 AUTHOR

Koha Development Team <http://koha-community.org/>

=cut
