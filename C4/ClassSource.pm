package C4::ClassSource;

# Copyright (C) 2007 LibLime
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

require Exporter;
use C4::Context;
use C4::ClassSortRoutine;

use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);


=head1 NAME

C4::ClassSources - handle classification sources in Koha

=head1 SYNOPSIS

use C4::ClassSource;

=head1 DESCRIPTION

This module deals with manipulating classification
sources and sorting rules.

=head1 FUNCTIONS

=cut


@ISA    = qw(Exporter);
@EXPORT = qw(
    &GetClassSources
    &GetClassSource
    &GetClassSortRule

    &GetClassSort

);

=head2 GetClassSources

  my $sources = GetClassSources();

  Returns reference to hash of references to
  the class sources, keyed on cn_source.

=head3 Example

my $sources = GetClassSources();
my @sources = ();
foreach my $cn_source (sort keys %$sources) {
    my $source = $sources->{$cn_source};
    push @sources, 
      {  
        code        => $source->{'cn_source'},
        description => $source->{'description'},
        used => $source->{'used'},
        sortrule    => $source->{'class_sort_rule'}
      } 
}

=cut

sub GetClassSources {

    my %class_sources = ();
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("SELECT * FROM `class_sources`");
    $sth->execute();
    while (my $source = $sth->fetchrow_hashref) {
        $class_sources{ $source->{'cn_source'} } = $source;
    }

    return \%class_sources;

}

=head2 GetClassSource

  my $hashref = GetClassSource($cn_source);

  Retrieves a class_sources row by cn_source.

=cut

sub GetClassSource {

    my ($cn_source) = (@_);
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("SELECT * FROM `class_sources` WHERE cn_source = ?");
    $sth->execute($cn_source);
    my $row = $sth->fetchrow_hashref();
    return $row;
}

=head2 GetClassSortRule

  my $hashref = GetClassSortRule($class_sort_rule);

  Retrieves a class_sort_rules row by class_sort_rule.

=cut

sub GetClassSortRule {

    my ($class_sort_rule) = (@_);
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("SELECT * FROM `class_sort_rules` WHERE `class_sort_rule` = ?");
    $sth->execute($class_sort_rule);
    my $row = $sth->fetchrow_hashref();
    return $row;
}

=head2 GetClassSort

  my $cn_sort = GetClassSort($cn_source, $cn_class, $cn_item);

Get the sort key corresponding to the classification part and item part
and the defined call number source.

=cut

sub GetClassSort {

    my ($cn_source, $cn_class, $cn_item) = @_;

    my $source_ref = GetClassSource($cn_source);
    unless (defined $source_ref) {
        $source_ref = GetClassSource(C4::Context->preference("DefaultClassificationSource"));
    }
    my $routine = "";
    if (defined $source_ref) {
        my $rule_ref = GetClassSortRule($source_ref->{'class_sort_rule'});
        if (defined $rule_ref) {
            $routine = $rule_ref->{'sort_routine'};
        }
    } 

    return GetClassSortKey($routine, $cn_class, $cn_item);

}

1;

=head1 AUTHOR

Koha Development Team <http://koha-community.org/>

=cut
