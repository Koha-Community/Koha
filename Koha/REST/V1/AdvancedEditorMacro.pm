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
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use Mojo::Base 'Mojolicious::Controller';
use Koha::AdvancedEditorMacros;

use Try::Tiny qw( catch try );

=head1 Name

Koha::REST::V1::AdvancedEditorMacro

=head1 API

=head2 Methods

=head3 list

Controller function that handles listing Koha::AdvancedEditorMacro objects

=cut

sub list {
    my $c = shift->openapi->valid_input or return;
    my $patron = $c->stash('koha.user');
    return try {
        my $macros_set = Koha::AdvancedEditorMacros->search(
            {
                -or =>
                  { shared => 1, borrowernumber => $patron->borrowernumber }
            }
        );
        my $macros = $c->objects->search( $macros_set );
        return $c->render(
            status  => 200,
            openapi => $macros
        );
    }
    catch {
        $c->unhandled_exception($_);
    };

}

=head3 get

Controller function that handles retrieving a single Koha::AdvancedEditorMacro

=cut

sub get {
    my $c = shift->openapi->valid_input or return;
    my $patron = $c->stash('koha.user');
    my $macro  = Koha::AdvancedEditorMacros->find( $c->param('advancededitormacro_id') );
    unless ($macro) {
        return $c->render(
            status  => 404,
            openapi => { error => "Macro not found" }
        );
    }
    if( $macro->shared ){
        return $c->render( status => 403, openapi => {
            error => "This macro is shared, you must access it via advanced_editor/macros/shared"
        });
    }
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
        id => $c->param('advancededitormacro_id'),
    });
    unless ($macro) {
        return $c->render( status  => 404,
                           openapi => { error => "Macro not found" } );
    }
    unless( $macro->shared ){
        return $c->render( status => 403, openapi => {
            error => "This macro is not shared, you must access it via advanced_editor/macros"
        });
    }
    return $c->render( status => 200, openapi => $macro->to_api );
}

=head3 add

Controller function that handles adding a new Koha::AdvancedEditorMacro object

=cut

sub add {
    my $c = shift->openapi->valid_input or return;

    my $body = $c->req->json;

    if( defined $body->{shared} && $body->{shared} == 1 ){
        return $c->render( status  => 403,
                           openapi => { error => "To create shared macros you must use advancededitor/shared" } );
    }

    return try {
        my $macro = Koha::AdvancedEditorMacro->new_from_api( $body );
        $macro->store->discard_changes;
        $c->res->headers->location( $c->req->url->to_string . '/' . $macro->id );
        return $c->render(
            status  => 201,
            openapi => $macro->to_api
        );
    }
    catch {
        $c->unhandled_exception($_);
    };
}

=head3 add_shared

Controller function that handles adding a new shared Koha::AdvancedEditorMacro object

=cut

sub add_shared {
    my $c = shift->openapi->valid_input or return;

    my $body = $c->req->json;

    unless( defined $body->{shared} && $body->{shared} == 1 ){
        return $c->render( status  => 403,
                           openapi => { error => "To create private macros you must use advancededitor" } );
    }
    return try {
        my $macro = Koha::AdvancedEditorMacro->new_from_api( $body );
        $macro->store->discard_changes;
        $c->res->headers->location( $c->req->url->to_string . '/' . $macro->id );
        return $c->render(
            status  => 201,
            openapi => $macro->to_api
        );
    }
    catch {
        $c->unhandled_exception($_);
    };
}

=head3 update

Controller function that handles updating a Koha::AdvancedEditorMacro object

=cut

sub update {
    my $c = shift->openapi->valid_input or return;

    my $macro = Koha::AdvancedEditorMacros->find( $c->param('advancededitormacro_id') );

    if ( not defined $macro ) {
        return $c->render( status  => 404,
                           openapi => { error => "Object not found" } );
    }
    my $patron = $c->stash('koha.user');

    my $body = $c->req->json;

    if( $macro->shared == 1 || defined $body->{shared} && $body->{shared} == 1 ){
        return $c->render( status  => 403,
                           openapi => { error => "To update a macro as shared you must use the advanced_editor/macros/shared endpoint" } );
    } else {
        unless ( $macro->borrowernumber == $patron->borrowernumber ){
            return $c->render( status  => 403,
                               openapi => { error => "You can only edit macros you own" } );
        }
    }

    return try {
        $macro->set_from_api( $body );
        $macro->store->discard_changes;
        return $c->render( status => 200, openapi => $macro->to_api );
    }
    catch {
        $c->unhandled_exception($_);
    };
}

=head3 update_shared

Controller function that handles updating a shared Koha::AdvancedEditorMacro object

=cut

sub update_shared {
    my $c = shift->openapi->valid_input or return;

    my $macro = Koha::AdvancedEditorMacros->find( $c->param('advancededitormacro_id') );

    my $body = $c->req->json;

    if ( not defined $macro ) {
        return $c->render( status  => 404,
                           openapi => { error => "Object not found" } );
    }

    unless( $macro->shared == 1 || defined $body->{shared} && $body->{shared} == 1 ){
        return $c->render( status  => 403,
                           openapi => { error => "You can only update shared macros using this endpoint" } );
    }

    return try {
        $macro->set_from_api( $body );
        $macro->store->discard_changes;
        return $c->render( status => 200, openapi => $macro->to_api );
    }
    catch {
        $c->unhandled_exception($_);
    };
}

=head3 delete

Controller function that handles deleting a Koha::AdvancedEditorMacro object

=cut

sub delete {
    my $c = shift->openapi->valid_input or return;

    my $macro = Koha::AdvancedEditorMacros->find( $c->param('advancededitormacro_id') );
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
        return $c->render( status => 204, openapi => q{} );
    }
    catch {
        $c->unhandled_exception($_);
    };
}

=head3 delete_shared

Controller function that handles deleting a shared Koha::AdvancedEditorMacro object

=cut

sub delete_shared {
    my $c = shift->openapi->valid_input or return;

    my $macro = Koha::AdvancedEditorMacros->find( $c->param('advancededitormacro_id') );
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
        return $c->render( status => 204, openapi => q{} );
    }
    catch {
        $c->unhandled_exception($_);
    };
}

1;
