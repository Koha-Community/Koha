package C4::Query;

# Copyright 2004 Katipo Communications
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

# $Id$

use 5.006;
use strict;
use warnings;

require Exporter;
use AutoLoader qw(AUTOLOAD);

our @ISA = qw(Exporter);

our %EXPORT_TAGS = (
    'all' => [
        qw(

        )
    ]
);

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(

);

our $VERSION = do { my @v = '$Revision$' =~ /\d+/g;
    shift (@v) . "." . join ( "_", map { sprintf "%03d", $_ } @v );
};

# Preloaded methods go here.

sub new {
    my $class         = shift;
    my $search_string = shift;    # high level query to construct search from
    my $self          = {};
    $self->{"search_string"} = $search_string;
    bless $self, $class;
    return $self;
}

sub count {
    my $self = shift;

}

sub results {
    my $self = shift;

}

# Autoload methods go after =cut, and are processed by the autosplit program.

1;
__END__

# Below is stub documentation for your module. You better edit it!

=head1 NAME

C4::Query 

=head1 SYNOPSIS

  use C4::Query;


=head1 DESCRIPTION

=head2 METHODS

=item new

$query = new C4::Query("title:bob marley");



=head2 EXPORT

None by default.


=head1 AUTHOR

Koha Development Team

=head1 SEE ALSO

L<perl>.

=cut

