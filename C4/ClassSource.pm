package C4::ClassSource;

# Copyright 2022 Koha Development Team
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

use Modern::Perl;

use C4::Context;
use C4::ClassSortRoutine qw( GetClassSortKey );

use Koha::Cache::Memory::Lite;

our ( @ISA, @EXPORT_OK );

BEGIN {
    require Exporter;
    @ISA       = qw(Exporter);
    @EXPORT_OK = qw(
        GetClassSources
        GetClassSource
        GetClassSortRule
        GetClassSort
    );
}

=head1 NAME

C4::ClassSources - handle classification sources in Koha

=head1 SYNOPSIS

use C4::ClassSource;

=head1 DESCRIPTION

This module deals with manipulating classification
sources and sorting rules.

=head1 FUNCTIONS

=cut

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

    my $memory_cache  = Koha::Cache::Memory::Lite->get_instance();
    my $class_sources = $memory_cache->get_from_cache("GetClassSource:All");
    unless ($class_sources) {
        my $dbh = C4::Context->dbh;
        my $sth = $dbh->prepare("SELECT * FROM `class_sources`");
        $sth->execute();
        while ( my $source = $sth->fetchrow_hashref ) {
            $class_sources->{ $source->{'cn_source'} } = $source;
        }
        $memory_cache->set_in_cache( "GetClassSource:All", $class_sources );
    }
    return $class_sources;

}

=head2 GetClassSource

  my $hashref = GetClassSource($cn_source);

  Retrieves a class_sources row by cn_source.

=cut

sub GetClassSource {

    my ($cn_source) = (@_);
    return unless $cn_source;
    my $memory_cache = Koha::Cache::Memory::Lite->get_instance();
    my $class_source = $memory_cache->get_from_cache( "GetClassSource:" . $cn_source );
    unless ($class_source) {
        my $dbh = C4::Context->dbh;
        my $sth = $dbh->prepare("SELECT * FROM `class_sources` WHERE cn_source = ?");
        $sth->execute($cn_source);
        $class_source = $sth->fetchrow_hashref();
        $memory_cache->set_in_cache( "GetClassSource:" . $cn_source, $class_source );
    }
    return $class_source;
}

=head2 GetClassSortRule

  my $hashref = GetClassSortRule($class_sort_rule);

  Retrieves a class_sort_rules row by class_sort_rule.

=cut

sub GetClassSortRule {

    my ($class_sort_rule) = (@_);
    return unless $class_sort_rule;
    my $memory_cache     = Koha::Cache::Memory::Lite->get_instance();
    my $class_sort_rules = $memory_cache->get_from_cache( "GetClassSortRule:" . $class_sort_rule );
    unless ($class_sort_rules) {
        my $dbh = C4::Context->dbh;
        my $sth = $dbh->prepare("SELECT * FROM `class_sort_rules` WHERE `class_sort_rule` = ?");
        $sth->execute($class_sort_rule);
        $class_sort_rules = $sth->fetchrow_hashref();
        $memory_cache->set_in_cache( "GetClassSortRule:" . $class_sort_rule, $class_sort_rules );
    }
    return $class_sort_rules;
}

=head2 GetClassSort

  my $cn_sort = GetClassSort($cn_source, $cn_class, $cn_item);

Get the sort key corresponding to the classification part and item part
and the defined call number source.

=cut

sub GetClassSort {

    my ( $cn_source, $cn_class, $cn_item ) = @_;

    my $source_ref = GetClassSource($cn_source);
    unless ( defined $source_ref ) {
        $source_ref = GetClassSource( C4::Context->preference("DefaultClassificationSource") );
    }
    my $routine = "";
    if ( defined $source_ref ) {
        my $rule_ref = GetClassSortRule( $source_ref->{'class_sort_rule'} );
        if ( defined $rule_ref ) {
            $routine = $rule_ref->{'sort_routine'};
        }
    }

    return GetClassSortKey( $routine, $cn_class, $cn_item );

}

1;

=head1 AUTHOR

Koha Development Team <http://koha-community.org/>

=cut
