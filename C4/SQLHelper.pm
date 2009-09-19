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


use strict;
use warnings;
use List::MoreUtils qw(first_value any);
use C4::Context;
use C4::Dates qw(format_date_in_iso);
use C4::Debug;
use YAML;
require Exporter;
use vars qw($VERSION @ISA @EXPORT_OK %EXPORT_TAGS);

BEGIN {
	# set the version for version checking
	$VERSION = 0.5;
	require Exporter;
	@ISA    = qw(Exporter);
@EXPORT_OK=qw(
	InsertInTable
	DeleteInTable
	SearchInTable
	UpdateInTable
	GetPrimaryKeys
);
	%EXPORT_TAGS = ( all =>[qw( InsertInTable DeleteInTable SearchInTable UpdateInTable GetPrimaryKeys)]
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

  $hashref = &SearchInTable($tablename,$data, $orderby, $limit, $columns_out, $filtercolumns, $searchtype);

=back

$tablename Name of the table (string)
$data may contain 
	- string
	- data_hashref : will be considered as an AND of all the data searched
	- data_array_ref on hashrefs : Will be considered as an OR of Datahasref elements

$orderby is an arrayref of hashref with fieldnames as key and 0 or 1 as values (ASCENDING or DESCENDING order)
$limit is an array ref on 2 values
$columns_out is an array ref on field names is used to limit results on those fields (* by default)
$filtercolums is an array ref on field names : is used to limit expansion of research for strings
$searchtype is string Can be "wide" or "exact"

=cut

sub SearchInTable{
    my ($tablename,$filters,$orderby, $limit, $columns_out, $filter_columns,$searchtype) = @_; 
#	$searchtype||="start_with";
    my $dbh      = C4::Context->dbh; 
	$columns_out||=["*"];
    my $sql      = do { local $"=', '; 
                qq{ SELECT @$columns_out from $tablename} 
               };
    my $row; 
    my $sth; 
    my ($keys,$values)=_filter_fields($tablename,$filters,$searchtype,$filter_columns); 
	if ($keys){
		my @criteria=grep{defined($_) && $_ !~/^\W$/ }@$keys;
		if (@criteria) { 
			$sql.= do { local $"=') AND ('; 
					qq{ WHERE (@criteria) } 
				   }; 
		} 
	}
    if ($orderby){ 
		#Order by desc by default
        my @orders=map{ "$_".($$orderby{$_}? " DESC" : "") } keys %$orderby; 
        $sql.= do { local $"=', '; 
                qq{ ORDER BY @orders} 
               }; 
    } 
	if ($limit){
		$sql.=qq{ LIMIT }.join(",",@$limit);
	}
     
    $debug && $values && warn $sql," ",join(",",@$values); 
    $sth = $dbh->prepare_cached($sql); 
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
    my ($keys,$values)=_filter_hash($tablename,$data,0);
    my $query = qq{ INSERT INTO $tablename SET  }.join(", ",@$keys);

	$debug && warn $query, join(",",@$values);
    my $sth = $dbh->prepare_cached($query);
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
	my @field_ids=GetPrimaryKeys($tablename);
    my @ids=@$data{@field_ids};
    my $dbh      = C4::Context->dbh;
    my ($keys,$values)=_filter_hash($tablename,$data,0);
    my $query = 
    qq{     UPDATE $tablename
            SET  }.join(",",@$keys).qq{
            WHERE }.join (" AND ",map{ "$_=?" }@field_ids);
	$debug && warn $query, join(",",@$values,@ids);

    my $sth = $dbh->prepare_cached($query);
    return $sth->execute( @$values,@ids);

}

=head2 DeleteInTable

=over 4

  $status = &DeleteInTable($tablename,$data_hashref);

=back

  Delete Data in table
  and returns the status of the operation
=cut

sub DeleteInTable{
    my ($tablename,$data) = @_;
    my $dbh      = C4::Context->dbh;
    my ($keys,$values)=_filter_fields($tablename,$data,1);
	if ($keys){
		my $query = do { local $"=') AND (';
		qq{ DELETE FROM $tablename WHERE (@$keys)};
		};
		$debug && warn $query, join(",",@$values);
		my $sth = $dbh->prepare_cached($query);
    	return $sth->execute( @$values);
	}
}

=head2 GetPrimaryKeys

=over 4

  @primarykeys = &GetPrimaryKeys($tablename)

=back

	Get the Primary Key field names of the table
=cut

sub GetPrimaryKeys($) {
	my $tablename=shift;
	my $hash_columns=_get_columns($tablename);
	return  grep { $$hash_columns{$_}{'Key'} =~/PRI/i}  keys %$hash_columns;
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

sub _get_columns($) {
	my ($tablename)=@_;
	my $dbh=C4::Context->dbh;
	my $sth=$dbh->prepare_cached(qq{SHOW COLUMNS FROM $tablename });
	$sth->execute;
    my $columns= $sth->fetchall_hashref(qw(Field));
}

=head2 _filter_columns

=over 4

_filter_columns($tablename,$research, $filtercolumns)

=back

Given 
	- a tablename 
	- indicator on purpose whether all fields should be returned or only non Primary keys
	- array_ref to columns to limit to

Returns an array of all the fieldnames of the table
If it is not for research purpose, filter primary keys

=cut

sub _filter_columns ($$;$) {
	my ($tablename,$research, $filtercolumns)=@_;
	if ($filtercolumns){
		return (@$filtercolumns);
	}
	else {
		my $columns=_get_columns($tablename);
		if ($research){
			return keys %$columns;
		}
		else {
			return grep {my $column=$_; any {$_ ne $column }GetPrimaryKeys($tablename) } keys %$columns;
		}
	}
}
=head2 _filter_fields

=over 4

_filter_fields

=back

Given 
	- a tablename
	- a string or a hashref (containing, fieldnames and datatofilter) or an arrayref to one of those elements
	- an indicator of operation whether it is a wide research or a narrow one
	- an array ref to columns to restrict string filter to.

Returns a ref of key array to use in SQL functions
and a ref to value array

=cut

sub _filter_fields{
	my ($tablename,$filter_input,$searchtype,$filtercolumns)=@_;
    my @keys; 
	my @values;
	if (ref($filter_input) eq "HASH"){
		my ($keys, $values) = _filter_hash($tablename,$filter_input, $searchtype);
		if ($keys){
		my $stringkey="(".join (") AND (",@$keys).")";
		return [$stringkey],$values;
		}
		else {
		return ();
		}
	} elsif (ref($filter_input) eq "ARRAY"){
		foreach my $element_data (@$filter_input){
			my ($localkeys,$localvalues)=_filter_fields($tablename,$element_data,$searchtype,$filtercolumns);
			if ($localkeys){
				@$localkeys=grep{defined($_) && $_ !~/^\W*$/}@$localkeys;
				my $string=do{ 
								local $"=") OR (";
								qq{(@$localkeys)}
							};
				push @keys, $string;
				push @values, @$localvalues;
			}
		}
	} 
	else{
		return _filter_string($tablename,$filter_input,$searchtype,$filtercolumns);
	}

	return (\@keys,\@values);
}

sub _filter_hash{
	my ($tablename,$filter_input, $searchtype)=@_;
	my (@values, @keys);
	my $columns= _get_columns($tablename);
	my @columns_filtered= _filter_columns($tablename,$searchtype);
	
	#Filter Primary Keys of table
    my $elements=join "|",@columns_filtered;
	foreach my $field (grep {/\b($elements)\b/} keys %$filter_input){
		## supposed to be a hash of simple values, hashes of arrays could be implemented
		$$filter_input{$field}=format_date_in_iso($$filter_input{$field}) if ($$columns{$field}{Type}=~/date/ && $$filter_input{$field} !~C4::Dates->regexp("iso"));
		my ($tmpkeys, $localvalues)=_Process_Operands($$filter_input{$field},$field,$searchtype,$columns);
		if (@$tmpkeys){
			push @values, @$localvalues;
			push @keys, @$tmpkeys;
		}
	}
	if (@keys){
		return (\@keys,\@values);
	}
	else {
		return ();
	}
}

sub _filter_string{
	my ($tablename,$filter_input, $searchtype,$filtercolumns)=@_;
	return () unless($filter_input);
	my @operands=split / /,$filter_input;
	my @columns_filtered= _filter_columns($tablename,$searchtype,$filtercolumns);
	my $columns= _get_columns($tablename);
	my (@values,@keys);
	my @localkeys;
	foreach my $operand (@operands){
		foreach my $field (@columns_filtered){
			my ($tmpkeys, $localvalues)=_Process_Operands($operand,$field,$searchtype,$columns);
			if ($tmpkeys){
				push @values,@$localvalues;
				push @localkeys,@$tmpkeys;
			}
		}
	}
	my $sql= join (' OR ', @localkeys);
	push @keys, $sql;

	if (@keys){
		return (\@keys,\@values);
	}
	else {
		return ();
	}
}
sub _Process_Operands{
	my ($operand, $field, $searchtype,$columns)=@_;
	my @values;
	my @tmpkeys;
	my @localkeys;
	push @tmpkeys, " $field = ? ";
	push @values, $operand;
	unless ($searchtype){
		return \@tmpkeys,\@values;
	}
	if ($searchtype eq "start_with"){
			if ($field=~/(?<!zip)code|(?<!card)number/ ){
				push @tmpkeys,(" $field= '' ","$field IS NULL");
			} elsif ($$columns{$field}{Type}=~/varchar|text/){
				push @tmpkeys,(" $field LIKE ? ","$field LIKE ?");
				my @localvaluesextended=("\% $operand\%","$operand\%") ;
				push @values,@localvaluesextended;
			}
	}
	push @localkeys,qq{ (}.join(" OR ",@tmpkeys).qq{) };
	return (\@localkeys,\@values);
}
1;

