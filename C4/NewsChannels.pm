package C4::NewsChannels;

# This file is part of Koha.
#
# Copyright (C) 2000-2002  Katipo Communications
# Copyright (C) 2013       Mark Tompsett
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
use Koha::DateUtils;
use C4::Log qw(logaction);
use Koha::News;

use vars qw(@ISA @EXPORT);

BEGIN { 
    @ISA = qw(Exporter);
    @EXPORT = qw(
        &GetNewsToDisplay
        &add_opac_new &upd_opac_new &del_opac_new &get_opac_new &get_opac_news
    );
}

=head1 NAME

C4::NewsChannels - Functions to manage OPAC and intranet news

=head1 DESCRIPTION

This module provides the functions needed to mange OPAC and intranet news.

=head1 FUNCTIONS

=cut

=head2 add_opac_new

    $retval = add_opac_new($hashref);

    $hashref should contains all the fields found in opac_news,
    except idnew. The idnew field is auto-generated.

=cut

sub add_opac_new {
    my ($href_entry) = @_;
    my $retval = 0;

    if ($href_entry) {
        $href_entry->{number} = 0 if $href_entry->{number} !~ /^\d+$/;
        my @fields = keys %{$href_entry};
        my @values = values %{$href_entry};
        my $field_string = join ',', @fields;
        $field_string = $field_string // q{};
        my $values_string = join(',', map { '?' } @fields);
        my $dbh = C4::Context->dbh;
        my $sth = $dbh->prepare("INSERT INTO opac_news ( $field_string ) VALUES ( $values_string )");
        $sth->execute(@values);
        $retval = 1;

        #Log new news entry
        if (C4::Context->preference("NewsLog")) {
                logaction('NEWS', 'ADD' , undef, $href_entry->{lang} . ' | ' . $href_entry->{content});
        }
    }
    return $retval;
}

=head2 upd_opac_new

    $retval = upd_opac_new($hashref);

    $hashref should contains all the fields found in opac_news,
    including idnew, since it is the key for the SQL UPDATE.

=cut

sub upd_opac_new {
    my ($href_entry) = @_;
    my $retval = 0;

    if ($href_entry) {
        $href_entry->{number} = 0 if $href_entry->{number} !~ /^\d+$/;
        # take the keys of hash entry and make a list, but...
        my @fields = keys %{$href_entry};
        my @values;
        $#values = -1;
        my $field_string = q{};
        foreach my $field_name (@fields) {
            # exclude idnew
            if ( $field_name ne 'idnew' ) {
                $field_string = $field_string . "$field_name = ?,";
                push @values,$href_entry->{$field_name};
            }
        }
        # put idnew at the end, so we know which record to update
        push @values,$href_entry->{'idnew'};
        chop $field_string; # remove that excess ,

        my $dbh = C4::Context->dbh;
        my $sth = $dbh->prepare("UPDATE opac_news SET $field_string WHERE idnew = ?;");
        $sth->execute(@values);
        $retval = 1;
    }

    #Log news entry modification
    if (C4::Context->preference("NewsLog")) {
            logaction('NEWS', 'MODIFY' , undef, $href_entry->{lang} . ' | ' . $href_entry->{content});
    }
    return $retval;
}

sub del_opac_new {
    my ($ids) = @_;
    if ($ids) {

        #Log news deletion
        if (C4::Context->preference("NewsLog")) {
            foreach my $newsid ( split(/,/, $ids )) {
                my $n = Koha::News->find( $newsid );
                logaction('NEWS', 'DELETE', undef, $n->unblessed->{lang} . ' | ' . $n->unblessed->{content} );
            }
        }

        my $dbh = C4::Context->dbh;
        my $sth = $dbh->prepare("DELETE FROM opac_news WHERE idnew IN ($ids)");
        $sth->execute();
        return 1;
    } else {
        return 0;
    }

}

sub get_opac_new {
    my ($idnew) = @_;
    my $dbh = C4::Context->dbh;
    my $query = q{
                  SELECT opac_news.*,branches.branchname
                  FROM opac_news LEFT JOIN branches
                      ON opac_news.branchcode=branches.branchcode
                  WHERE opac_news.idnew = ?;
                };
    my $sth = $dbh->prepare($query);
    $sth->execute($idnew);
    my $data = $sth->fetchrow_hashref;
    $data->{expirationdate} = output_pref({ dt => dt_from_string( $data->{expirationdate} ), dateonly => 1 }) if ( $data->{expirationdate} );
    $data->{published_on} = output_pref({ dt => dt_from_string( $data->{published_on} ), dateonly => 1 });
    return $data;
}

sub get_opac_news {
    my ($limit, $lang, $branchcode) = @_;
    my @values;
    my $dbh = C4::Context->dbh;
    my $query = q{
                  SELECT opac_news.*, branches.branchname,
                         published_on AS newdate,
                         borrowers.title AS author_title,
                         borrowers.firstname AS author_firstname,
                         borrowers.surname AS author_surname
                  FROM opac_news LEFT JOIN branches
                      ON opac_news.branchcode=branches.branchcode
                  LEFT JOIN borrowers on borrowers.borrowernumber = opac_news.borrowernumber
                };
    $query .= ' WHERE 1';
    if ($lang) {
        $query .= " AND (opac_news.lang='' OR opac_news.lang=?)";
        push @values,$lang;
    }
    if ($branchcode) {
        $query .= ' AND (opac_news.branchcode IS NULL OR opac_news.branchcode=?)';
        push @values,$branchcode;
    }
    $query.= ' ORDER BY published_on DESC ';
    #if ($limit) {
    #    $query.= 'LIMIT 0, ' . $limit;
    #}
    my $sth = $dbh->prepare($query);
    $sth->execute(@values);
    my @opac_news;
    my $count = 0;
    while (my $row = $sth->fetchrow_hashref) {
        if ((($limit) && ($count < $limit)) || (!$limit)) {
            push @opac_news, $row;
        }
        $count++;
    }
    return ($count, \@opac_news);
}

=head2 GetNewsToDisplay

    $news = &GetNewsToDisplay($lang,$branch);
    C<$news> is a ref to an array which contains
    all news with expirationdate > today or expirationdate is null
    that is applicable for a given branch.

=cut

sub GetNewsToDisplay {
    my ($lang,$branch) = @_;
    my $dbh = C4::Context->dbh;
    my $query = q{
     SELECT opac_news.*,published_on AS newdate,
     borrowers.title AS author_title,
     borrowers.firstname AS author_firstname,
     borrowers.surname AS author_surname
     FROM   opac_news
     LEFT JOIN borrowers on borrowers.borrowernumber = opac_news.borrowernumber
     WHERE   (
        expirationdate >= CURRENT_DATE()
        OR    expirationdate IS NULL
     )
     AND   published_on <= CURDATE()
     AND   (opac_news.lang = '' OR opac_news.lang = ?)
     AND   (opac_news.branchcode IS NULL OR opac_news.branchcode = ?)
     ORDER BY number
    };
    my $sth = $dbh->prepare($query);
    $lang = $lang // q{};
    $sth->execute($lang,$branch);
    my @results;
    while ( my $row = $sth->fetchrow_hashref ){
        $row->{newdate} = output_pref({ dt => dt_from_string( $row->{newdate} ), dateonly => 1 });
        push @results, $row;
    }
    return \@results;
}

1;
__END__

=head1 AUTHOR

TG

=cut
