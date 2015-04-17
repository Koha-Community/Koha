package C4::SocialData;

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
use Business::ISBN;
use C4::Koha;

=head1 NAME

C4::SocialData - Koha functions for dealing with social datas
For now used by babeltheque, a french company providing, for books, comments, upload of videos, scoring (star)...
the social_data table could be used and improved by other provides.

=head1 SYNOPSIS

use C4::SocialData;

=head1 DESCRIPTION

The functions in this module deal with social datas

=head1 FUNCTIONS

=head2 get_data

Get social data from a biblio

params:
  $isbn = isbn of the biblio (it must be the same in your database, isbn given to babelio)

returns:
  this function returns an hashref with keys

  isbn = isbn
  num_critics = number of critics
  num_critics_pro = number of profesionnal critics
  num_quotations = number of quotations
  num_videos = number of videos
  score_avg = average score
  num_scores = number of score
=cut

sub get_data {
    my ( $isbn ) = @_;
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare( qq{SELECT * FROM social_data WHERE isbn = ? LIMIT 1} );
    $sth->execute( $isbn );
    my $results = $sth->fetchrow_hashref;

    return $results;
}

=head2 update_data

Update Social data

params:
  $url = url containing csv file with data

data separator : ; (semicolon)
data order : isbn ; active ; critics number , critics pro number ; quotations number ; videos number ; average score ; scores number

=cut

sub update_data {
    my ( $output_filepath ) = @_;

    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare( qq{INSERT INTO social_data (
            `isbn`, `num_critics`, `num_critics_pro`, `num_quotations`, `num_videos`, `score_avg`, `num_scores`
        ) VALUES ( ?, ?, ?, ?, ?, ?, ? )
        ON DUPLICATE KEY UPDATE `num_critics`=?, `num_critics_pro`=?, `num_quotations`=?, `num_videos`=?, `score_avg`=?, `num_scores`=?
    } );

    open my $file, '<', $output_filepath or die "File $output_filepath can not be read";
    my $sep = qq{;};
    my $i = 0;
    my $unknown = 0;
    while ( my $line = <$file> ) {
        my ( $isbn, $active, $num_critics, $num_critics_pro, $num_quotations, $num_videos, $score_avg, $num_scores ) = split $sep, $line;
        next if not $active;
        eval {
            $sth->execute( $isbn, $num_critics, $num_critics_pro, $num_quotations, $num_videos, $score_avg, $num_scores,
                $num_critics, $num_critics_pro, $num_quotations, $num_videos, $score_avg, $num_scores
            );
        };
        if ( $@ ) {
            warn "Can't insert $isbn ($@)";
        } else {
            $i++;
        }
    }
    say "$i data insered or updated";
}

=head2 get_report

Get social data report

=cut

sub get_report {
    my $dbh = C4::Context->dbh;

    my $sth = $dbh->prepare( qq{
        SELECT biblionumber, isbn FROM biblioitems
    } );
    $sth->execute;
    my %results;
    while ( my ( $biblionumber, $isbn ) = $sth->fetchrow() ) {
        push @{ $results{no_isbn} }, { biblionumber => $biblionumber } and next if not $isbn;
        my $original_isbn = $isbn;
        $isbn =~ s/^\s*(\S*)\s*$/$1/;
        $isbn = GetNormalizedISBN( $isbn, undef, undef );
        $isbn = Business::ISBN->new( $isbn );
        next if not $isbn;
        eval{
            $isbn = $isbn->as_isbn13->as_string;
        };
        next if $@;
        $isbn =~ s/-//g;
        my $social_datas = C4::SocialData::get_data( $isbn );
        if ( $social_datas ) {
            push @{ $results{with} }, { biblionumber => $biblionumber, isbn => $isbn, original => $original_isbn };
        } else {
            push @{ $results{without} }, { biblionumber => $biblionumber, isbn => $isbn, original => $original_isbn };
        }
    }
    return \%results;
}

1;
