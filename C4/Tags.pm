package C4::Tags;

# Copyright Liblime 2008
# Parts Copyright ACPL 2011
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
use Carp qw( carp );
use Exporter;

use C4::Context;
use Module::Load::Conditional qw( check_install );
use Koha::Tags;
use Koha::Tags::Approvals;
use Koha::Tags::Indexes;
use constant TAG_FIELDS => qw(tag_id borrowernumber biblionumber term language date_created);
use constant TAG_SELECT => "SELECT " . join( ',', TAG_FIELDS ) . "\n FROM   tags_all\n";

our ( @ISA, @EXPORT_OK );

BEGIN {
    @ISA       = qw(Exporter);
    @EXPORT_OK = qw(
        get_tags get_tag_rows
        add_tags
        add_tag
        add_tag_approval
        add_tag_index
        remove_tag
        get_approval_rows
        blacklist
        whitelist
        is_approved
        approval_counts
        get_count_by_tag_status
        get_filters
        stratify_tags
    );
    my $ext_dict = C4::Context->preference('TagsExternalDictionary');

    if ( $ext_dict && !check_install( module => 'Lingua::Ispell' ) ) {
        warn "Ignoring TagsExternalDictionary, because Lingua::Ispell is not installed.";
        $ext_dict = q{};
    }
    if ($ext_dict) {
        require Lingua::Ispell;
        import Lingua::Ispell qw(spellcheck add_word_lc);
        $Lingua::Ispell::path = $ext_dict;
    }
}

=head1 C4::Tags.pm - Support for user tagging of biblios.

=cut

=head2 get_filters

Missing POD for get_filters.

=cut

sub get_filters {
    my $query = "SELECT * FROM tags_filters ";
    my ($sth);
    if (@_) {
        $sth = C4::Context->dbh->prepare( $query . " WHERE filter_id = ? " );
        $sth->execute(shift);
    } else {
        $sth = C4::Context->dbh->prepare($query);
        $sth->execute;
    }
    return $sth->fetchall_arrayref( {} );
}

#     (SELECT count(*) FROM tags_all     ) as tags_all,
#     (SELECT count(*) FROM tags_index   ) as tags_index,

=head2 approval_counts

Missing POD for approval_counts.

=cut

sub approval_counts {
    my $query = "SELECT
        (SELECT count(*) FROM tags_approval WHERE approved= 1) as approved_count,
        (SELECT count(*) FROM tags_approval WHERE approved=-1) as rejected_count,
        (SELECT count(*) FROM tags_approval WHERE approved= 0) as unapproved_count
    ";
    my $sth = C4::Context->dbh->prepare($query);
    $sth->execute;
    my $result = $sth->fetchrow_hashref();
    $result->{approved_total} = $result->{approved_count} + $result->{rejected_count} + $result->{unapproved_count};
    return $result;
}

=head2 get_count_by_tag_status

  get_count_by_tag_status($status);

Takes a status and gets a count of tags with that status

=cut

sub get_count_by_tag_status {
    my ($status) = @_;
    my $dbh      = C4::Context->dbh;
    my $query    = "SELECT count(*) FROM tags_approval WHERE approved=?";
    my $sth      = $dbh->prepare($query);
    $sth->execute($status);
    return $sth->fetchrow;
}

=head2 remove_tag

Missing POD for remove_tag.

=cut

