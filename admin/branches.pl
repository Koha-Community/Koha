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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use CGI qw ( -utf8 );
use Try::Tiny qw( catch try );

use C4::Auth qw( get_template_and_user );
use C4::Context;
use C4::Output qw( output_html_with_http_headers );
use C4::Koha;

use Koha::Database;
use Koha::Patrons;
use Koha::Items;
use Koha::Libraries;
use Koha::SMTP::Servers;

my $input        = CGI->new;
my $branchcode   = $input->param('branchcode');
my $categorycode = $input->param('categorycode');
my $op           = $input->param('op') || 'list';
my @messages;

my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {   template_name   => "admin/branches.tt",
        query           => $input,
        type            => "intranet",
        flagsrequired   => { parameters => 'manage_libraries' },
    }
);

if ( $op eq 'add_form' ) {
    my $library;
    if ($branchcode) {
        $library = Koha::Libraries->find($branchcode);
        $template->param( selected_smtp_server => $library->smtp_server );
    }

    my @smtp_servers = Koha::SMTP::Servers->search;

    $template->param(
        library      => $library,
        smtp_servers => \@smtp_servers
    );
} elsif ( $op eq 'add_validate' ) {
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
      opac_info
      marcorgcode
      pickup_location
      public
    );
    my $is_a_modif = $input->param('is_a_modif');

    if ($is_a_modif) {
        my $library = Koha::Libraries->find($branchcode);
        for my $field (@fields) {
            if( $field =~ /^(pickup_location|public)$/  ) {
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

                    if ( $smtp_server_id ) {
                        if ( $smtp_server_id eq '*' ) {
                            $library->smtp_server({ smtp_server => undef });
                        }
                        else {
                            my $smtp_server = Koha::SMTP::Servers->find( $smtp_server_id );
                            Koha::Exceptions::BadParameter->throw( parameter => 'smtp_server' )
                                unless $smtp_server;
                            $library->smtp_server({ smtp_server => $smtp_server });
                        }
                    }

                    push @messages, { type => 'message', code => 'success_on_update' };
                }
            );
        }
        catch {
            push @messages, { type => 'alert', code => 'error_on_update' };
        };
    } else {
        $branchcode =~ s|\s||g;
        my $library = Koha::Library->new(
            {
                branchcode => $branchcode,
                (
                    map {
                        /^(pickup_location|public)$/ # Don't fallback to undef for those fields
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

                    if ( $smtp_server_id ) {
                        if ( $smtp_server_id ne '*' ) {
                            my $smtp_server = Koha::SMTP::Servers->find( $smtp_server_id );
                            Koha::Exceptions::BadParameter->throw( parameter => 'smtp_server' )
                                unless $smtp_server;
                            $library->smtp_server({ smtp_server => $smtp_server });
                        }
                    }

                    push @messages, { type => 'message', code => 'success_on_insert' };
                }
            );
        }
        catch {
            push @messages, { type => 'alert', code => 'error_on_insert' };
        };
    }
    $op = 'list';
} elsif ( $op eq 'delete_confirm' ) {
    my $library       = Koha::Libraries->find($branchcode);
    my $items_count = Koha::Items->search(
        {   -or => {
                holdingbranch => $branchcode,
                homebranch    => $branchcode
            },
        }
    )->count;
    my $patrons_count = Koha::Patrons->search( { branchcode => $branchcode, } )->count;

    if ( $items_count or $patrons_count ) {
        push @messages,
          { type => 'alert',
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
} elsif ( $op eq 'delete_confirmed' ) {
    my $library = Koha::Libraries->find($branchcode);

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
