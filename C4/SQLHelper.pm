package C4::SQLHelper;

# Copyright 2009 Biblibre SARL
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
use List::MoreUtils qw(first_value any);
use C4::Context;
use C4::Dates qw(format_date_in_iso);
use C4::Debug;
require Exporter;
use vars qw($VERSION @ISA @EXPORT_OK %EXPORT_TAGS);

eval {
    my $servers = C4::Context->config('memcached_servers');
    if ($servers) {
        require Memoize::Memcached;
        import Memoize::Memcached qw(memoize_memcached);

        my $memcached = {
            servers     => [$servers],
            key_prefix  => C4::Context->config('memcached_namespace') || 'koha',
            expire_time => 600
        };    # cache for 10 mins

        memoize_memcached( '_get_columns',   memcached => $memcached );
        memoize_memcached( 'GetPrimaryKeys', memcached => $memcached );
    }
};

BEGIN {
	# set the version for version checking
    $VERSION = 3.07.00.049;
	require Exporter;
	@ISA    = qw(Exporter);
@EXPORT_OK=qw(
	InsertInTable
	DeleteInTable
	SearchInTable
	UpdateInTable
	GetPrimaryKeys
        clear_columns_cache
);
	%EXPORT_TAGS = ( all =>[qw( InsertInTable DeleteInTable SearchInTable UpdateInTable GetPrimaryKeys)]
				);
}

my $tablename;
my $hashref;

=head1 NAME

C4::SQLHelper - Perl Module containing convenience functions for SQL Handling

=head1 SYNOPSIS

use C4::SQLHelper;

=head1 DESCRIPTION

This module contains routines for adding, modifying and Searching Data in MysqlDB 

=head1 FUNCTIONS

=head2 SearchInTable

  $hashref = &SearchInTable($tablename,$data, $orderby, $limit, 
                      $columns_out, $filtercolumns, $searchtype);


$tablename Name of the table (string)

$data may contain 
	- string

	- data_hashref : will be considered as an AND of all the data searched

	- data_array_ref on hashrefs : Will be considered as an OR of Datahasref elements

$orderby is an arrayref of hashref with fieldnames as key and 0 or 1 as values (ASCENDING or DESCENDING order)

$limit is an array ref on 2 values in order to limit results to MIN..MAX

$columns_out is an array ref on field names is used to limit results on those fields (* by default)

$filtercolums is an array ref on field names : is used to limit expansion of research for strings

$searchtype is string Can be "start_with" or "exact" 

This query builder is very limited, it should be replaced with DBIx::Class
or similar  very soon
Meanwhile adding support for special key '' in case of a data_hashref to
support filters of type

  ( f1 = a OR f2 = a ) AND fx = b AND fy = c

Call for the query above is:

  SearchInTable($tablename, {'' => a, fx => b, fy => c}, $orderby, $limit,
                $columns_out, [f1, f2], 'exact');

NOTE: Current implementation may remove parts of the iinput hashrefs. If that is a problem
a copy needs to be created in _filter_fields() below

=cut

sub SearchInTable{
    my ($tablename,$filters,$orderby, $limit, $columns_out, $filter_columns,$searchtype) = @_; 
	$searchtype||="exact";
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
			$sql.= do { local $"=') OR ('; 
					qq{ WHERE (@criteria) } 
				   }; 
		} 
	}
    if ($orderby){ 
		#Order by desc by default
		my @orders;
		foreach my $order ( ref($orderby) ? @$orderby : $orderby ){
            if (ref $order) {
			    push @orders,map{ "$_".($order->{$_}? " DESC " : "") } keys %$order; 
            } else {
			    push @orders,$order; 
            }
		}
		$sql.= do { local $"=', '; 
				qq{ ORDER BY @orders} 
        }; 
    } 
	if ($limit){
		$sql.=qq{ LIMIT }.join(",",@$limit);
	}
     
    $debug && $values && warn $sql," ",join(",",@$values); 
    $sth = $dbh->prepare_cached($sql); 
    eval{$sth->execute(@$values)}; 
	warn $@ if ($@ && $debug);
    my $results = $sth->fetchall_arrayref( {} ); 
    return $results;
}

=head2 InsertInTable

  $data_id_in_table = &InsertInTable($tablename,$data_hashref,$withprimarykeys);

Insert Data in table and returns the id of the row inserted

=cut

sub InsertInTable{
    my ($tablename,$data,$withprimarykeys) = @_;
    my $dbh      = C4::Context->dbh;
    my ($keys,$values)=_filter_hash($tablename,$data,($withprimarykeys?"exact":0));
    my $query = qq{ INSERT INTO $tablename SET  }.join(", ",@$keys);

	$debug && warn $query, join(",",@$values);
    my $sth = $dbh->prepare_cached($query);
    eval{$sth->execute(@$values)}; 
	warn $@ if ($@ && $debug);

	return $dbh->last_insert_id(undef, undef, $tablename, undef);
}

=head2 UpdateInTable

  $status = &UpdateInTable($tablename,$data_hashref);

Update Data in table and returns the status of the operation

=cut

sub UpdateInTable{
    my ($tablename,$data) = @_;
	my @field_ids=GetPrimaryKeys($tablename);
    my @ids=@$data{@field_ids};
    my $dbh      = C4::Context->dbh;
    my ($keys,$values)=_filter_hash($tablename,$data,0);
    return unless ($keys);
    my $query = 
    qq{     UPDATE $tablename
            SET  }.join(",",@$keys).qq{
            WHERE }.join (" AND ",map{ "$_=?" }@field_ids);
	$debug && warn $query, join(",",@$values,@ids);

    my $sth = $dbh->prepare_cached($query);
	my $result;
    eval{$result=$sth->execute(@$values,@ids)}; 
	warn $@ if ($@ && $debug);
    return $result;
}

