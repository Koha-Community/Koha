package C4::Tags;
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
use Carp;
use Exporter;

use C4::Context;
use C4::Debug;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
use vars qw($ext_dict $select_all @fields);

BEGIN {
	$VERSION = 0.01;
	@ISA = qw(Exporter);
	@EXPORT_OK = qw(
		&get_tag &get_tags &get_tag_rows
		&add_tags &add_tag
		&delete_tag_row_by_id
		&remove_tag
		&delete_tag_rows_by_ids
		&rectify_weights
	);
	# %EXPORT_TAGS = ();
	$ext_dict = C4::Context->preference('TagsExternalDictionary');
	if ($debug) {
		require Data::Dumper;
		import Data::Dumper qw(:DEFAULT);
		print STDERR __PACKAGE__ . " external dictionary = " . ($ext_dict||'none') . "\n";
	}
	if ($ext_dict) {
		require Lingua::Ispell;
		import Lingua::Ispell qw(spellcheck);
	}
}

INIT {
    $ext_dict and $Lingua::Ispell::path = $ext_dict;
    $debug and print STDERR "\$Lingua::Ispell::path = $Lingua::Ispell::path\n";
	@fields = qw(tag_id borrowernumber biblionumber term language date_created);
	$select_all = "SELECT " . join(',',@fields) . "\n FROM   tags_all\n";
}

sub remove_tag ($) {
	my $tag_id = shift;
	my $rows = get_tag_rows({tag_id=>$tag_id}) or return 0;
	(scalar(@$rows) == 1) or return undef;
	my $row = shift(@$rows);
	($tag_id == $row->{tag_id}) or return 0;
	my $tags = get_tags({term=>$row->{term}, biblionumber=>$row->{biblionumber}});
	my $index = shift(@$tags);
	$debug and print STDERR
		sprintf "remove_tag: tag_id=>%s, biblionumber=>%s, weight=>%s, weight_total=>%s\n",
			$row->{tag_id}, $row->{biblionumber}, $index->{weight}, $index->{weight_total};
	if ($index->{weight} <= 1) {
		delete_tag_index($row->{term},$row->{biblionumber});
	} else {
		decrement_weight($row->{term},$row->{biblionumber});
	}
	if ($index->{weight_total} <= 1) {
		delete_tag_approval($row->{term});
	} else {
		decrement_weight_total($row->{term});
	}
	delete_tag_row_by_id($tag_id);
}

sub delete_tag_index ($$) {
	(@_) or return undef;
	my $sth = C4::Context->dbh->prepare("DELETE FROM tags_index WHERE term = ? AND biblionumber = ? LIMIT 1");
	$sth->execute(@_);
	return $sth->rows || 0;
}
sub delete_tag_approval ($) {
	(@_) or return undef;
	my $sth = C4::Context->dbh->prepare("DELETE FROM tags_approval WHERE term = ? LIMIT 1");
	$sth->execute(shift);
	return $sth->rows || 0;
}
sub delete_tag_row_by_id ($) {
	(@_) or return undef;
	my $sth = C4::Context->dbh->prepare("DELETE FROM tags_all WHERE tag_id = ? LIMIT 1");
	$sth->execute(shift);
	return $sth->rows || 0;
}
sub delete_tag_rows_by_ids (@) {
	(@_) or return undef;
	my $i=0;
	foreach(@_) {
		$i += delete_tag_row_by_id($_);
	}
	($i == scalar(@_)) or
		warn sprintf "delete_tag_rows_by_ids tried %s tag_ids, only succeeded on $i", scalar(@_);
	return $i;
}

sub get_tag_rows ($) {
	my $hash = shift || {};
	my @ok_fields = @fields;
	push @ok_fields, 'limit';	# push the limit! :)
	my $wheres;
	my $limit  = "";
	my @exe_args = ();
	foreach my $key (keys %$hash) {
		$debug and print STDERR "get_tag_rows arg. '$key' = ", $hash->{$key}, "\n";
		unless (length $key) {
			carp "Empty argument key to get_tag_rows: ignoring!";
			next;
		}
		unless (1 == scalar grep {/^ $key $/xi} @ok_fields) {
			carp "get_tag_rows received unreconized argument key '$key'.";
			next;
		}
		if ($key =~ /^limit$/i) {
			my $val = $hash->{$key};
			unless ($val =~ /^\d+$/) {
				carp "Non-nuerical limit value '$val' ignored!";
				next;
			}
			$limit = " LIMIT $val\n";
		} else {
			$wheres .= ($wheres) ? " AND    $key = ?\n" : " WHERE  $key = ?\n";
			push @exe_args, $hash->{$key};
		}
	}
	my $query = $select_all . ($wheres||'') . $limit;
	$debug and print STDERR "get_tag_rows query:\n $query\n",
							"get_tag_rows query args: ", join(',', @exe_args), "\n";
	my $sth = C4::Context->dbh->prepare($query);
	if (@exe_args) {
		$sth->execute(@exe_args);
	} else {
		$sth->execute;
	}
	return $sth->fetchall_arrayref({});
}