sub remove_tag {
    my $tag_id  = shift or return;
    my $user_id = (@_) ? shift : undef;
    my $rows =
        ( defined $user_id )
        ? get_tag_rows( { tag_id => $tag_id, borrowernumber => $user_id } )
        : get_tag_rows( { tag_id => $tag_id } );
    $rows                   or return 0;
    ( scalar(@$rows) == 1 ) or return;     # should never happen (duplicate ids)
    my $row = shift(@$rows);
    ( $tag_id == $row->{tag_id} ) or return 0;
    my $tags  = get_tags( { term => $row->{term}, biblionumber => $row->{biblionumber} } );
    my $index = shift(@$tags);

    if ( $index->{weight} <= 1 ) {
        Koha::Tags::Indexes->search( { term => $row->{term}, biblionumber => $row->{biblionumber} } )->delete;
    } else {
        decrement_weight( $row->{term}, $row->{biblionumber} );
    }
    if ( $index->{weight_total} <= 1 ) {
        Koha::Tags::Approvals->search( { term => $row->{term} } )->delete;
    } else {
        decrement_weight_total( $row->{term} );
    }
    Koha::Tags->search( { tag_id => $tag_id } )->delete;
}

=head2 get_tag_rows

Missing POD for get_tag_rows.

=cut

sub get_tag_rows {
    my $hash      = shift || {};
    my @ok_fields = TAG_FIELDS;
    push @ok_fields, 'limit';    # push the limit! :)
    my $wheres;
    my $limit    = "";
    my @exe_args = ();
    foreach my $key ( keys %$hash ) {
        unless ( length $key ) {
            carp "Empty argument key to get_tag_rows: ignoring!";
            next;
        }
        unless ( 1 == scalar grep { $_ eq $key } @ok_fields ) {
            carp "get_tag_rows received unrecognized argument key '$key'.";
            next;
        }
        if ( $key eq 'limit' ) {
            my $val = $hash->{$key};
            unless ( $val =~ /^(\d+,)?\d+$/ ) {
                carp "Non-nuerical limit value '$val' ignored!";
                next;
            }
            $limit = " LIMIT $val\n";
        } else {
            $wheres .= ($wheres) ? " AND    $key = ?\n" : " WHERE  $key = ?\n";
            push @exe_args, $hash->{$key};
        }
    }
    my $query = TAG_SELECT . ( $wheres || '' ) . $limit;
    my $sth   = C4::Context->dbh->prepare($query);
    if (@exe_args) {
        $sth->execute(@exe_args);
    } else {
        $sth->execute;
    }
    return $sth->fetchall_arrayref( {} );
}

=head2 get_tags

Missing POD for get_tags.

=cut