=head2 DeleteInTable

  $status = &DeleteInTable($tablename,$data_hashref);

Delete Data in table and returns the status of the operation

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
   		my $result;
    	eval{$result=$sth->execute(@$values)}; 
		warn $@ if ($@ && $debug);
    	return $result;
	}
}

=head2 GetPrimaryKeys

  @primarykeys = &GetPrimaryKeys($tablename)

Get the Primary Key field names of the table

=cut

sub GetPrimaryKeys {
	my $tablename=shift;
	my $hash_columns=_get_columns($tablename);
	return  grep { $hash_columns->{$_}->{'Key'} =~/PRI/i}  keys %$hash_columns;
}


=head2 clear_columns_cache

  C4::SQLHelper->clear_columns_cache();

cleans the internal cache of sysprefs. Please call this method if
you update a tables structure. Otherwise, your new changes
will not be seen by this process.

=cut

sub clear_columns_cache {
    %$hashref = ();
}



=head2 _get_columns

    _get_columns($tablename)

Given a tablename 
Returns a hashref of all the fieldnames of the table
With 
	Key
	Type
	Default

=cut

sub _get_columns {
    my ($tablename) = @_;
    unless ( exists( $hashref->{$tablename} ) ) {
        my $dbh = C4::Context->dbh;
        my $sth = $dbh->prepare_cached(qq{SHOW COLUMNS FROM $tablename });
        $sth->execute;
        my $columns = $sth->fetchall_hashref(qw(Field));
        $hashref->{$tablename} = $columns;
    }
    return $hashref->{$tablename};
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

sub _filter_columns {
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

  _filter_fields

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
		my ($keys, $values);
        if (my $special = delete $filter_input->{''}) { # XXX destroyes '' key
		    ($keys, $values) = _filter_fields($tablename,$special, $searchtype,$filtercolumns);
        }
		my ($hkeys, $hvalues) = _filter_hash($tablename,$filter_input, $searchtype);
		if ($hkeys){
            push @$keys, @$hkeys;
            push @$values, @$hvalues;
        }
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
        $debug && warn "filterstring : $filter_input";
		my ($keys, $values) = _filter_string($tablename,$filter_input, $searchtype,$filtercolumns);
		if ($keys){
		my $stringkey="(".join (") AND (",@$keys).")";
		return [$stringkey],$values;
		}
		else {
		return ();
		}
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
        if ( $columns->{$field}{Type}=~/date/ ) {
            if ( defined $filter_input->{$field} ) {
                if ( $filter_input->{$field} eq q{} ) {
                    $filter_input->{$field} = undef;
                } elsif ( $filter_input->{$field} !~ C4::Dates->regexp("iso") ) {
                    $filter_input->{$field} = format_date_in_iso($filter_input->{$field});
                }
            }
        }
		my ($tmpkeys, $localvalues)=_Process_Operands($filter_input->{$field},"$tablename.$field",$searchtype,$columns);
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
	my @operands=split /\s+/,$filter_input;

    # An act of desperation
    $searchtype = 'contain' if @operands > 1 && $searchtype =~ /start_with/o;

	my @columns_filtered= _filter_columns($tablename,$searchtype,$filtercolumns);
	my $columns= _get_columns($tablename);
	my (@values,@keys);
	foreach my $operand (@operands){
		my @localkeys;
		foreach my $field (@columns_filtered){
			my ($tmpkeys, $localvalues)=_Process_Operands($operand,"$tablename.$field",$searchtype,$columns);
			if ($tmpkeys){
				push @values,@$localvalues;
				push @localkeys,@$tmpkeys;
			}
		}
		my $sql= join (' OR ', @localkeys);
		push @keys, $sql;
	}

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

    $operand = [$operand] unless ref $operand eq 'ARRAY';
    foreach (@$operand) {
	    push @tmpkeys, " $field = ? ";
	    push @values, $_;
    }
	#By default, exact search
	if (!$searchtype ||$searchtype eq "exact"){
		return \@tmpkeys,\@values;
	}
	my $col_field=(index($field,".")>0?substr($field, index($field,".")+1):$field);
	if ($field=~/(?<!zip)code|(?<!card)number/ && $searchtype ne "exact"){
		push @tmpkeys,(" $field= '' ","$field IS NULL");
	}
	if ($columns->{$col_field}->{Type}=~/varchar|text/i){
		my @localvaluesextended;
		if ($searchtype eq "contain"){
            foreach (@$operand) {
			    push @tmpkeys,(" $field LIKE ? ");
			    push @localvaluesextended,("\%$_\%") ;
            }
		}
		if ($searchtype eq "field_start_with"){
            foreach (@$operand) {
			    push @tmpkeys,("$field LIKE ?");
			    push @localvaluesextended, ("$_\%") ;
            }
		}
		if ($searchtype eq "start_with"){
            foreach (@$operand) {
			    push @tmpkeys,("$field LIKE ?","$field LIKE ?");
			    push @localvaluesextended, ("$_\%", " $_\%") ;
            }
		}
		push @values,@localvaluesextended;
	}
	push @localkeys,qq{ (}.join(" OR ",@tmpkeys).qq{) };
	return (\@localkeys,\@values);
}
1;

