package Koha::List::Patron;

# Copyright 2013 ByWater Solutions
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

=head1 NAME

Koha::List::Patron - Management of lists of patrons

=head1 FUNCTIONS

=cut

use Modern::Perl;

use Carp;

use Koha::Database;

use base 'Exporter';
our @EXPORT = (
    qw(
      GetPatronLists

      DelPatronList
      AddPatronList
      ModPatronList

      AddPatronsToList
      DelPatronsFromList
      )
);

=head2 GetPatronLists

    my @lists = GetPatronLists( $params );

    Returns an array of lists created by the the given user
    or the logged in user if none is passed in.
=cut

sub GetPatronLists {
    my ($params) = @_;

    $params->{owner} ||= C4::Context->userenv->{'number'};

    unless ( $params->{owner} ) {
        carp("No owner passed in or defined!");
        return;
    }

    delete $params->{owner} if C4::Context->IsSuperLibrarian();

    if ( my $owner = $params->{owner} ) {
        delete $params->{owner};
        $params->{'-or'} = [
            owner => $owner,
            shared => 1,
        ];
    }

    my $schema = Koha::Database->new()->schema();

    my @patron_lists = $schema->resultset('PatronList')->search($params);

    return wantarray() ? @patron_lists : \@patron_lists;
}

=head2 DelPatronList

    DelPatronList( { patron_list_id => $list_id [, owner => $owner ] } );

=cut

sub DelPatronList {
    my ($params) = @_;

    $params->{owner} ||= C4::Context->userenv->{'number'};

    unless ( $params->{patron_list_id} ) {
        croak("No patron list id passed in!");
    }
    unless ( $params->{owner} ) {
        carp("No owner passed in or defined!");
        return;
    }

    delete( $params->{owner} ) if ( C4::Context->IsSuperLibrarian() );

    return Koha::Database->new()->schema()->resultset('PatronList')
      ->search($params)->single()->delete();
}

=head2 AddPatronList

    AddPatronList( { name => $name [, owner => $owner ] } );

=cut

sub AddPatronList {
    my ($params) = @_;

    $params->{owner} ||= C4::Context->userenv->{'number'};

    unless ( $params->{owner} ) {
        carp("No owner passed in or defined!");
        return;
    }

    unless ( $params->{name} ) {
        carp("No list name passed in!");
        return;
    }

    return Koha::Database->new()->schema()->resultset('PatronList')
      ->create($params);
}

=head2 ModPatronList

    ModPatronList( { patron_list_id => $id, name => $name [, owner => $owner ] } );

=cut

sub ModPatronList {
    my ($params) = @_;

    unless ( $params->{patron_list_id} ) {
        carp("No patron list id passed in!");
        return;
    }

    my ($list) = GetPatronLists(
        {
            patron_list_id => $params->{patron_list_id},
            owner          => $params->{owner}
        }
    );

    return $list->update($params);
}

=head2 AddPatronsToList

    AddPatronsToList({ list => $list, cardnumbers => \@cardnumbers });

=cut

sub AddPatronsToList {
    my ($params) = @_;

    my $list            = $params->{list};
    my $cardnumbers     = $params->{'cardnumbers'};
    my $borrowernumbers = $params->{'borrowernumbers'};

    return unless ( $list && ( $cardnumbers || $borrowernumbers ) );

    my @borrowernumbers;

    if ($cardnumbers) {
        @borrowernumbers =
          Koha::Database->new()->schema()->resultset('Borrower')->search(
            { cardnumber => { 'IN' => $cardnumbers } },
            { columns    => [qw/ borrowernumber /] }
          )->get_column('borrowernumber')->all();
    }
    else {
        @borrowernumbers = @$borrowernumbers;
    }

    my $patron_list_id = $list->patron_list_id();

    my $plp_rs = Koha::Database->new()->schema()->resultset('PatronListPatron');

    my @results;
    foreach my $borrowernumber (@borrowernumbers) {
        my $result = $plp_rs->update_or_create(
            {
                patron_list_id => $patron_list_id,
                borrowernumber => $borrowernumber
            }
        );
        push( @results, $result );
    }

    return wantarray() ? @results : \@results;
}

=head2 DelPatronsFromList

    DelPatronsFromList({ list => $list, patron_list_patrons => \@patron_list_patron_ids });

=cut

sub DelPatronsFromList {
    my ($params) = @_;

    my $list                = $params->{list};
    my $patron_list_patrons = $params->{patron_list_patrons};

    return unless ( $list && $patron_list_patrons );

    return Koha::Database->new()->schema()->resultset('PatronListPatron')
      ->search( { patron_list_patron_id => { 'IN' => $patron_list_patrons } } )
      ->delete();
}

=head1 AUTHOR

Kyle M Hall, E<lt>kyle@bywatersolutions.comE<gt>

=cut

1;

__END__
