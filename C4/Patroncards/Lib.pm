package C4::Patroncards::Lib;

# Copyright 2009 Foundations Bible College.
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

use autouse 'Data::Dumper' => qw(Dumper);

use C4::Context;
use C4::Debug;

BEGIN {
    use version; our $VERSION = qv('3.07.00.049');
    use base qw(Exporter);
    our @EXPORT = qw(unpack_UTF8
                     text_alignment
                     leading
                     box
                     get_borrower_attributes
                     put_image
                     get_image
                     rm_image
    );
}

sub unpack_UTF8 {
    my ($str) = @_;
    my @UTF8 =  (unpack("U0U*", $str));
    my @HEX = map { sprintf '%2.2x', $_ } @UTF8;
    return \@HEX;
}

sub text_alignment {
    my ($origin_llx, $text_box_width, $text_llx, $string_width, $line, $alignment) = @_;
    my $Tw = 0;
    my $Tx = 0;
    if ($alignment eq 'J') {
        my $UTF82HEX = unpack_UTF8($line);
        my $space_count = 0;
        grep {$space_count++ if $_ eq '20'} @$UTF82HEX;
        $Tw = (($text_box_width - $text_llx) - $string_width) / $space_count;
        return $origin_llx, $Tw;
    }
    elsif ($alignment eq 'C') {
        my $center_margin = ($text_box_width / 2) + ($origin_llx - $text_llx);
        $Tx = $center_margin - ($string_width / 2);
        return $Tx, $Tw;
    }
    elsif ($alignment eq 'R') {
        $Tx = ($text_box_width - $string_width) + (($origin_llx - $text_llx) / 2);
        return $Tx, $Tw;
    }
    elsif ($alignment eq 'L') {
        return $origin_llx, $Tw;
    }
    else {      # if we are not handed an alignment default to left align text...
        return $origin_llx, $Tw;
    }
}

sub leading {
    return $_[0] + ($_[0] * 0.20);      # recommended starting point for leading is 20% of the font point size  (See http://www.bastoky.com/KeyRelations.htm)
}

sub box {
    my ($llx, $lly, $width, $height, $pdf) = @_;
    my $obj_stream = "q\n";                            # save the graphic state
    $obj_stream .= "0.5 w\n";                          # border line width
    $obj_stream .= "1.0 0.0 0.0  RG\n";                # border color red
    $obj_stream .= "1.0 1.0 1.0  rg\n";                # fill color white
    $obj_stream .= "$llx $lly $width $height re\n";    # a rectangle
    $obj_stream .= "B\n";                              # fill (and a little more)
    $obj_stream .= "Q\n";                              # restore the graphic state
    $pdf->Add($obj_stream);
}

sub get_borrower_attributes {
    my ($borrower_number, @fields) = @_;
    my $get_branch = 0;
    $get_branch = 1 if grep{$_ eq 'branchcode'} @fields;
    my $attrib_count = scalar(@fields);
    my $query = "SELECT ";
    while (scalar(@fields)) {
        $query .= shift(@fields);
        $query .= ', ' if scalar(@fields);
    }
    $query .= " FROM borrowers WHERE borrowernumber = ?";
    my $sth = C4::Context->dbh->prepare($query);
#    $sth->{'TraceLevel'} = 3;
    $sth->execute($borrower_number);
    if ($sth->err) {
        warn sprintf('Database returned the following error: %s', $sth->errstr);
        return 1;
    }
    my $borrower_attributes = $sth->fetchrow_hashref();
    if ($get_branch) {
        $query = "SELECT branchname FROM branches WHERE branchcode = ?";
        $sth = C4::Context->dbh->prepare($query);
        $sth->execute($borrower_attributes->{'branchcode'});
        if ($sth->err) {
            warn sprintf('Database returned the following error: %s', $sth->errstr);
            return 1;
        }
        $borrower_attributes->{'branchcode'} = $sth->fetchrow_hashref()->{'branchname'};
    }
    return $borrower_attributes;
}

