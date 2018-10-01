#!/usr/bin/perl

# Copyright 2016 PTFS-Europe Ltd
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

=head1 stockrotation.pl

 Script to handle stockrotation. Including rotas, their associated stages
 and items

=cut

use Modern::Perl;
use CGI;

use C4::Auth;
use C4::Context;
use C4::Output;

use Koha::Libraries;
use Koha::StockRotationRotas;
use Koha::StockRotationItems;
use Koha::StockRotationStages;
use Koha::Item;
use Koha::Util::StockRotation qw(:ALL);

my $input = new CGI;

unless (C4::Context->preference('StockRotation')) {
    # redirect to Intranet home if self-check is not enabled
    print $input->redirect("/cgi-bin/koha/mainpage.pl");
    exit;
}

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => 'tools/stockrotation.tt',
        query           => $input,
        type            => 'intranet',
        flagsrequired   => {
            tools => '*',
            stockrotation => '*',
        },
        authnotrequired => 0
    }
);

# Grab all passed data
# 'our' since Plack changes the scoping
# of 'my'
our %params = $input->Vars();

my $op = $params{op};

if (!defined $op) {

    # No operation is supplied, we're just displaying the list of rotas
    my $rotas = Koha::StockRotationRotas->search(
        undef,
        {
            order_by => { -asc => 'title' }
        }
    )->as_list;

    $template->param(
        existing_rotas => $rotas,
        no_op_set      => 1
    );

} elsif ($op eq 'create_edit_rota') {

    # Edit an existing rota or define a new one
    my $rota_id = $params{rota_id};

    my $rota = {};

    if (!defined $rota_id) {

        # No ID supplied, we're creating a new rota
        # Create a shell rota hashref
        $rota = {
            cyclical => 1
        };

    } else {

        # ID supplied, we're editing an existing rota
        $rota = Koha::StockRotationRotas->find($rota_id);

    }

    $template->param(
        rota => $rota,
        op   => $op
    );

} elsif ($op eq 'toggle_rota') {

    # Find and update the active status of the rota
    my $rota = Koha::StockRotationRotas->find($params{rota_id});

    my $new_active = ($rota->active == 1) ? 0 : 1;

    $rota->active($new_active)->store;

    # Return to rotas page
    print $input->redirect('stockrotation.pl');

} elsif ($op eq 'process_rota') {

    # Get a hashref of the submitted rota data
    my $rota = get_rota_from_form();

    if (!process_rota($rota)) {

        # The submitted rota was invalid
        $template->param(
            error => 'invalid_form',
            rota => $rota,
            op   => 'create_edit_rota'
        );

    } else {

        # All was well, return to the rotas list
        print $input->redirect('stockrotation.pl');

    }

} elsif ($op eq 'manage_stages') {

    my $rota = Koha::StockRotationRotas->find($params{rota_id});

    $template->param(
        rota            => $rota,
        branches        => get_branches(),
        existing_stages => get_stages($rota),
        rota_id         => $params{rota_id},
        op              => $op
    );

} elsif ($op eq 'create_edit_stage') {

    # Edit an existing stage or define a new one
    my $stage_id = $params{stage_id};

    my $rota_id = $params{rota_id};

    if (!defined $stage_id) {

        # No ID supplied, we're creating a new stage
        $template->param(
            branches => get_branches(),
            stage    => {},
            rota_id  => $rota_id,
            op       => $op
        );

    } else {

        # ID supplied, we're editing an existing stage
        my $stage = Koha::StockRotationStages->find($stage_id);

        $template->param(
            branches => get_branches(),
            stage    => $stage,
            rota_id  => $stage->rota->rota_id,
            op       => $op
        );

    }

} elsif ($op eq 'confirm_remove_from_rota') {

    # Get the stage we're deleting
    $template->param(
        op       => $op,
        rota_id  => $params{rota_id},
        stage_id => $params{stage_id},
        item_id  => $params{item_id}
    );

} elsif ($op eq 'confirm_delete_stage') {

    # Get the stage we're deleting
    my $stage = Koha::StockRotationStages->find($params{stage_id});

    $template->param(
        op    => $op,
        stage => $stage
    );

} elsif ($op eq 'delete_stage') {

    # Get the stage we're deleting
    my $stage = Koha::StockRotationStages->find($params{stage_id});

    # Get the ID of the rota with which this stage is associated
    # (so we can return to the "Manage stages" page after deletion)
    my $rota_id = $stage->rota->rota_id;

    $stage->delete;

    # Return to the stages list
    print $input->redirect("?op=manage_stages&rota_id=$rota_id");

} elsif ($op eq 'process_stage') {

    # Get a hashref of the submitted stage data
    my $stage = get_stage_from_form();

    # The rota we're managing
    my $rota_id = $params{rota_id};

    if (!process_stage($stage, $rota_id)) {

        # The submitted stage was invalid
        # Get all branches
        my $branches = get_branches();

        $template->param(
            error        => 'invalid_form',
            all_branches => $branches,
            stage        => $stage,
            rota_id      => $rota_id,
            op           => 'create_edit_stage'
        );

    } else {

        # All was well, return to the stages list
        print $input->redirect("?op=manage_stages&rota_id=$rota_id");

    }

} elsif ($op eq 'manage_items') {

    my $rota = Koha::StockRotationRotas->find($params{rota_id});

    # Get all items on this rota, for each prefetch their
    # stage and biblio objects
    my $items = Koha::StockRotationItems->search(
        { 'stage.rota_id' => $params{rota_id} },
        {
            prefetch => {
                stage => {
                    'stockrotationitems' => {
                        'itemnumber' => 'biblionumber'
                    }
                }
            }
        }
    );

    $template->param(
        rota_id  => $params{rota_id},
        error    => $params{error},
        items    => $items,
        branches => get_branches(),
        stages   => get_stages($rota),
        rota     => $rota,
        op       => $op
    );

} elsif ($op eq 'move_to_next_stage') {

    move_to_next_stage($params{item_id}, $params{stage_id});

    # Return to the items list
    print $input->redirect("?op=manage_items&rota_id=" . $params{rota_id});

} elsif ($op eq 'toggle_in_demand') {

    # Toggle the item's in_demand
    toggle_indemand($params{item_id}, $params{stage_id});

    # Return to the items list
    print $input->redirect("?op=manage_items&rota_id=".$params{rota_id});

} elsif ($op eq 'remove_item_from_stage') {

    # Remove the item from the stage
    remove_from_stage($params{item_id}, $params{stage_id});

    # Return to the items list
    print $input->redirect("?op=manage_items&rota_id=".$params{rota_id});

} elsif ($op eq 'add_items_to_rota') {

    # The item's barcode,
    # which we may or may not have been passed
    my $barcode = $params{barcode};

    # The rota we're adding the item to
    my $rota_id = $params{rota_id};

    # The uploaded file filehandle,
    # which we may or may not have been passed
    my $barcode_file = $input->upload("barcodefile");

    # We need to create an array of one or more barcodes to
    # insert
    my @barcodes = ();

    # If the barcode input box was populated, use it
    push @barcodes, $barcode if $barcode;

    # Only parse the uploaded file if necessary
    if ($barcode_file) {

        # Call binmode on the filehandle as we want to set a
        # UTF-8 layer on it
        binmode($barcode_file, ":encoding(UTF-8)");
        # Parse the file into an array of barcodes
        while (my $barcode = <$barcode_file>) {
            $barcode =~ s/\r/\n/g;
            $barcode =~ s/\n+/\n/g;
            my @data = split(/\n/, $barcode);
            push @barcodes, @data;
        }

    }

    # A hashref to hold the status of each barcode
    my $barcode_status = {
        ok        => [],
        on_other  => [],
        on_this   => [],
        not_found => []
    };

    # If we have something to work with, do it
    get_barcodes_status($rota_id, \@barcodes, $barcode_status) if (@barcodes);

    # Now we know the status of each barcode, add those that
    # need it
    if (scalar @{$barcode_status->{ok}} > 0) {

        add_items_to_rota($rota_id, $barcode_status->{ok});

    }
    # If we were only passed one barcode and it was successfully
    # added, redirect back to ourselves, we don't want to display
    # a report, redirect also if we were passed no barcodes
    if (
        scalar @barcodes == 0 ||
        (scalar @barcodes == 1 && scalar @{$barcode_status->{ok}} == 1)
    ) {

        print $input->redirect("?op=manage_items&rota_id=$rota_id");

    } else {

        # Report on the outcome
        $template->param(
            barcode_status => $barcode_status,
            rota_id        => $rota_id,
            op             => $op
        );

    }

} elsif ($op eq 'move_items_to_rota') {

    # The barcodes of the items we're moving
    my @move = $input->param('move_item');

    foreach my $item(@move) {

        # The item we're moving
        my $item = Koha::Items->find($item);

        # Move it to the new rota
        $item->add_to_rota($params{rota_id});

    }

    # Return to the items list
    print $input->redirect("?op=manage_items&rota_id=".$params{rota_id});

}

