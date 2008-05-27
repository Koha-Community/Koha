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
	$VERSION = 0.03;
	@ISA = qw(Exporter);
	@EXPORT_OK = qw(
		&get_tag &get_tags &get_tag_rows
		&add_tags &add_tag
		&delete_tag_row_by_id
		&remove_tag
		&delete_tag_rows_by_ids
		&rectify_weights
		&get_approval_rows
		&blacklist
		&whitelist
		&is_approved
		&approval_counts
		&get_filters
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
		import Lingua::Ispell qw(spellcheck add_word_lc save_dictionary);
	}
}

INIT {
    $ext_dict and $Lingua::Ispell::path = $ext_dict;
    $debug and print STDERR "\$Lingua::Ispell::path = $Lingua::Ispell::path\n";
	@fields = qw(tag_id borrowernumber biblionumber term language date_created);
	$select_all = "SELECT " . join(',',@fields) . "\n FROM   tags_all\n";
}

sub get_filters (;$) {
	my $query = "SELECT * FROM tags_filters ";
	my ($sth);
	if (@_) {
		$sth = C4::Context->dbh->prepare($query . " WHERE filter_id = ? ");
		$sth->execute(shift);
	} else {
		$sth = C4::Context->dbh->prepare($query);
		$sth->execute;
	}
	return $sth->fetchall_arrayref({});
}

# 	(SELECT count(*) FROM tags_all     ) as tags_all,
# 	(SELECT count(*) FROM tags_index   ) as tags_index,

sub approval_counts () { 
	my $query = "SELECT
		(SELECT count(*) FROM tags_approval WHERE approved= 1) as approved_count,
		(SELECT count(*) FROM tags_approval WHERE approved=-1) as rejected_count,
		(SELECT count(*) FROM tags_approval WHERE approved= 0) as unapproved_count
	";
	my $sth = C4::Context->dbh->prepare($query);
	$sth->execute;
	my $result = $sth->fetchrow_hashref();
	$result->{approved_total} = $result->{approved_count} + $result->{rejected_count} + $result->{unapproved_count};
	$debug and warn "counts returned: " . Dumper $result;
	return $result;
}

