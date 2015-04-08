package C4::Category;

# Copyright 2009 Liblime
# Parts Copyright 2011 Tamil
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
use C4::Context;

our $AUTOLOAD;




=head1 NAME

C4::Category - objects from the categories table

=head1 SYNOPSIS

    use C4::Category;
    my @categories = C4::Category->all;
    print join("\n", map { $_->description } @categories), "\n";

=head1 DESCRIPTION

Objects of this class represent a row in the C<categories> table.

Currently, the bare minimum for using this as a read-only data source has
been implemented.  The API was designed to make it easy to transition to
an ORM later on.

=head1 API

=head2 Class Methods

=cut

=head3 C4::Category->new(\%opts)

Given a hashref, a new (in-memory) C4::Category object will be instantiated.
The database is not touched.

=cut

sub new {
    my ($class, $opts) = @_;
    bless $opts => $class;
}




=head3 C4::Category->all

This returns all the categories as objects.  By default they're ordered by
C<description>.

=cut

sub all {
    my ( $class ) = @_;
    my $branch_limit = C4::Context->userenv ? C4::Context->userenv->{"branch"} : "";
    my $dbh = C4::Context->dbh;
    # The categories table is small enough for
    # `SELECT *` to be harmless.
    my $query = "SELECT categories.* FROM categories";
    $query .= qq{
        LEFT JOIN categories_branches ON categories_branches.categorycode = categories.categorycode
        WHERE categories_branches.branchcode = ? OR categories_branches.branchcode IS NULL
    } if $branch_limit;
    $query .= " ORDER BY description";
    return map { $class->new($_) } @{
        $dbh->selectall_arrayref(
            $query,
            { Slice => {} },
            $branch_limit ? $branch_limit : ()
        )
    };
}




=head2 Object Methods

These are read-only accessors for attributes of a C4::Category object.

=head3 $category->categorycode

=cut

=head3 $category->description

=cut

=head3 $category->enrolmentperiod

=cut

=head3 $category->upperagelimit

=cut

=head3 $category->dateofbirthrequired

=cut

=head3 $category->finetype

=cut

=head3 $category->bulk

=cut

=head3 $category->enrolmentfee

=cut

=head3 $category->overduenoticerequired

=cut

=head3 $category->issuelimit

=cut

=head3 $category->reservefee

=cut

=head3 $category->category_type

=cut

sub AUTOLOAD {
    my $self = shift;
    my $attr = $AUTOLOAD;
    $attr =~ s/.*://;
    if (exists $self->{$attr}) {
        return $self->{$attr};
    } else {
        return undef;
    }
}

sub DESTROY { }




=head1 SEE ALSO

The following modules make reference to the C<categories> table.

L<C4::Members>, L<C4::Overdues>, L<C4::Reserves>


=head1 AUTHOR

John Beppu <john.beppu@liblime.com>

=cut

1;