output_html_with_http_headers $input, $cookie, $template->output;

sub get_rota_from_form {

    return {
        id          => $params{id},
        title       => $params{title},
        cyclical    => $params{cyclical},
        description => $params{description}
    };
}

sub get_stage_from_form {

    return {
        stage_id    => $params{stage_id},
        branchcode  => $params{branchcode},
        duration    => $params{duration}
    };
}

sub process_rota {

    my $sub_rota = shift;

    # Fields we require
    my @required = ('title','cyclical');

    # Count of the number of required fields we have
    my $valid = 0;

    # Ensure we have everything we require
    foreach my $req(@required) {

        if (exists $sub_rota->{$req}) {

            chomp(my $value = $sub_rota->{$req});
            if (length $value > 0) {
                $valid++;
            }

        }

    }

    # If we don't have everything we need
    return 0 if $valid != scalar @required;

    # Passed validation
    # Find the rota we're updating
    my $rota = Koha::StockRotationRotas->find($sub_rota->{id});

    if ($rota) {

        $rota->title(
            $sub_rota->{title}
        )->cyclical(
            $sub_rota->{cyclical}
        )->description(
            $sub_rota->{description}
        )->store;

    } else {

        $rota = Koha::StockRotationRota->new({
            title       => $sub_rota->{title},
            cyclical    => $sub_rota->{cyclical},
            active      => 0,
            description => $sub_rota->{description}
        })->store;

    }

    return 1;
}

sub process_stage {

    my ($sub_stage, $rota_id) = @_;

    # Fields we require
    my @required = ('branchcode','duration');

    # Count of the number of required fields we have
    my $valid = 0;

    # Ensure we have everything we require
    foreach my $req(@required) {

        if (exists $sub_stage->{$req}) {

            chomp(my $value = $sub_stage->{$req});
            if (length $value > 0) {
                $valid++;
            }

        }

    }

    # If we don't have everything we need
    return 0 if $valid != scalar @required;

    # Passed validation
    # Find the stage we're updating
    my $stage = Koha::StockRotationStages->find($sub_stage->{stage_id});

    if ($stage) {

        # Updating an existing stage
        $stage->branchcode_id(
            $sub_stage->{branchcode}
        )->duration(
            $sub_stage->{duration}
        )->store;

    } else {

        # Creating a new stage
        $stage = Koha::StockRotationStage->new({
            branchcode_id  => $sub_stage->{branchcode},
            rota_id        => $rota_id,
            duration       => $sub_stage->{duration}
        })->store;

    }

    return 1;
}

=head1 AUTHOR

Andrew Isherwood <andrew.isherwood@ptfs-europe.com>

=cut
