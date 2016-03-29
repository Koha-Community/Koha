#!/usr/bin/perl

# Copyright 2002 paul.poulain@free.fr
# Copyright 2014 Rijksmuseum
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


# This script is used to maintain the Z3950 servers table.
# Parameter $op is operation: list, new, edit, add_validated, delete_confirmed.
# add_validated saves a validated record and goes to list view.
# delete_confirmed deletes a record and goes to list view.

use Modern::Perl;
use CGI qw ( -utf8 );
use C4::Context;
use C4::Auth;
use C4::Output;
use Koha::Database;

# Initialize CGI, template, database

my $input = new CGI;
my $op = $input->param('op') || 'list';
my $id = $input->param('id') || 0;
my $type = $input->param('type') || '';
my $searchfield = '';

my ( $template, $loggedinuser, $cookie ) = get_template_and_user( {
    template_name => "admin/z3950servers.tt",
    query => $input,
    type => "intranet",
    authnotrequired => 0,
    flagsrequired => {parameters => 'parameters_remaining_permissions'},
    debug => 1,
});
my $script_name = "/cgi-bin/koha/admin/z3950servers.pl";
$template->param( script_name => $script_name );

my $schema = Koha::Database->new()->schema();

# Main code
# First process a confirmed delete, or save a validated record

if( $op eq 'delete_confirmed' && $id ) {
    my $server = $schema->resultset('Z3950server')->find($id);
    if ( $server ) {
        $server->delete;
        $template->param( msg_deleted => 1, msg_add => $server->servername );
    } else {
        $template->param( msg_notfound => 1, msg_add => $id );
    }
    $id = 0;
} elsif ( $op eq 'add_validated' ) {
    my @fields=qw/host port db userid password rank syntax encoding timeout
        recordtype checked servername servertype sru_options sru_fields
        add_xslt/;
    my $formdata = _form_data_hashref( $input, \@fields );
    if( $id ) {
        my $server = $schema->resultset('Z3950server')->find($id);
        if ( $server ) {
            $server->update( $formdata );
            $template->param( msg_updated => 1, msg_add => $formdata->{servername} );
        } else {
            $template->param( msg_notfound => 1, msg_add => $id );
        }
        $id = 0;
    } else {
        $schema->resultset('Z3950server')->create( $formdata );
        $template->param( msg_added => 1, msg_add => $formdata->{servername} );
    }
} else {
    #use searchfield only in remaining operations
    $searchfield = $input->param('searchfield') || '';
}

# Now list multiple records, or edit one record

my $data = [];
if ( $op eq 'add' || $op eq 'edit' ) {
    $data = ServerSearch( $schema, $id, $searchfield ) if $searchfield || $id;
    delete $data->[0]->{id} if @$data && $op eq 'add'; #cloning record
    $template->param( add_form => 1, server => @$data? $data->[0]: undef,
        op => $op, type => $op eq 'add'? lc $type: '' );
} else {
    $data = ServerSearch( $schema, $id, $searchfield );
    $template->param( loop => \@$data, searchfield => $searchfield, id => $id,
        op => 'list' );
}
output_html_with_http_headers $input, $cookie, $template->output;

# End of main code

sub ServerSearch  { #find server(s) by id or name
    my ( $schema, $id, $searchstring )= @_;
    my $rs = $schema->resultset('Z3950server')->search(
        $id ? { id => $id }: { servername => { like => $searchstring.'%' } },
        { result_class => 'DBIx::Class::ResultClass::HashRefInflator' }
    );
    return [ $rs->all ];
}

sub _form_data_hashref {
    my ( $input, $fieldref ) = @_;
    return { map { ( $_ => scalar $input->param($_)//'' ) } @$fieldref };
}
