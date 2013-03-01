package Koha::Linktracker;

# Copyright 2013 chris@bigballofwax.co.nz
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

=head1 NAME

Koha::Linktracker

=head1 SYNOPSIS

  use Koha::Linktracker;
  my $tracker = Koha::Linktracker->new();
  $tracker->trackclick( $linkinfo );

=head1 FUNCTIONS

=cut

use Modern::Perl;
use Carp;
use C4::Context;
use base qw(Class::Accessor);

__PACKAGE__->mk_accessors(qw( trackingmethod ));

sub trackclick {
    my ( $self, $linkinfo ) = @_;
    my $dbh   = C4::Context->dbh();
    my $query = "INSERT INTO linktracker (biblionumber,itemnumber,borrowernumber
                    ,url,timeclicked) VALUES (?,?,?,?,now())";
    my $sth = $dbh->prepare($query);
    $sth->execute(
        $linkinfo->{biblionumber},   $linkinfo->{itemnumber},
        $linkinfo->{borrowernumber}, $linkinfo->{uri}
    );

}

=head2 EXPORT

None by default.


=head1 AUTHOR

Chris Cormack, E<lt>chris@bigballofwax.co.nzE<gt>

=cut

1;

__END__
