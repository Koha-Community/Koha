#!/usr/bin/perl

# Copyright 2000-2002 Katipo Communications
# Copyright 2015 Koha Development Team
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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use CGI       qw ( -utf8 );
use Try::Tiny qw( catch try );

use C4::Auth qw( get_template_and_user );
use C4::Context;
use C4::Output qw( output_html_with_http_headers );
use C4::Koha;

use Koha::AdditionalFields;
use Koha::Database;
use Koha::Patrons;
use Koha::Items;
use Koha::Libraries;
use Koha::SMTP::Servers;
use Koha::Library::Hours;

my $input        = CGI->new;
my $branchcode   = $input->param('branchcode');
my $categorycode = $input->param('categorycode');
my $op           = $input->param('op') || 'list';
my @messages;

my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name => "admin/branches.tt",
        query         => $input,
        type          => "intranet",
        flagsrequired => { parameters => 'manage_libraries' },
    }
);

my $library;
$library = Koha::Libraries->find($branchcode);
my @additional_fields = Koha::AdditionalFields->search( { tablename => 'branches' } )->as_list;
my @additional_field_values;
@additional_field_values = $library ? $library->get_additional_field_values_for_template : ();

$template->param(
    additional_fields       => \@additional_fields,
    additional_field_values => @additional_field_values,
);