sub get_tags {    # i.e., from tags_index
    my $hash      = shift || {};
    my @ok_fields = qw(term biblionumber weight limit sort approved);
    my $wheres;
    my $limit    = "";
    my $order    = "";
    my @exe_args = ();
    foreach my $key ( keys %$hash ) {
        unless ( length $key ) {
            carp "Empty argument key to get_tags: ignoring!";
            next;
        }
        unless ( 1 == scalar grep { $_ eq $key } @ok_fields ) {
            carp "get_tags received unrecognized argument key '$key'.";
            next;
        }
        if ( $key eq 'limit' ) {
            my $val = $hash->{$key};
            unless ( $val =~ /^(\d+,)?\d+$/ ) {
                carp "Non-nuerical limit value '$val' ignored!";
                next;
            }
            $limit = " LIMIT $val\n";
        } elsif ( $key eq 'sort' ) {
            foreach my $by ( split /\,/, $hash->{$key} ) {
                unless ( $by =~ /^([-+])?(term)/
                    or $by =~ /^([-+])?(biblionumber)/
                    or $by =~ /^([-+])?(weight)/ )
                {
                    carp "get_tags received illegal sort order '$by'";
                    next;
                }
                if ($order) {
                    $order .= ", ";
                } else {
                    $order = " ORDER BY ";
                }
                $order .= $2 . " " . ( ( !$1 ) ? '' : $1 eq '-' ? 'DESC' : $1 eq '+' ? 'ASC' : '' ) . "\n";
            }

        } else {
            my $whereval = $hash->{$key};
            my $longkey =
                  ( $key eq 'term' )     ? 'tags_index.term'
                : ( $key eq 'approved' ) ? 'tags_approval.approved'
                :                          $key;
            my $op = ( $whereval =~ s/^(>=|<=)// or $whereval =~ s/^(>|=|<)// ) ? $1 : '=';
            $wheres .= ($wheres) ? " AND    $longkey $op ?\n" : " WHERE  $longkey $op ?\n";
            push @exe_args, $whereval;
        }
    }
    my $query = "
    SELECT    tags_index.term as term,biblionumber,weight,weight_total
    FROM      tags_index
    LEFT JOIN tags_approval
    ON        tags_index.term = tags_approval.term
    " . ( $wheres || '' ) . $order . $limit;
    my $sth = C4::Context->dbh->prepare($query);
    if (@exe_args) {
        $sth->execute(@exe_args);
    } else {
        $sth->execute;
    }
    return $sth->fetchall_arrayref( {} );
}

=head2 get_approval_rows

Missing POD for get_approval_rows.

=cut

sub get_approval_rows {    # i.e., from tags_approval
    my $hash      = shift || {};
    my @ok_fields = qw(term approved date_approved approved_by weight_total limit sort borrowernumber);
    my $wheres;
    my $limit    = "";
    my $order    = "";
    my @exe_args = ();
    foreach my $key ( keys %$hash ) {
        unless ( length $key ) {
            carp "Empty argument key to get_approval_rows: ignoring!";
            next;
        }
        unless ( 1 == scalar grep { $_ eq $key } @ok_fields ) {
            carp "get_approval_rows received unrecognized argument key '$key'.";
            next;
        }
        if ( $key eq 'limit' ) {
            my $val = $hash->{$key};
            unless ( $val =~ /^(\d+,)?\d+$/ ) {
                carp "Non-numerical limit value '$val' ignored!";
                next;
            }
            $limit = " LIMIT $val\n";
        } elsif ( $key eq 'sort' ) {
            foreach my $by ( split /\,/, $hash->{$key} ) {
                unless ( $by =~ /^([-+])?(term)/
                    or $by =~ /^([-+])?(biblionumber)/
                    or $by =~ /^([-+])?(borrowernumber)/
                    or $by =~ /^([-+])?(weight_total)/
                    or $by =~ /^([-+])?(approved(_by)?)/
                    or $by =~ /^([-+])?(date_approved)/ )
                {
                    carp "get_approval_rows received illegal sort order '$by'";
                    next;
                }
                if ($order) {
                    $order .= ", ";
                } else {
                    $order = " ORDER BY " unless $order;
                }
                $order .= $2 . " " . ( ( !$1 ) ? '' : $1 eq '-' ? 'DESC' : $1 eq '+' ? 'ASC' : '' ) . "\n";
            }

        } else {
            my $whereval = $hash->{$key};
            my $op       = ( $whereval =~ s/^(>=|<=)// or $whereval =~ s/^(>|=|<)// ) ? $1 : '=';
            $wheres .= ($wheres) ? " AND    $key $op ?\n" : " WHERE  $key $op ?\n";
            push @exe_args, $whereval;
        }
    }
    my $query = "
    SELECT     tags_approval.term          AS term,
            tags_approval.approved      AS approved,
            tags_approval.date_approved AS date_approved,
            tags_approval.approved_by   AS approved_by,
            tags_approval.weight_total  AS weight_total,
            CONCAT(borrowers.surname, ', ', borrowers.firstname) AS approved_by_name
    FROM     tags_approval
    LEFT JOIN borrowers
    ON      tags_approval.approved_by = borrowers.borrowernumber ";
    $query .= ( $wheres || '' ) . $order . $limit;
    my $sth = C4::Context->dbh->prepare($query);
    if (@exe_args) {
        $sth->execute(@exe_args);
    } else {
        $sth->execute;
    }
    return $sth->fetchall_arrayref( {} );
}

=head2 is_approved

Missing POD for is_approved.

=cut

sub is_approved {
    my $term = shift or return;
    my $sth  = C4::Context->dbh->prepare("SELECT approved FROM tags_approval WHERE term = ?");
    $sth->execute($term);
    my $ext_dict = C4::Context->preference('TagsExternalDictionary');
    unless ( $sth->rows ) {
        $ext_dict and return ( spellcheck($term) ? 0 : 1 );    # spellcheck returns empty on OK word
        return 0;
    }
    return $sth->fetchrow;
}

=head2 get_tag_index

Missing POD for get_tag_index.

=cut

sub get_tag_index {
    my $term = shift or return;
    my $sth;
    if (@_) {
        $sth = C4::Context->dbh->prepare("SELECT * FROM tags_index WHERE term = ? AND biblionumber = ?");
        $sth->execute( $term, shift );
    } else {
        $sth = C4::Context->dbh->prepare("SELECT * FROM tags_index WHERE term = ?");
        $sth->execute($term);
    }
    return $sth->fetchrow_hashref;
}

=head2 whitelist

Missing POD for whitelist.

=cut

sub whitelist {
    my $operator = shift;
    defined $operator or return;    # have to test defined to allow =0 (kohaadmin)
    my $ext_dict = C4::Context->preference('TagsExternalDictionary');
    if ($ext_dict) {
        foreach (@_) {
            spellcheck($_) or next;
            add_word_lc($_);
        }
    }
    foreach (@_) {
        my $aref = get_approval_rows( { term => $_ } );
        if ( $aref and scalar @$aref ) {
            mod_tag_approval( $operator, $_, 1 );
        } else {
            add_tag_approval( $_, $operator );
        }
    }
    return scalar @_;
}

# note: there is no "unwhitelist" operation because there is no remove for Ispell.
# The blacklist regexps should operate "in front of" the whitelist, so if you approve
# a term mistakenly, you can still reverse it. But there is no going back to "neutral".

=head2 blacklist

Missing POD for blacklist.

=cut

sub blacklist {
    my $operator = shift;
    defined $operator or return;    # have to test defined to allow =0 (kohaadmin)
    foreach (@_) {
        my $aref = get_approval_rows( { term => $_ } );
        if ( $aref and scalar @$aref ) {
            mod_tag_approval( $operator, $_, -1 );
        } else {
            add_tag_approval( $_, $operator, -1 );
        }
    }
    return scalar @_;
}

=head2 add_filter

Missing POD for add_filter.

=cut

sub add_filter {
    my $operator = shift;
    defined $operator or return;    # have to test defined to allow =0 (kohaadmin)
    my $query = "INSERT INTO tags_blacklist (regexp,y,z) VALUES (?,?,?)";

    # my $sth = C4::Context->dbh->prepare($query);
    return scalar @_;
}

=head2 remove_filter

Missing POD for remove_filter.

=cut

sub remove_filter {
    my $operator = shift;
    defined $operator or return;    # have to test defined to allow =0 (kohaadmin)
    my $query = "REMOVE FROM tags_blacklist WHERE blacklist_id = ?";

    # my $sth = C4::Context->dbh->prepare($query);
    # $sth->execute($term);
    return scalar @_;
}

=head2 add_tag_approval

Missing POD for add_tag_approval.

=cut

sub add_tag_approval {    # or disapproval
    my $term  = shift or return;
    my $query = "SELECT * FROM tags_approval WHERE term = ?";
    my $sth   = C4::Context->dbh->prepare($query);
    $sth->execute($term);
    ( $sth->rows ) and return increment_weight_total($term);
    my $operator = shift || 0;
    my $approval = ( @_ ? shift : 0 );    # default is unapproved
    my @exe_args = ($term);               # all 3 queries will use this argument

    if ($operator) {
        $query = "INSERT INTO tags_approval (term,approved_by,approved,date_approved) VALUES (?,?,?,NOW())";
        push @exe_args, $operator, $approval;
    } elsif ($approval) {
        $query = "INSERT INTO tags_approval (term,approved,date_approved) VALUES (?,?,NOW())";
        push @exe_args, $approval;
    } else {
        $query = "INSERT INTO tags_approval (term,date_approved) VALUES (?,NOW())";
    }
    $sth = C4::Context->dbh->prepare($query);
    $sth->execute(@exe_args);
    return $sth->rows;
}

=head2 mod_tag_approval

Missing POD for mod_tag_approval.

=cut

sub mod_tag_approval {
    my $operator = shift;
    defined $operator or return;                 # have to test defined to allow =0 (kohaadmin)
    my $term     = shift or return;
    my $approval = ( scalar @_ ? shift : 1 );    # default is to approve
    my $query    = "UPDATE tags_approval SET approved_by=?, approved=?, date_approved=NOW() WHERE term = ?";
    my $sth      = C4::Context->dbh->prepare($query);
    $sth->execute( $operator, $approval, $term );
}

=head2 add_tag_index

Missing POD for add_tag_index.

=cut

sub add_tag_index {
    my $term         = shift or return;
    my $biblionumber = shift or return;
    my $query        = "SELECT * FROM tags_index WHERE term = ? AND biblionumber = ?";
    my $sth          = C4::Context->dbh->prepare($query);
    $sth->execute( $term, $biblionumber );
    ( $sth->rows ) and return increment_weight( $term, $biblionumber );
    $query = "INSERT INTO tags_index (term,biblionumber) VALUES (?,?)";
    $sth   = C4::Context->dbh->prepare($query);
    $sth->execute( $term, $biblionumber );
    return $sth->rows;
}

=head2 increment_weights

Missing POD for increment_weights.

=cut

sub increment_weights {
    increment_weight(@_);
    increment_weight_total(shift);
}

=head2 decrement_weights

Missing POD for decrement_weights.

=cut

sub decrement_weights {
    decrement_weight(@_);
    decrement_weight_total(shift);
}

=head2 increment_weight_total

Missing POD for increment_weight_total.

=cut

sub increment_weight_total {
    _set_weight_total( 'weight_total+1', shift );
}

=head2 increment_weight

Missing POD for increment_weight.

=cut

sub increment_weight {
    _set_weight( 'weight+1', shift, shift );
}

=head2 decrement_weight_total

Missing POD for decrement_weight_total.

=cut

sub decrement_weight_total {
    _set_weight_total( 'weight_total-1', shift );
}

=head2 decrement_weight

Missing POD for decrement_weight.

=cut

sub decrement_weight {
    _set_weight( 'weight-1', shift, shift );
}

sub _set_weight_total {
    my $sth = C4::Context->dbh->prepare( "
    UPDATE tags_approval
    SET    weight_total=" . (shift) . "
    WHERE  term=?
    " );    # note: CANNOT use "?" for weight_total (see the args above).
    $sth->execute(shift);    # just the term
}

sub _set_weight {
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare( "
    UPDATE tags_index
    SET    weight=" . (shift) . "
    WHERE  term=?
    AND    biblionumber=?
    " );
    $sth->execute(@_);
}

sub add_tag {    # biblionumber,term,[borrowernumber,approvernumber]
    my $biblionumber   = shift or return;
    my $term           = shift or return;
    my $borrowernumber = (@_) ? shift : 0;    # the user, default to kohaadmin
    $term =~ s/^\s+//;
    $term =~ s/\s+$//;
    ($term) or return;                        # must be more than whitespace
    my $rows =
        get_tag_rows( { biblionumber => $biblionumber, borrowernumber => $borrowernumber, term => $term, limit => 1 } );
    my $query = "INSERT INTO tags_all
    (borrowernumber,biblionumber,term,date_created)
    VALUES (?,?,?,NOW())";

    if ( scalar @$rows ) {
        return;
    }

    # add to tags_all regardless of approaval
    my $sth = C4::Context->dbh->prepare($query);
    $sth->execute( $borrowernumber, $biblionumber, $term );

    # then
    if ( scalar @_ ) {    # if arg remains, it is the borrowernumber of the approver: tag is pre-approved.
        my $approver = shift;
        add_tag_approval( $term, $approver, 1 );
        add_tag_index( $term, $biblionumber, $approver );
    } elsif ( is_approved($term) >= 1 ) {
        add_tag_approval( $term, 0, 1 );
        add_tag_index( $term, $biblionumber, 1 );
    } else {
        add_tag_approval($term);
        add_tag_index( $term, $biblionumber );
    }
}

# This takes a set of tags, as returned by C<get_approval_rows> and divides
# them up into a number of "strata" based on their weight. This is useful
# to display them in a number of different sizes.
#
# Usage:
#   ($min, $max) = stratify_tags($strata, $tags);
# $stratum: the number of divisions you want
# $tags: the tags, as provided by get_approval_rows
# $min: the minimum stratum value
# $max: the maximum stratum value. This may be the same as $min if there
# is only one weight. Beware of divide by zeros.
# This will add a field to the tag called "stratum" containing the calculated
# value.

=head2 stratify_tags

Missing POD for stratify_tags.

=cut

sub stratify_tags {
    my ( $strata, $tags ) = @_;
    return ( 0, 0 ) if !@$tags;
    my ( $min, $max );
    foreach (@$tags) {
        my $w = $_->{weight_total};
        $min = $w if ( !defined($min) || $min > $w );
        $max = $w if ( !defined($max) || $max < $w );
    }

    # normalise min to zero
    $max = $max - $min;
    my $orig_min = $min;
    $min = 0;

    # if min and max are the same, just make it 1
    my $span = ( $strata - 1 ) / ( $max || 1 );
    foreach (@$tags) {
        my $w = $_->{weight_total};
        $_->{stratum} = int( ( $w - $orig_min ) * $span );
    }
    return ( $min, $max );
}

1;
__END__

=head2 add_tag(biblionumber,term[,borrowernumber])

=head3 TO DO: Add real perldoc

=cut

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

WARNING: The default Ispell dictionary includes (properly spelled) obscenities!  Users 
should build their own wordlist and recompile Ispell based on it.  See man ispell for 
instructions.

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
    weight_total   - total occurrence of term in any biblio by any users

tags_index - This table is for performance, because by far the most common operation will 
be fetching tags for a list of search results.  We will have a set of biblios, and we will
want ONLY their approved tags and overall weighting.  While we could implement a query that
would traverse tags_all filtered against tags_approval, the performance implications of
trying to calculate that and the "weight" (number of times a tag appears) on the fly are drastic.
    term           - approved term as it appears in tags_approval
    biblionumber   - book record it is attached to
    weight         - number of times tag applied by any user

tags_blacklist - A set of regular expression filters.  Unsurprisingly, these should be perl-
compatible (PCRE) for your version of perl.  Since this is a blacklist, a term will be
blocked if it matches any of the given patterns.  WARNING: do not add blacklist regexps
if you do not understand their operation and interaction.  It is quite easy to define too
simple or too complex a regexp and effectively block all terms.  The blacklist operation is 
fairly resource intensive, since every line of tags_blacklist will need to be read and compared.
It is recommended that tags_blacklist be used minimally, and only by an administrator with an
understanding of regular expression syntax and performance.

So the best way to think about the different tables is that they are each tailored to a certain
use.  Note that tags_approval and tags_index do not rely on the user's borrower mapping, so
the tag population can continue to grow even if a user (along with their corresponding
rows in tags_all) is removed.  

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

Then, take those numbers and type/pipe them into this perl command line:
perl -ne 'use C4::Tags qw(get_tags add_tag); use Data::Dumper;chomp; add_tag($_,"health",51,1); print Dumper get_tags({limit=>5,term=>"health",});'

Note, the borrowernumber in this example is 51.  Use your own or any arbitrary valid borrowernumber.

=cut

