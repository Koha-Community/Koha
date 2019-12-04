package Koha::REST::V1::AdvancedEditorMacro;

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

use Modern::Perl;

use Mojo::Base 'Mojolicious::Controller';
use Koha::AdvancedEditorMacros;

use Try::Tiny;

=head1 API

=head2 Class Methods

=cut

=head3 list

Controller function that handles listing Koha::AdvancedEditorMacro objects

=cut

sub list {
    my $c = shift->openapi->valid_input or return;
    my $patron = $c->stash('koha.user');
    return try {
        my $macros_set = Koha::AdvancedEditorMacros->search({ -or => { shared => 1, borrowernumber => $patron->borrowernumber } });
        my $macros = $c->objects->search( $macros_set, \&_to_model, \&_to_api );
        return $c->render( status => 200, openapi => $macros );
    }
    catch {
        if ( $_->isa('DBIx::Class::Exception') ) {
            return $c->render( status  => 500,
                               openapi => { error => $_->{msg} } );
        }
        else {
            return $c->render( status => 500,
                openapi => { error => "Something went wrong, check the logs. $_"} );
        }
    };

}

=head3 get

Controller function that handles retrieving a single Koha::AdvancedEditorMacro

=cut

sub get {
    my $c = shift->openapi->valid_input or return;
    my $patron = $c->stash('koha.user');
    my $macro = Koha::AdvancedEditorMacros->find({
        id => $c->validation->param('advancededitormacro_id'),
    });
    unless ($macro) {
        return $c->render( status  => 404,
                           openapi => { error => "Macro not found" } );
    }
    if( $macro->shared ){
        return $c->render( status => 403, openapi => {
            error => "This macro is shared, you must access it via advancededitormacros/shared"
        });
    }
    warn $macro->borrowernumber;
    warn $patron->borrowernumber;
    if( $macro->borrowernumber != $patron->borrowernumber ){
        return $c->render( status => 403, openapi => {
            error => "You do not have permission to access this macro"
        });
    }

    return $c->render( status => 200, openapi => $macro->to_api );
}

=head3 get_shared

Controller function that handles retrieving a single Koha::AdvancedEditorMacro

=cut

sub get_shared {
    my $c = shift->openapi->valid_input or return;
    my $patron = $c->stash('koha.user');
    my $macro = Koha::AdvancedEditorMacros->find({
        id => $c->validation->param('advancededitormacro_id'),
    });
    unless ($macro) {
        return $c->render( status  => 404,
                           openapi => { error => "Macro not found" } );
    }
    unless( $macro->shared ){
        return $c->render( status => 403, openapi => {
            error => "This macro is not shared, you must access it via advancededitormacros"
        });
    }
    return $c->render( status => 200, openapi => $macro->to_api );
}

=head3 add

Controller function that handles adding a new Koha::AdvancedEditorMacro object

=cut

sub add {
    my $c = shift->openapi->valid_input or return;

    if( defined $c->validation->param('body')->{shared} && $c->validation->param('body')->{shared} == 1 ){
        return $c->render( status  => 403,
                           openapi => { error => "To create shared macros you must use advancededitor/shared" } );
    }

    return try {
        my $macro = Koha::AdvancedEditorMacro->new( _to_model( $c->validation->param('body') ) );
        $macro->store;
        $c->res->headers->location( $c->req->url->to_string . '/' . $macro->id );
        return $c->render(
            status  => 201,
            openapi => $macro->to_api
        );
    }
    catch { handle_error($_) };
}

=head3 add_shared

Controller function that handles adding a new shared Koha::AdvancedEditorMacro object

=cut

sub add_shared {
    my $c = shift->openapi->valid_input or return;

    unless( defined $c->validation->param('body')->{shared} && $c->validation->param('body')->{shared} == 1 ){
        return $c->render( status  => 403,
                           openapi => { error => "To create private macros you must use advancededitor" } );
    }

    return try {
        my $macro = Koha::AdvancedEditorMacro->new( _to_model( $c->validation->param('body') ) );
        $macro->store;
        $c->res->headers->location( $c->req->url->to_string . '/' . $macro->id );
        return $c->render(
            status  => 201,
            openapi => $macro->to_api
        );
    }
    catch { handle_error($_) };
}

=head3 update

Controller function that handles updating a Koha::AdvancedEditorMacro object

=cut

sub update {
    my $c = shift->openapi->valid_input or return;

    my $macro = Koha::AdvancedEditorMacros->find( $c->validation->param('advancededitormacro_id') );

    if ( not defined $macro ) {
        return $c->render( status  => 404,
                           openapi => { error => "Object not found" } );
    }
    my $patron = $c->stash('koha.user');

    if( $macro->shared == 1 || defined $c->validation->param('body')->{shared} && $c->validation->param('body')->{shared} == 1 ){
        return $c->render( status  => 403,
                           openapi => { error => "To update a macro as shared you must use the advancededitormacros/shared endpoint" } );
    } else {
        unless ( $macro->borrowernumber == $patron->borrowernumber ){
            return $c->render( status  => 403,
                               openapi => { error => "You can only edit macros you own" } );
        }
    }

    return try {
        my $params = $c->req->json;
        $macro->set( _to_model($params) );
        $macro->store();
        return $c->render( status => 200, openapi => $macro->to_api );
    }
    catch { handle_error($_) };
}

