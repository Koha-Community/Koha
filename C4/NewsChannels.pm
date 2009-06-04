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

use C4::Context;
use C4::Dates qw(format_date);

use vars qw($VERSION @ISA @EXPORT);

BEGIN { 
	$VERSION = 3.01;	# set the version for version checking
	@ISA = qw(Exporter);
	@EXPORT = qw(
		&GetNewsToDisplay
		&news_channels &get_new_channel &del_channels &add_channel &update_channel
		&news_channels_categories &get_new_channel_category &del_channels_categories
		&add_channel_category &update_channel_category &news_channels_by_category
		&add_opac_new &upd_opac_new &del_opac_new &get_opac_new &get_opac_news
		&add_opac_electronic &upd_opac_electronic &del_opac_electronic &get_opac_electronic &get_opac_electronics
	);
}

=head1 NAME

C4::NewsChannels - Functions to manage the news channels and its categories

=head1 DESCRIPTION

This module provides the functions needed to admin the news channels and its categories

=head1 FUNCTIONS

=head2 news_channels

  ($count, @channels) = &news_channels($channel_name, $id_category, $unclassified);

Looks up news channels by name or category.

C<$channel_name> is the channel name to search.

C<$id_category> is the channel category code to search.

C<$$unclassified> if it is set and $channel_name and $id_category search for the news channels without a category

if none of the params are set C<&news_channels> returns all the news channels.

C<&news_channels> returns two values: an integer giving the number of
news channels found and a reference to an array
of references to hash, which has the news_channels and news_channels_categories fields.

=cut

sub news_channels {
    my ($channel_name, $id_category, $unclassified) = @_;
    my $dbh = C4::Context->dbh;
    my @channels;
    my $query = "SELECT * FROM news_channels LEFT JOIN news_channels_categories ON news_channels.id_category = news_channels_categories.id_category";
    if ( ($channel_name ne '') && ($id_category ne '') ) {
        $query.= " WHERE channel_name like '" . $channel_name . "%' AND news_channels.id_category = " . $id_category;
    } elsif ($channel_name ne '')  {
        $query.= " WHERE channel_name like '" . $channel_name . "%'";
    } elsif ($id_category ne '') {
        $query.= " WHERE news_channels.id_category = " . $id_category;
    } elsif ($unclassified) {
        $query.= " WHERE news_channels.id_category IS NULL ";
    }
    my $sth = $dbh->prepare($query);
    $sth->execute();
    while (my $row = $sth->fetchrow_hashref) {
        push @channels, $row;
    }
    $sth->finish;
    return (scalar(@channels), @channels);
}

=head2 news_channels_by_category

  ($count, @results) = &news_channels_by_category();

Looks up news channels grouped by category.

C<&news_channels_by_category> returns two values: an integer giving the number of
categories found and a reference to an array
of references to hash, which the following keys: 

=over 4

=item C<channels_count>

The number of news channels in that category

=item C<channels>

A reference to an array of references to hash which keys are the new_channels fields. 

Additionally the last index of results has a reference to all the news channels which don't have a category 

=back

=cut

sub news_channels_by_category {
    
    my ($categories_count, @results) = &news_channels_categories();
    foreach my $row (@results) {

        my ($channels_count, @channels) = &news_channels('', $row->{'id_category'});
        $row->{'channels_count'} = $channels_count;
        $row->{'channels'} = \@channels;
    }

    my ($channels_count, @channels) = &news_channels('', '', 1);
    my %row;
    $row{'id_category'} = -1;
    $row{'unclassified'} = 1;
    $row{'channels_count'} = $channels_count;
    $row{'channels'} = \@channels;
    push @results, \%row;

    return (scalar(@results), @results);
}

sub get_new_channel {
    my ($id) = @_;
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("SELECT * FROM news_channels WHERE id = ?");
    $sth->execute($id);
    my $channel = $sth->fetchrow_hashref;
    $sth->finish;
    return $channel;
}

sub del_channels {
    my ($ids) = @_;
    if ($ids ne '') {
        my $dbh = C4::Context->dbh;
        my $sth = $dbh->prepare("DELETE FROM news_channels WHERE id IN ($ids) ");
        $sth->execute();
        $sth->finish;
        return $ids;
    }
    return 0;
}