sub get_tags (;$) {		# i.e., from tags_index
	# my $self = shift;
	my $hash = shift || {};
	my @ok_fields = qw(term biblionumber weight limit sort);
	my $wheres;
	my $limit  = "";
	my $order  = "";
	my @exe_args = ();
	foreach my $key (keys %$hash) {
		$debug and print STDERR "get_tags arg. '$key' = ", $hash->{$key}, "\n";
		unless (length $key) {
			carp "Empty argument key to get_tags: ignoring!";
			next;
		}
		unless (1 == scalar grep {/^ $key $/xi} @ok_fields) {
			carp "get_tags received unreconized argument key '$key'.";
			next;
		}
		if ($key =~ /^limit$/i) {
			my $val = $hash->{$key};
			unless ($val =~ /^\d+$/) {
				carp "Non-nuerical limit value '$val' ignored!";
				next;
			}
			$limit = " LIMIT $val\n";
		} elsif ($key =~ /^sort$/i) {
			foreach my $by (split /\,/, $hash->{$key}) {
				unless (
					$by =~ /^([-+])?(term)/ or
					$by =~ /^([-+])?(biblionumber)/ or
					$by =~ /^([-+])?(weight)/
				) {
					carp "get_tags received illegal sort order '$by'";
					next;
				}
				$order .= " ORDER BY $2 " . ($1 eq '-' ? 'DESC' : $1 eq '+' ? 'ASC' : '') . "\n";
			}
			
		} else {
			my $whereval = $key;
			($key =~ /^term$/i) and $whereval = 'tags_index.term';
			$wheres .= ($wheres) ? " AND    $whereval = ?\n" : " WHERE  $whereval = ?\n";
			push @exe_args, $hash->{$key};
		}
	}
	my $query = "
	SELECT    tags_index.term as term,biblionumber,weight,weight_total
	FROM      tags_index
	LEFT JOIN tags_approval 
	ON        tags_index.term = tags_approval.term
	" . ($wheres||'') . $order . $limit;
	$debug and print STDERR "get_tags query:\n $query\n",
							"get_tags query args: ", join(',', @exe_args), "\n";
	my $sth = C4::Context->dbh->prepare($query);
	if (@exe_args) {
		$sth->execute(@exe_args);
	} else {
		$sth->execute;
	}
	return $sth->fetchall_arrayref({});
}

sub is_approved ($) {
	my $term = shift or return undef;
	if ($ext_dict) {
		return (spellcheck($term) ? 0 : 1);
	}
	my $sth = C4::Context->dbh->prepare("SELECT approved FROM tags_approval WHERE term = ?");
	$sth->execute($term);
	$sth->rows or return undef;
	return $sth->fetch;
}

sub get_tag_index ($;$) {
	my $term = shift or return undef;
	my $sth;
	if (@_) {
		$sth = C4::Context->dbh->prepare("SELECT * FROM tags_index WHERE term = ? AND biblionumber = ?");
		$sth->execute($term,shift);
	} else {
		$sth = C4::Context->dbh->prepare("SELECT * FROM tags_index WHERE term = ?");
		$sth->execute($term);
	}
	return $sth->fetchrow_hashref;
}

sub add_tag_approval ($;$) {
	my $term = shift or return undef;
	my $query = "SELECT * FROM tags_approval WHERE term = ?";
	my $sth = C4::Context->dbh->prepare($query);
	$sth->execute($term);
	($sth->rows) and return increment_weight_total($term);
	my $ok = (@_ ? shift : 0);
	if ($ok) {
		$query = "INSERT INTO tags_approval (term,approved_by,approved,date_approved) VALUES (?,?,1,NOW())";
		$debug and print STDERR "add_tag_approval query:\n$query\nadd_tag_approval args: ($term,$ok)\n";
		$sth = C4::Context->dbh->prepare($query);
		$sth->execute($term,$ok);
	} else {
		$query = "INSERT INTO tags_approval (term,date_approved) VALUES (?,NOW())";
		$debug and print STDERR "add_tag_approval query:\n$query\nadd_tag_approval args: ($term)\n";
		$sth = C4::Context->dbh->prepare($query);
		$sth->execute($term);
	}
	return $sth->rows;
}

sub add_tag_index ($$;$) {
	my $term         = shift or return undef;
	my $biblionumber = shift or return undef;
	my $query = "SELECT * FROM tags_index WHERE term = ? AND biblionumber = ?";
	my $sth = C4::Context->dbh->prepare($query);
	$sth->execute($term,$biblionumber);
	($sth->rows) and return increment_weight($term,$biblionumber);
	$query = "INSERT INTO tags_index (term,biblionumber) VALUES (?,?)";
	$debug and print "add_tag_index query:\n$query\nadd_tag_index args: ($term,$biblionumber)\n";
	$sth = C4::Context->dbh->prepare($query);
	$sth->execute($term,$biblionumber);
	return $sth->rows;
}

