package C4::NewsChannels;

# Copyright 2000-2002 Katipo Communications
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

use C4::Context;
use C4::Dates qw(format_date);

use vars qw($VERSION @ISA @EXPORT);

BEGIN { 
	$VERSION = 3.01;	# set the version for version checking
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

sub add_opac_new {
    my ($title, $new, $lang, $expirationdate, $timestamp, $number) = @_;
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("INSERT INTO opac_news (title, new, lang, expirationdate, timestamp, number) VALUES (?,?,?,?,?,?)");
    $sth->execute($title, $new, $lang, $expirationdate, $timestamp, $number);
    $sth->finish;
    return 1;
}

sub upd_opac_new {
    my ($idnew, $title, $new, $lang, $expirationdate, $timestamp,$number) = @_;
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("
        UPDATE opac_news SET 
            title = ?,
            new = ?,
            lang = ?,
            expirationdate = ?,
            timestamp = ?,
            number = ?
        WHERE idnew = ?
    ");
    $sth->execute($title, $new, $lang, $expirationdate, $timestamp,$number,$idnew);
    $sth->finish;
    return 1;
}

sub del_opac_new {
    my ($ids) = @_;
    if ($ids) {
        my $dbh = C4::Context->dbh;
        my $sth = $dbh->prepare("DELETE FROM opac_news WHERE idnew IN ($ids)");
        $sth->execute();
        $sth->finish;
        return 1;
    } else {
        return 0;
    }
}

sub get_opac_new {
    my ($idnew) = @_;
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("SELECT * FROM opac_news WHERE idnew = ?");
    $sth->execute($idnew);
    my $data = $sth->fetchrow_hashref;
    $data->{$data->{'lang'}} = 1 if defined $data->{lang};
    $data->{expirationdate} = format_date($data->{expirationdate});
    $data->{timestamp}      = format_date($data->{timestamp});
    $sth->finish;
    return $data;
}

sub get_opac_news {
    my ($limit, $lang) = @_;
    my $dbh = C4::Context->dbh;
    my $query = "SELECT *, timestamp AS newdate FROM opac_news";
    if ($lang) {
        $query.= " WHERE lang = '" .$lang ."' ";
    }
    $query.= " ORDER BY timestamp DESC ";
    #if ($limit) {
    #    $query.= "LIMIT 0, " . $limit;
    #}
    my $sth = $dbh->prepare($query);
    $sth->execute();
    my @opac_news;
    my $count = 0;
    while (my $row = $sth->fetchrow_hashref) {
        if ((($limit) && ($count < $limit)) || (!$limit)) {
            $row->{'newdate'} = format_date($row->{'newdate'});
            $row->{'expirationdate'} = format_date($row->{'expirationdate'});
            push @opac_news, $row;
        }
        $count++;
    }
    return ($count, \@opac_news);
}

=head2 GetNewsToDisplay

    $news = &GetNewsToDisplay($lang);
    C<$news> is a ref to an array which containts
    all news with expirationdate > today or expirationdate is null.

=cut

sub GetNewsToDisplay {
    my $lang = shift;
    my $dbh = C4::Context->dbh;
    # SELECT *,DATE_FORMAT(timestamp, '%d/%m/%Y') AS newdate
    my $query = "
     SELECT *,timestamp AS newdate
     FROM   opac_news
     WHERE   (
        expirationdate >= CURRENT_DATE()
        OR    expirationdate IS NULL
        OR    expirationdate = '00-00-0000'
      )
      AND   `timestamp` <= CURRENT_DATE()
      AND   lang = ?
      ORDER BY number
    ";				# expirationdate field is NOT in ISO format?
    my $sth = $dbh->prepare($query);
    $sth->execute($lang);
    my @results;
    while ( my $row = $sth->fetchrow_hashref ){
		$row->{newdate} = format_date($row->{newdate});
        push @results, $row;
    }
    return \@results;
}

1;
__END__

=head1 AUTHOR

TG

=cut