sub add_channel {
    my ($name, $url, $id_category, $notes) = @_;
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("INSERT INTO news_channels (channel_name, url, id_category, notes) VALUES (?,?,?,?)");
    $sth->execute($name, $url, $id_category, $notes);
    $sth->finish;
    return 1;
}

sub update_channel {
    my ($id, $name, $url, $id_category, $notes) = @_;
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("UPDATE news_channels SET channel_name = ?,  url = ?, id_category = ?, notes = ? WHERE id = ?");
    $sth->execute($name, $url, $id_category, $notes, $id);
    $sth->finish;
    return 1;
}

sub news_channels_categories {
    my $dbh = C4::Context->dbh;
    my @categories;
    my $query = "SELECT * FROM news_channels_categories";
    my $sth = $dbh->prepare($query);
    $sth->execute();
    while (my $row = $sth->fetchrow_hashref) {
        push @categories, $row;
    }
    $sth->finish;
    return (scalar(@categories), @categories);

}

sub get_new_channel_category {
    my ($id) = @_;
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("SELECT * FROM news_channels_categories WHERE id_category = ?");
    $sth->execute($id);
    my $category = $sth->fetchrow_hashref;
    $sth->finish;
    return $category;
}

sub del_channels_categories {
    my ($ids) = @_;
    if ($ids ne '') {
        my $dbh = C4::Context->dbh;
        my $sth = $dbh->prepare("UPDATE news_channels SET id_category = NULL WHERE id_category IN ($ids) ");
        $sth->execute();
        $sth = $dbh->prepare("DELETE FROM news_channels_categories WHERE id_category IN ($ids) ");
        $sth->execute();
        $sth->finish;
        return $ids;
    }
    return 0;
}

sub add_channel_category {
    my ($name) = @_;
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("INSERT INTO news_channels_categories (category_name) VALUES (?)");
    $sth->execute($name);
    $sth->finish;
    return 1;
}

sub update_channel_category {
    my ($id, $name) = @_;
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("UPDATE news_channels_categories SET category_name = ? WHERE id_category = ?");
    $sth->execute($name, $id);
    $sth->finish;
    return 1;
}

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
    $data->{$data->{'lang'}} = 1;
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

### get electronic databases

sub add_opac_electronic {
    my ($title, $edata, $lang,$image,$href,$section) = @_;
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("INSERT INTO opac_electronic (title, edata, lang,image,href,section) VALUES (?,?,?,?,?,?)");
    $sth->execute($title, $edata, $lang,$image,$href,$section);
    $sth->finish;
    return 1;
}

sub upd_opac_electronic {
    my ($idelectronic, $title, $edata, $lang, $image, $href,$section) = @_;
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("UPDATE opac_electronic SET title = ?, edata = ?, lang = ? , image=?, href=? ,section=? WHERE idelectronic = ?");
    $sth->execute($title, $edata, $lang, $image,$href ,$section, $idelectronic);
    $sth->finish;
    return 1;
}

sub del_opac_electronic {
    my ($ids) = @_;
    if ($ids) {
        my $dbh = C4::Context->dbh;
        my $sth = $dbh->prepare("DELETE FROM opac_electronic WHERE idelectronic IN ($ids)");
        $sth->execute();
        $sth->finish;
        return 1;
    } else {
        return 0;
    }
}

sub get_opac_electronic {
    my ($idelectronic) = @_;
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("SELECT * FROM opac_electronic WHERE idelectronic = ?");
    $sth->execute($idelectronic);
    my $data = $sth->fetchrow_hashref;
    $data->{$data->{'lang'}} = 1;
    $data->{$data->{'section'}} = 1;
    $sth->finish;
    return $data;
}

sub get_opac_electronics {
    my ($section, $lang) = @_;
    my $dbh = C4::Context->dbh;
    my $query = "SELECT *, DATE_FORMAT(timestamp, '%d/%m/%Y') AS newdate FROM opac_electronic";
    if ($lang) {
        $query.= " WHERE lang = '" .$lang ."' ";
    }
    if ($section) {
        $query.= " and section= '" . $section."' ";
    }
    $query.= " ORDER BY title ";
    
    my $sth = $dbh->prepare($query);
    $sth->execute();
    my @opac_electronic;
    my $count = 0;
    while (my $row = $sth->fetchrow_hashref) {
            push @opac_electronic, $row;
        $count++;
    }

    return ($count,\@opac_electronic);
}

1;
__END__

=head1 AUTHOR

TG

=cut