sub get_tag ($) {		# by tag_id
	(@_) or return undef;
	my $sth = C4::Context->dbh->prepare("$select_all WHERE tag_id = ?");
	$sth->execute(shift);
	return $sth->fetchrow_hashref;
}

sub rectify_weights (;$) {
	my $dbh = C4::Context->dbh;
	my $sth;
	my $query = "
	SELECT term,biblionumber,count(*) as count
	FROM   tags_all
	";
	(@_) and $query .= " WHERE term =? ";
	$query .= " GROUP BY term,biblionumber ";
	$sth = $dbh->prepare($query);
	if (@_) {
		$sth->execute(shift);
	} else {
		$sth->execute();
	}
	my $results = $sth->fetchall_arrayref({}) or return undef;
	my %tally = ();
	foreach (@$results) {
		_set_weight($_->{count},$_->{term},$_->{biblionumber});
		$tally{$_->{term}} += $_->{count};
	}
	foreach (keys %tally) {
		_set_weight_total($tally{$_},$_);
	}
	return ($results,\%tally);
}

sub increment_weights ($$) {
	increment_weight(@_);
	increment_weight_total(shift);
}
sub decrement_weights ($$) {
	decrement_weight(@_);
	derement_weight_total(shift);
}
sub increment_weight_total ($) {
	_set_weight_total('weight_total+1',shift);
}
sub increment_weight ($$) {
	_set_weight('weight+1',shift,shift);
}
sub decrement_weight_total ($) {
	_set_weight_total('weight_total-1',shift);
}
sub decrement_weight ($$) {
	_set_weight('weight-1',shift,shift);
}
sub _set_weight_total ($$) {
	my $sth = C4::Context->dbh->prepare("
	UPDATE tags_approval
	SET    weight_total=" . (shift) . "
	WHERE  term=?
	");
	$sth->execute(shift);	# just the term
}
sub _set_weight ($$$) {
	my $dbh = C4::Context->dbh;
	my $sth = $dbh->prepare("
	UPDATE tags_index
	SET    weight=" . (shift) . "
	WHERE  term=?
	AND    biblionumber=?
	");
	$sth->execute(@_);
}

sub add_tag ($$;$$) {	# biblionumber,term,[borrowernumber,approvernumber]
	my $biblionumber = shift or return undef;
	my $term         = shift or return undef;
	my $borrowernumber = (@_) ? shift : 0;		# the user, default to kohaadmin

	# first, add to tags regardless of approaval
	my $query = "INSERT INTO tags_all
	(borrowernumber,biblionumber,term,date_created)
	VALUES (?,?,?,NOW())";
	$debug and print STDERR "add_tag query:\n $query\n",
							"add_tag query args: ($borrowernumber,$biblionumber,$term)\n";
	my $sth = C4::Context->dbh->prepare($query);
	$sth->execute($borrowernumber,$biblionumber,$term);

	# then 
	if (@_) { 	# if an arg remains, it is the borrowernumber of the approver: tag is pre-approved.
		my $approver = shift;
		add_tag_approval($term,$approver);
		add_tag_index($term,$biblionumber,$approver);
	} elsif (is_approved($term)) {
		add_tag_approval($term,1);
		add_tag_index($term,$biblionumber,1);
	} else {
		add_tag_approval($term);
		add_tag_index($term,$biblionumber);
	}
}

1;
__END__

=head1 C4::Tags.pm - Support for user tagging of biblios.

More verose debugging messages are sent in the presence of non-zero $ENV{"DEBUG"}.

=head2 add_tag(biblionumber,term[,borrowernumber])

=head3 TO DO: Add real perldoc

=head2 Tricks

If you want to auto-populate some tags for debugging, do something like this:

mysql> select biblionumber from biblio where title LIKE "%Health%";
+--------------+
| biblionumber |
+--------------+
|           18 | 
|           22 | 
|           24 | 
|           30 | 
|           44 | 
|           45 | 
|           46 | 
|           49 | 
|          111 | 
|          113 | 
|          128 | 
|          146 | 
|          155 | 
|          518 | 
|          522 | 
|          524 | 
|          530 | 
|          544 | 
|          545 | 
|          546 | 
|          549 | 
|          611 | 
|          613 | 
|          628 | 
|          646 | 
|          655 | 
+--------------+
26 rows in set (0.00 sec)

Then, take those numbers and type them into this perl command line:
perl -ne 'use C4::Tags qw(get_tags add_tag); use Data::Dumper;chomp; add_tag($_,"health",51,1); print Dumper get_tags({limit=>5,term=>"health",});'

=cut