sub remove_tag ($;$) {
	my $tag_id  = shift or return undef;
	my $user_id = (@_) ? shift : undef;
	my $rows = (defined $user_id) ?
			get_tag_rows({tag_id=>$tag_id, borrowernumber=>$user_id}) :
			get_tag_rows({tag_id=>$tag_id}) ;
	$rows or return 0;
	(scalar(@$rows) == 1) or return undef;	# should never happen (duplicate ids)
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
		unless (1 == scalar grep {/^ $key $/x} @ok_fields) {
			carp "get_tag_rows received unreconized argument key '$key'.";
			next;
		}
		if ($key eq 'limit') {
			my $val = $hash->{$key};
			unless ($val =~ /^(\d+,)?\d+$/) {
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
		unless (1 == scalar grep {/^ $key $/x} @ok_fields) {
			carp "get_tags received unreconized argument key '$key'.";
			next;
		}
		if ($key eq 'limit') {
			my $val = $hash->{$key};
			unless ($val =~ /^(\d+,)?\d+$/) {
				carp "Non-nuerical limit value '$val' ignored!";
				next;
			}
			$limit = " LIMIT $val\n";
		} elsif ($key eq 'sort') {
			foreach my $by (split /\,/, $hash->{$key}) {
				unless (
					$by =~ /^([-+])?(term)/ or
					$by =~ /^([-+])?(biblionumber)/ or
					$by =~ /^([-+])?(weight)/
				) {
					carp "get_tags received illegal sort order '$by'";
					next;
				}
				if ($order) {
					$order .= ", ";
				} else {
					$order = " ORDER BY ";
				}
				$order .= $2 . " " . ((!$1) ? '' : $1 eq '-' ? 'DESC' : $1 eq '+' ? 'ASC' : '') . "\n";
			}
			
		} else {
			my $whereval = $hash->{$key};
			my $longkey = ($key eq 'term') ? 'tags_index.term' : $key;
			my $op = ($whereval =~ s/^(>=|<=)// or
					  $whereval =~ s/^(>|=|<)//   ) ? $1 : '=';
			$wheres .= ($wheres) ? " AND    $longkey $op ?\n" : " WHERE  $longkey $op ?\n";
			push @exe_args, $whereval;
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

sub get_approval_rows (;$) {		# i.e., from tags_approval
	my $hash = shift || {};
	my @ok_fields = qw(term approved date_approved approved_by weight_total limit sort);
	my $wheres;
	my $limit  = "";
	my $order  = "";
	my @exe_args = ();
	foreach my $key (keys %$hash) {
		$debug and print STDERR "get_approval_rows arg. '$key' = ", $hash->{$key}, "\n";
		unless (length $key) {
			carp "Empty argument key to get_approval_rows: ignoring!";
			next;
		}
		unless (1 == scalar grep {/^ $key $/x} @ok_fields) {
			carp "get_approval_rows received unreconized argument key '$key'.";
			next;
		}
		if ($key eq 'limit') {
			my $val = $hash->{$key};
			unless ($val =~ /^(\d+,)?\d+$/) {
				carp "Non-nuerical limit value '$val' ignored!";
				next;
			}
			$limit = " LIMIT $val\n";
		} elsif ($key eq 'sort') {
			foreach my $by (split /\,/, $hash->{$key}) {
				unless (
					$by =~ /^([-+])?(term)/            or
					$by =~ /^([-+])?(biblionumber)/    or
					$by =~ /^([-+])?(weight_total)/    or
					$by =~ /^([-+])?(approved(_by)?)/  or
					$by =~ /^([-+])?(date_approved)/
				) {
					carp "get_approval_rows received illegal sort order '$by'";
					next;
				}
				if ($order) {
					$order .= ", ";
				} else {
					$order = " ORDER BY " unless $order;
				}
				$order .= $2 . " " . ((!$1) ? '' : $1 eq '-' ? 'DESC' : $1 eq '+' ? 'ASC' : '') . "\n";
			}
			
		} else {
			my $whereval = $hash->{$key};
			my $op = ($whereval =~ s/^(>=|<=)// or
					  $whereval =~ s/^(>|=|<)//   ) ? $1 : '=';
			$wheres .= ($wheres) ? " AND    $key $op ?\n" : " WHERE  $key $op ?\n";
			push @exe_args, $whereval;
		}
	}
	my $query = "
	SELECT 	tags_approval.term          AS term,
			tags_approval.approved      AS approved,
			tags_approval.date_approved AS date_approved,
			tags_approval.approved_by   AS approved_by,
			tags_approval.weight_total  AS weight_total,
			CONCAT(borrowers.surname, ', ', borrowers.firstname) AS approved_by_name
	FROM 	tags_approval
	LEFT JOIN borrowers
	ON      tags_approval.approved_by = borrowers.borrowernumber ";
	$query .= ($wheres||'') . $order . $limit;
	$debug and print STDERR "get_approval_rows query:\n $query\n",
							"get_approval_rows query args: ", join(',', @exe_args), "\n";
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
	my $sth = C4::Context->dbh->prepare("SELECT approved FROM tags_approval WHERE term = ?");
	$sth->execute($term);
	unless ($sth->rows) {
		$ext_dict and return (spellcheck($term) ? 0 : 1);	# spellcheck returns empty on OK word
		return undef;
	}
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

sub whitelist {
	my $operator = shift;
	defined $operator or return undef; # have to test defined to allow =0 (kohaadmin)
	if ($ext_dict) {
		foreach (@_) {
			spellcheck($_) or next;
			add_word_lc($_);
		}
	}
	foreach (@_) {
		my $aref = get_approval_rows({term=>$_});
		if ($aref and scalar @$aref) {
			mod_tag_approval($operator,$_,1);
		} else {
			add_tag_approval($_,$operator);
		}
	}
	return scalar @_;
}
# note: there is no "unwhitelist" operation because there is no remove for Ispell.
# The blacklist regexps should operate "in front of" the whitelist, so if you approve
# a term mistakenly, you can still reverse it. But there is no going back to "neutral".
sub blacklist {
	my $operator = shift;
	defined $operator or return undef; # have to test defined to allow =0 (kohaadmin)
	foreach (@_) {
		my $aref = get_approval_rows({term=>$_});
		if ($aref and scalar @$aref) {
			mod_tag_approval($operator,$_,-1);
		} else {
			add_tag_approval($_,$operator,-1);
		}
	}
	return scalar @_;
}
sub add_filter {
	my $operator = shift;
	defined $operator or return undef; # have to test defined to allow =0 (kohaadmin)
	my $query = "INSERT INTO tags_blacklist (regexp,y,z) VALUES (?,?,?)";
	# my $sth = C4::Context->dbh->prepare($query);
	return scalar @_;
}
sub remove_filter {
	my $operator = shift;
	defined $operator or return undef; # have to test defined to allow =0 (kohaadmin)
	my $query = "REMOVE FROM tags_blacklist WHERE blacklist_id = ?";
	# my $sth = C4::Context->dbh->prepare($query);
	# $sth->execute($term);
	return scalar @_;
}

sub add_tag_approval ($;$$) {	# or disapproval
	my $term = shift or return undef;
	my $query = "SELECT * FROM tags_approval WHERE term = ?";
	my $sth = C4::Context->dbh->prepare($query);
	$sth->execute($term);
	($sth->rows) and return increment_weight_total($term);
	my $operator = (@_ ? shift : 0);
	if ($operator) {
		my $approval = (@_ ? shift : 1); # default is to approve
		$query = "INSERT INTO tags_approval (term,approved_by,approved,date_approved) VALUES (?,?,?,NOW())";
		$debug and print STDERR "add_tag_approval query:\n$query\nadd_tag_approval args: ($term,$operator,$approval)\n";
		$sth = C4::Context->dbh->prepare($query);
		$sth->execute($term,$operator,$approval);
	} else {
		$query = "INSERT INTO tags_approval (term,date_approved) VALUES (?,NOW())";
		$debug and print STDERR "add_tag_approval query:\n$query\nadd_tag_approval args: ($term)\n";
		$sth = C4::Context->dbh->prepare($query);
		$sth->execute($term);
	}
	return $sth->rows;
}

sub mod_tag_approval ($$$) {
	my $operator = shift;
	defined $operator or return undef; # have to test defined to allow =0 (kohaadmin)
	my $term     = shift or return undef;
	my $approval = (@_ ? shift : 1);	# default is to approve
	my $query = "UPDATE tags_approval SET approved_by=?, approved=?, date_approved=NOW() WHERE term = ?";
	$debug and print STDERR "mod_tag_approval query:\n$query\nmod_tag_approval args: ($operator,$approval,$term)\n";
	my $sth = C4::Context->dbh->prepare($query);
	$sth->execute($operator,$approval,$term);
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
	decrement_weight_total(shift);
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
	");						# note: CANNOT use "?" for weight_total (see the args above).
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

=head2 External Dictionary (Ispell) [Recommended]

An external dictionary can be used as a means of "pre-populating" and tracking
allowed terms based on the widely available Ispell dictionary.  This can be the system
dictionary or a personal version, but in order to support whitelisting, it must be
editable to the process running Koha.  

To enable, enter the absolute path to the ispell dictionary in the system
preference "TagsExternalDictionary".

Using external Ispell is recommended for both ease of use and performance.  Note that any
language version of Ispell can be installed.  It is also possible to modify the dictionary 
at the command line to affect the desired content.

=head2 Table Structure

The tables used by tags are:
	tags_all
	tags_index
	tags_approval
	tags_blacklist

Your first thought may be that this looks a little complicated.  It is, but only because
it has to be.  I'll try to explain.

tags_all - This table would be all we really need if we didn't care about moderation or
performance or tags disappearing when borrowers are removed.  Too bad, we do.  Otherwise
though, it contains all the relevant info about a given tag:
	tag_id         - unique id number for it
	borrowernumber - user that entered it
	biblionumber   - book record it is attached to
	term           - tag "term" itself
	language       - perhaps used later to influence weighting
	date_created   - date and time it was created

tags_approval - Since we need to provide moderation, this table is used to track it.  If no
external dictionary is used, this table is the sole reference for approval and rejection.
With an external dictionary, it tracks pending terms and past whitelist/blacklist actions.
This could be called an "approved terms" table.  See above regarding the External Dictionary.
	term           - tag "term" itself 
	approved       - Negative, 0 or positive if tag is rejected, pending or approved.
	date_approved  - date of last action
	approved_by    - staffer performing the last action
	weight_total   - total occurance of term in any biblio by any users

tags_index - This table is for performance, because by far the most common operation will 
be fetching tags for a list of search results.  We will have a set of biblios, and we will
want ONLY their approved tags and overall weighting.  While we could implement a query that
would traverse tags_all filtered against tags_approval, the performance implications of
trying to calculate that and the "weight" (number of times a tag appears) on the fly are drastic.
	term           - approved term as it appears in tags_approval
	biblionumber   - book record it is attached to
	weight         - number of times tag applied by any user

tags_blacklist - TODO

So the best way to think about the different tabes is that they are each tailored to a certain
use.  Note that tags_approval and tags_index do not rely on the user's borrower mapping, so
the tag population can continue to grow even if a user is removed, along with the corresponding
rows in tags_all.  

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