sub put_image {
    my ($image_name, $image_file) = @_;
    if (my $image_limit = C4::Context->preference('ImageLimit')) { # enforce quota if set
        my $query = "SELECT count(*) FROM creator_images;";
        my $sth = C4::Context->dbh->prepare($query);
        $sth->execute();
        if ($sth->err) {
            warn sprintf('Database returned the following error: %s', $sth->errstr);
            return 1;
        }
        return 202 if $sth->fetchrow_array >= $image_limit;
    }
    my$query = "INSERT INTO creator_images (imagefile, image_name) VALUES (?,?) ON DUPLICATE KEY UPDATE imagefile = ?;";
    my $sth = C4::Context->dbh->prepare($query);
    $sth->execute($image_file, $image_name, $image_file);
    if ($sth->err) {
        warn sprintf('Database returned the following error: %s', $sth->errstr);
        return 1;
    }
    return;
}

sub get_image {
    my ($image_name, $fields) = @_;
    $fields = '*' unless $fields;
    my $query = "SELECT $fields FROM creator_images";
    $query .= " WHERE image_name = ?" if $image_name;
    my $sth = C4::Context->dbh->prepare($query);
    if ($image_name) {
        $sth->execute($image_name);
    }
    else {
        $sth->execute();
    }
    if ($sth->err) {
        warn sprintf('Database returned the following error: %s', $sth->errstr);
        return 1;
    }
    return $sth->fetchall_arrayref({});
}

sub rm_image {
    my $image_ids = shift;
    my $errstr = ();
    foreach my $image_id (@$image_ids) {
        my $query = "DELETE FROM creator_images WHERE image_id = ?";
        my $sth = C4::Context->dbh->prepare($query);
        $sth->execute($image_id);
        if ($sth->err) {
            warn sprintf('Database returned the following error: %s', $sth->errstr);
            push (@$errstr, $image_id);
        }
    }
    if ($errstr) {
        return $errstr;
    }
    else {
        return;
    }
}

1;
__END__

=head1 NAME

C4::Patroncards::Lib - A shared library of linear functions used in the Patroncard Creator module in Koha

=head1 ABSTRACT

This library provides functions used by various sections of the Patroncard Creator module.

=head1 FUNCTIONS

=head2 C4::Patroncards::Lib::unpack_UTF8()

    This function returns a reference to an array of hex values equivelant to the utf8 values of the string passed in. This assumes, of course, that the string is
    indeed utf8.

    example:

        my $hex = unpack_UTF8($str);

=cut

=head2 C4::Patroncards::Lib::text_alignment()

    This function returns $Tx and $Tw values for the supplied text alignment. It accepts six parameters:

    C<origin_llx>       = the x value for the origin of the text box to align text in
    C<text_box_width>   = the width in postscript points of the text box
    C<text_llx>         = the x value for the lower left point of the text to align
    C<string_width>     = the width in postscript points of the string of text to align
    C<line>             = the line of text to align (this may be set to 'undef' for all alignment types except 'Justify')
    C<alignment>        = the type of text alignment desired:

    =item .
    B<L>        Left align
    =item .
    B<C>        Center align
    =item .
    B<R>        Right align
    =item .
    B<J>        Justify

    example:

        my ($Tx, $Tw)  = text_alignment($origin_llx, $text_box_width, $text_llx, $string_width, $line, $alignment);

=cut

=head2 C4::Patroncards::Lib::leading()

    This function accepts a single parameter, font postscript point size, and returns the ammount of leading to be added.

    example:

        my $leading = leading($font_size);

=cut

=head2 C4::Patroncards::Lib::box()

    This function will create and insert a "guide box" into the supplied pdf object. It accepts five arguments:

    C<llx>      = the x value of the lower left coordinate of the guide box
    C<lly>      = the y value of the lower left coordinate of the guide box
    C<width>    = the width of the guide box
    C<height>   = the height of the guide box
    C<pdf>      = the pdf object into which to insert the guide box


    example:

        box($llx, $lly, $width, $height, $pdf);

=cut

=head1 AUTHOR

Chris Nighswonger <cnighswonger AT foundations DOT edu>

=head1 COPYRIGHT

Copyright 2009 Foundations Bible College.

=head1 LICENSE

This file is part of Koha.

Koha is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software
Foundation; either version 2 of the License, or (at your option) any later version.

You should have received a copy of the GNU General Public License along with Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
Suite 330, Boston, MA  02111-1307 USA

=head1 DISCLAIMER OF WARRANTY

Koha is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

=cut