=head3 update_shared

Controller function that handles updating a shared Koha::AdvancedEditorMacro object

=cut

sub update_shared {
    my $c = shift->openapi->valid_input or return;

    my $macro = Koha::AdvancedEditorMacros->find( $c->validation->param('advancededitormacro_id') );

    if ( not defined $macro ) {
        return $c->render( status  => 404,
                           openapi => { error => "Object not found" } );
    }

    unless( $macro->shared == 1 || defined $c->validation->param('body')->{shared} && $c->validation->param('body')->{shared} == 1 ){
        return $c->render( status  => 403,
                           openapi => { error => "You can only update shared macros using this endpoint" } );
    }

    return try {
        my $params = $c->req->json;
        $macro->set( _to_model($params) );
        $macro->store();
        return $c->render( status => 200, openapi => $macro->to_api );
    }
    catch { handle_error($_) };
}

=head3 delete

Controller function that handles deleting a Koha::AdvancedEditorMacro object

=cut

sub delete {
    my $c = shift->openapi->valid_input or return;

    my $macro = Koha::AdvancedEditorMacros->find( $c->validation->param('advancededitormacro_id') );
    if ( not defined $macro ) {
        return $c->render( status  => 404,
                           openapi => { error => "Object not found" } );
    }

    my $patron = $c->stash('koha.user');
    if( $macro->shared == 1 ){
        return $c->render( status  => 403,
                           openapi => { error => "You cannot delete shared macros using this endpoint" } );
    } else {
        unless ( $macro->borrowernumber == $patron->borrowernumber ){
            return $c->render( status  => 403,
                               openapi => { error => "You can only delete macros you own" } );
        }
    }

    return try {
        $macro->delete;
        return $c->render( status => 200, openapi => "" );
    }
    catch { handle_error($_) };
}

=head3 delete_shared

Controller function that handles deleting a shared Koha::AdvancedEditorMacro object

=cut

sub delete_shared {
    my $c = shift->openapi->valid_input or return;

    my $macro = Koha::AdvancedEditorMacros->find( $c->validation->param('advancededitormacro_id') );
    if ( not defined $macro ) {
        return $c->render( status  => 404,
                           openapi => { error => "Object not found" } );
    }

    unless( $macro->shared == 1 ){
        return $c->render( status  => 403,
                           openapi => { error => "You can only delete shared macros using this endpoint" } );
    }

    return try {
        $macro->delete;
        return $c->render( status => 200, openapi => "" );
    }
    catch { handle_error($_,$c) };
}

=head3 _handle_error

Helper function that passes exception or error

=cut

sub _handle_error {
    my ($err,$c) = @_;
    if ( $err->isa('DBIx::Class::Exception') ) {
        return $c->render( status  => 500,
                           openapi => { error => $err->{msg} } );
    }
    else {
        return $c->render( status => 500,
            openapi => { error => "Something went wrong, check the logs."} );
    }
};


=head3 _to_api

Helper function that maps a hashref of Koha::AdvancedEditorMacro attributes into REST api
attribute names.

=cut

sub _to_api {
    my $macro = shift;

    # Rename attributes
    foreach my $column ( keys %{ $Koha::REST::V1::AdvancedEditorMacro::to_api_mapping } ) {
        my $mapped_column = $Koha::REST::V1::AdvancedEditorMacro::to_api_mapping->{$column};
        if (    exists $macro->{ $column }
             && defined $mapped_column )
        {
            # key /= undef
            $macro->{ $mapped_column } = delete $macro->{ $column };
        }
        elsif (    exists $macro->{ $column }
                && !defined $mapped_column )
        {
            # key == undef => to be deleted
            delete $macro->{ $column };
        }
    }

    return $macro;
}

=head3 _to_model

Helper function that maps REST api objects into Koha::AdvancedEditorMacros
attribute names.

=cut

sub _to_model {
    my $macro = shift;

    foreach my $attribute ( keys %{ $Koha::REST::V1::AdvancedEditorMacro::to_model_mapping } ) {
        my $mapped_attribute = $Koha::REST::V1::AdvancedEditorMacro::to_model_mapping->{$attribute};
        if (    exists $macro->{ $attribute }
             && defined $mapped_attribute )
        {
            # key /= undef
            $macro->{ $mapped_attribute } = delete $macro->{ $attribute };
        }
        elsif (    exists $macro->{ $attribute }
                && !defined $mapped_attribute )
        {
            # key == undef => to be deleted
            delete $macro->{ $attribute };
        }
    }

    if ( exists $macro->{shared} ) {
        $macro->{shared} = ($macro->{shared}) ? 1 : 0;
    }


    return $macro;
}

=head2 Global variables

=head3 $to_api_mapping

=cut

our $to_api_mapping = {
    id                  => 'macro_id',
    macro               => 'macro_text',
    borrowernumber      => 'patron_id',
};

=head3 $to_model_mapping

=cut

our $to_model_mapping = {
    macro_id         => 'id',
    macro_text       => 'macro',
    patron_id        => 'borrowernumber',
};

1;
