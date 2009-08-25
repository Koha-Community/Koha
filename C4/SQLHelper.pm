package C4::SQLHelper;

# Copyright 2009 Biblibre SARL
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


use List::MoreUtils qw(first_value);
use C4::Context;
use C4::Dates qw(format_date_in_iso);
use C4::Debug;
use strict;
use warnings;
require Exporter;
use vars qw($VERSION @ISA @EXPORT_OK %EXPORT_TAGS);

BEGIN {
	# set the version for version checking
	$VERSION = 0.5;
	require Exporter;
	@ISA    = qw(Exporter);
@EXPORT_OK=qw(
	InsertInTable
	SearchInTable
	UpdateInTable
	GetPrimaryKey
);
	%EXPORT_TAGS = ( all =>[qw( InsertInTable SearchInTable UpdateInTable GetPrimaryKey)]
				);
}

my $tablename;
my $hash;

=head1 NAME

C4::SQLHelper - Perl Module containing convenience functions for SQL Handling

=head1 SYNOPSIS

use C4::SQLHelper;

=head1 DESCRIPTION

This module contains routines for adding, modifying and Searching Data in MysqlDB 

=head1 FUNCTIONS

=over 2

=back


=head2 SearchInTable

=over 4

  $hashref = &SearchInTable($tablename,$data, $orderby);

=back

$data may contain 
	- string
	- data_hashref : will be considered as an AND of all the data searched
	- data_array_ref on hashrefs : Will be considered as an OR of Datahasref elements

$orderby is a hashref with fieldnames as key and 0 or 1 as values (ASCENDING or DESCENDING order)

=cut

sub SearchInTable{
    my ($tablename,$filters,$orderby) = @_; 
    my $dbh      = C4::Context->dbh; 
    my $sql      = "SELECT * from $tablename"; 
    my $row; 
    my $sth; 
    my ($keys,$values)=_filter_fields($filters,$tablename, "search"); 
    if ($filters) { 
        $sql.= do { local $"=' AND '; 
                qq{ WHERE @$keys } 
               }; 
    } 
    if ($orderby){ 
        my @orders=map{ "$_".($$orderby{$_}? " DESC" : "") } keys %$orderby; 
        $sql.= do { local $"=', '; 
                qq{ ORDER BY @orders} 
               }; 
    } 
     
    $debug && warn $sql," ",join(",",@$values); 
    $sth = $dbh->prepare($sql); 
    $sth->execute(@$values); 
    my $results = $sth->fetchall_arrayref( {} ); 
    return $results;
}

=head2 InsertInTable

=over 4

  $data_id_in_table = &InsertInTable($tablename,$data_hashref);

=back

  Insert Data in table
  and returns the id of the row inserted
=cut

sub InsertInTable{
    my ($tablename,$data) = @_;
    my $dbh      = C4::Context->dbh;
    my ($keys,$values)=_filter_fields($data,$tablename);

    my $query = do { local $"=',';
    qq{
            INSERT $tablename
            SET  @$keys
        };
    };

	$debug && warn $query, join(",",@$values);
    my $sth = $dbh->prepare($query);
    $sth->execute( @$values);

	return $dbh->last_insert_id(undef, undef, $tablename, undef);
}

=head2 UpdateInTable

=over 4

  $status = &UpdateInTable($tablename,$data_hashref);

=back

  Update Data in table
  and returns the status of the operation
=cut

sub UpdateInTable{
    my ($tablename,$data) = @_;
	my $field_id=GetPrimaryKey($tablename);
    my $id=$$data{$field_id};
    my $dbh      = C4::Context->dbh;
    my ($keys,$values)=_filter_fields($data,$tablename);

    my $query = do { local $"=',';
    qq{
            UPDATE $tablename
            SET  @$keys
            WHERE  $field_id=?
        };
    };
	$debug && warn $query, join(",",@$values,$id);

    my $sth = $dbh->prepare($query);
    return $sth->execute( @$values,$id);

}

=head2 GetPrimaryKey

=over 4

  $primarykeyname = &GetPrimaryKey($tablename)

=back

	Get the Primary Key field name of the table
=cut

sub GetPrimaryKey($) {
	my $tablename=shift;
	my $hash_columns=_columns($tablename);
	return  first_value { $$hash_columns{$_}{'Key'} =~/PRI/}  keys %$hash_columns;
}

=head2 _get_columns

=over 4

_get_columns($tablename)

=back

Given a tablename 
Returns a hashref of all the fieldnames of the table
With 
	Key
	Type
	Default

=cut

sub _columns($) {
	my $tablename=shift;
	$debug && warn $tablename;
	my $dbh=C4::Context->dbh;
	my $sth=$dbh->prepare(qq{SHOW COLUMNS FROM $tablename });
	$sth->execute;
    return $sth->fetchall_hashref(qw(Field));
}

=head2 _filter_fields

=over 4

_filter_fields

=back

Given 
	- a tablename
	- a hashref of data 
	- an indicator on operation

Returns a ref of key array to use in SQL functions
and a ref to value array

=cut

sub _filter_fields{
	my ($data_to_filter,$tablename,$research)=@_;
	warn "$tablename";
    my @keys; 
	my @values;
	my $columns= _columns($tablename);
	#Filter Primary Keys of table
    my $elements=join "|",grep {$$columns{$_}{'Key'} ne "PRI"} keys %$columns;
	if (ref($data_to_filter) eq "HASH"){
		foreach my $field (grep {/\b($elements)\b/} keys %$data_to_filter){
			## supposed to be a hash of simple values, hashes of arrays could be implemented
			$$data_to_filter{$field}=format_date_in_iso($$data_to_filter{$field}) if ($$columns{$field}{Type}=~/date/ && $$data_to_filter{$field} !~C4::Dates->regexp("iso"));
			my $strkeys= " $field = ? ";
			if ($field=~/code/ && $research){
				$strkeys="( $strkeys OR $field='' OR $field IS NULL) ";
			}
			push @values, $$data_to_filter{$field};
			push @keys, $strkeys;
		}
	} elsif (ref($data_to_filter) eq "ARRAY"){
		foreach my $element (@$data_to_filter){
			my (@localkeys,@localvalues)=_filter_fields($element);
			push @keys, join(' AND ',@localkeys);
			push @values, @localvalues;
		}
	} 
	else{
			my @operands=split / /,$data_to_filter;
			foreach my $operand (@operands){
				my @localvalues=($operand,"\%$operand\%") ;
				foreach my $field (keys %$columns){
					my $strkeys= " ( $field = ? OR $field LIKE ? )";
					if ($field=~/code/){
						$strkeys="( $strkeys OR $field='' OR $field IS NULL) ";
					}
					push @values, @localvalues;
					push @keys, $strkeys;
				}
			}
	}

	return (\@keys,\@values);
}

1;

