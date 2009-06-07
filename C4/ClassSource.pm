package C4::ClassSource;

# Copyright (C) 2007 LibLime
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
use warnings;

require Exporter;
use C4::Context;
use C4::Koha;
use C4::ClassSortRoutine;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

# set the version for version checking
$VERSION = 3.00;

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
    &AddClassSource
    &GetClassSource
    &ModClassSource
    &DelClassSource
    &GetClassSortRules
    &AddClassSortRule
    &GetClassSortRule
    &ModClassSortRule
    &DelClassSortRule
  
    &GetSourcesForSortRule
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
    my $sth = $dbh->prepare_cached("SELECT * FROM `class_sources`");
    $sth->execute();
    while (my $source = $sth->fetchrow_hashref) {
        $class_sources{ $source->{'cn_source'} } = $source;
    }
    $sth->finish();

    return \%class_sources;

}

=head2 AddClassSource

  AddClassSource($cn_source, $description, $used, $class_sort_rule);

  Adds a class_sources row.

=cut

sub AddClassSource {

    my ($cn_source, $description, $used, $class_sort_rule) = @_;
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare_cached("INSERT INTO `class_sources` 
                                           (`cn_source`, `description`, `used`, `class_sort_rule`)
                                           VALUES (?, ?, ?, ?)");
    $sth->execute($cn_source, $description, $used, $class_sort_rule);
    $sth->finish();
  
}

=head2 GetClassSource

  my $hashref = GetClassSource($cn_source);

  Retrieves a class_sources row by cn_source.

=cut

sub GetClassSource {

    my ($cn_source) = (@_);
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare_cached("SELECT * FROM `class_sources` WHERE cn_source = ?");
    $sth->execute($cn_source);
    my $row = $sth->fetchrow_hashref();
    $sth->finish();
    return $row;
}

=head2 ModClassSource 

  ModClassSource($cn_source, $description, $used, $class_sort_rule);

  Updates a class_sources row.

=cut

sub ModClassSource {

    my ($cn_source, $description, $used, $class_sort_rule) = @_;
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare_cached("UPDATE `class_sources` 
                                    SET  `description` = ?,
                                         `used` = ?,
                                         `class_sort_rule` = ?
                                    WHERE `cn_source` = ?");
    $sth->execute($description, $used, $class_sort_rule, $cn_source);
    $sth->finish();

}

=head2 DelClassSource 

  DelClassSource($cn_source);

  Deletes class_sources row.

=cut

sub DelClassSource {

    my ($cn_source) = @_;
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare_cached("DELETE FROM `class_sources` WHERE `cn_source` = ?");
    $sth->execute($cn_source);
    $sth->finish();

}

=head2 GetClassSortRules

  my $sort_rules = GetClassSortRules();

  Returns reference to hash of references to
  the class sorting rules, keyed on class_sort_rule
  
=head3 Example

my $sort_rules = GetClassSortRules();
my @sort_rules = ();
foreach my $sort_rule (sort keys %$sort_rules) {
    my $sort_rule = $sort_rules->{$sort_rule};
    push @sort_rules,
      {
        rule        => $sort_rule->{'class_sort_rule'},
        description => $sort_rule->{'description'},
        sort_routine    => $sort_rule->{'sort_routine'}
      }
}

=cut

sub GetClassSortRules {

    my %class_sort_rules = ();
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare_cached("SELECT * FROM `class_sort_rules`");
    $sth->execute();
    while (my $sort_rule = $sth->fetchrow_hashref) {
        $class_sort_rules{ $sort_rule->{'class_sort_rule'} } = $sort_rule;
    }
    $sth->finish();

    return \%class_sort_rules;

}

=head2 AddClassSortRule

  AddClassSortRule($class_sort_rule, $description, $sort_routine);

  Adds a class_sort_rules row.

=cut

sub AddClassSortRule {

    my ($class_sort_rule, $description, $sort_routine) = @_;
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare_cached("INSERT INTO `class_sort_rules` 
                                           (`class_sort_rule`, `description`, `sort_routine`)
                                           VALUES (?, ?, ?)");
    $sth->execute($class_sort_rule, $description, $sort_routine);
    $sth->finish();
  
}

=head2 GetClassSortRule

  my $hashref = GetClassSortRule($class_sort_rule);

  Retrieves a class_sort_rules row by class_sort_rule.

=cut

sub GetClassSortRule {

    my ($class_sort_rule) = (@_);
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare_cached("SELECT * FROM `class_sort_rules` WHERE `class_sort_rule` = ?");
    $sth->execute($class_sort_rule);
    my $row = $sth->fetchrow_hashref();
    $sth->finish();
    return $row;
}

=head2 ModClassSortRule 

  ModClassSortRule($class_sort_rule, $description, $sort_routine);

  Updates a class_sort_rules row.

=cut

sub ModClassSortRule {

    my ($class_sort_rule, $description, $sort_routine) = @_;
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare_cached("UPDATE `class_sort_rules` 
                                    SET  `description` = ?,
                                         `sort_routine` = ?
                                    WHERE `class_sort_rule` = ?");
    $sth->execute($description, $sort_routine, $class_sort_rule);
    $sth->finish();

}

=head2 DelClassSortRule 

  DelClassSortRule($class_sort_rule);

  Deletes class_sort_rules row.

=cut

sub DelClassSortRule {

    my ($class_sort_rule) = @_;
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare_cached("DELETE FROM `class_sort_rules` WHERE `class_sort_rule` = ?");
    $sth->execute($class_sort_rule);
    $sth->finish();

}

=head2 GetSourcesForSortRule

  my @source = GetSourcesForSortRule($class_sort_rule);

  Retrieves an array class_source.cn_rule for each source
  that uses the supplied $class_sort_rule.

=cut

sub GetSourcesForSortRule {

    my ($class_sort_rule) = @_;

    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare_cached("SELECT cn_source FROM class_sources WHERE class_sort_rule = ?");
    $sth->execute($class_sort_rule);
    my @sources = ();
    while (my ($source) = $sth->fetchrow_array()) {
        push @sources, $source;
    }
    $sth->finish();
    return @sources;

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

Koha Developement team <info@koha.org>

=cut