if ( $op eq 'add_form' ) {
    $template->param(
        library      => $library,
        smtp_servers => Koha::SMTP::Servers->search,
    );
} elsif ( $branchcode && $op eq 'view' ) {
    $template->param(
        library => $library,
    );
} elsif ( $op eq 'cud-add_validate' ) {
    my @fields = qw(
        branchname
        branchaddress1
        branchaddress2
        branchaddress3
        branchzip
        branchcity
        branchstate
        branchcountry
        branchphone
        branchfax
        branchemail
        branchillemail
        branchreplyto
        branchreturnpath
        branchurl
        issuing
        branchip
        branchnotes
        marcorgcode
        pickup_location
        public
        opacuserjs
        opacusercss
    );
    my $is_a_modif = $input->param('is_a_modif');

    if ($is_a_modif) {
        for my $field (@fields) {
            if ( $field =~ /^(pickup_location|public)$/ ) {

                # Don't fallback to undef/NULL, default is 1 in DB
                $library->$field( scalar $input->param($field) );
            } else {
                $library->$field( scalar $input->param($field) || undef );
            }
        }

        try {
            Koha::Database->new->schema->txn_do(
                sub {
                    $library->store->discard_changes;

                    # Deal with SMTP server
                    my $smtp_server_id = $input->param('smtp_server');

                    if ($smtp_server_id) {
                        if ( $smtp_server_id eq '*' ) {
                            $library->smtp_server( { smtp_server => undef } );
                        } else {
                            my $smtp_server = Koha::SMTP::Servers->find($smtp_server_id);
                            Koha::Exceptions::BadParameter->throw( parameter => 'smtp_server' )
                                unless $smtp_server;
                            $library->smtp_server( { smtp_server => $smtp_server } );
                        }
                    }

                    # Deal with opening hours
                    my @days        = $input->multi_param("day");
                    my @open_times  = $input->multi_param("open_time");
                    my @close_times = $input->multi_param("close_time");

                    my $index = 0;
                    foreach my $day (@days) {
                        if ( $open_times[$index] !~ /([0-9]{2}:[0-9]{2})/ ) {
                            $open_times[$index] = undef;
                        }
                        if ( $close_times[$index] !~ /([0-9]{2}:[0-9]{2})/ ) {
                            $close_times[$index] = undef;
                        }

                        my $openday = Koha::Library::Hours->find( { library_id => $branchcode, day => $day } );
                        if ($openday) {
                            $openday->update(
                                { open_time => $open_times[$index], close_time => $close_times[$index] } );
                        } else {
                            $openday = Koha::Library::Hour->new(
                                {
                                    library_id => $branchcode, day => $day, open_time => $open_times[$index],
                                    close_time => $close_times[$index]
                                }
                            )->store;
                        }
                        $index++;
                    }

                    my @additional_fields =
                        Koha::Libraries->find($branchcode)->prepare_cgi_additional_field_values( $input, 'branches' );
                    Koha::Libraries->find($branchcode)->set_additional_fields( \@additional_fields );

                    push @messages, { type => 'message', code => 'success_on_update' };
                }
            );
        } catch {
            push @messages, { type => 'alert', code => 'error_on_update' };
        };
    } else {
        $branchcode =~ s|\s||g;
        $library = Koha::Library->new(
            {
                branchcode => $branchcode,
                (
                    map {
                        /^(pickup_location|public)$/    # Don't fallback to undef for those fields
                            ? ( $_ => scalar $input->param($_) )
                            : ( $_ => scalar $input->param($_) || undef )
                    } @fields
                )
            }
        );

        try {
            Koha::Database->new->schema->txn_do(
                sub {
                    $library->store->discard_changes;

                    my $smtp_server_id = $input->param('smtp_server');

                    # Deal with SMTP server
                    if ($smtp_server_id) {
                        if ( $smtp_server_id ne '*' ) {
                            my $smtp_server = Koha::SMTP::Servers->find($smtp_server_id);
                            Koha::Exceptions::BadParameter->throw( parameter => 'smtp_server' )
                                unless $smtp_server;
                            $library->smtp_server( { smtp_server => $smtp_server } );
                        }
                    }

                    # Deal with opening hours
                    my @days        = $input->multi_param("day");
                    my @open_times  = $input->multi_param("open_time");
                    my @close_times = $input->multi_param("close_time");

                    my $index = 0;
                    foreach my $day (@days) {
                        if ( $open_times[$index] !~ /([0-9]{2}:[0-9]{2})/ ) {
                            $open_times[$index] = undef;
                        }
                        if ( $close_times[$index] !~ /([0-9]{2}:[0-9]{2})/ ) {
                            $close_times[$index] = undef;
                        }

                        my $openday = Koha::Library::Hour->new(
                            {
                                library_id => $branchcode, day => $day, open_time => $open_times[$index],
                                close_time => $close_times[$index]
                            }
                        )->store;
                        $index++;
                    }

                    my @additional_fields = $library->prepare_cgi_additional_field_values( $input, 'branches' );
                    $library->set_additional_fields( \@additional_fields );

                    push @messages, { type => 'message', code => 'success_on_insert' };
                }
            );
        } catch {
            push @messages, { type => 'alert', code => 'error_on_insert' };
        };
    }
    $op = 'list';
} elsif ( $op eq 'delete_confirm' ) {
    my $items_count = Koha::Items->search(
        {
            -or => {
                holdingbranch => $branchcode,
                homebranch    => $branchcode
            },
        }
    )->count;
    my $patrons_count = Koha::Patrons->search( { branchcode => $branchcode, } )->count;

    if ( $items_count or $patrons_count ) {
        push @messages,
            {
            type => 'alert',
            code => 'cannot_delete_library',
            data => {
                items_count   => $items_count,
                patrons_count => $patrons_count,
            },
            };
        $op = 'list';
    } else {
        $template->param(
            library       => $library,
            items_count   => $items_count,
            patrons_count => $patrons_count,
        );
    }
} elsif ( $op eq 'cud-delete_confirmed' ) {

    my $deleted = eval { $library->delete; };

    if ( $@ or not $deleted ) {
        push @messages, { type => 'alert', code => 'error_on_delete' };
    } else {
        push @messages, { type => 'message', code => 'success_on_delete' };
    }
    $op = 'list';
} else {
    $op = 'list';
}

$template->param( libraries_count => Koha::Libraries->search->count )
    if $op eq 'list';

$template->param(
    messages => \@messages,
    op       => $op,
);

output_html_with_http_headers $input, $cookie, $template->output;
