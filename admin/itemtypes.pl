#!/usr/bin/perl

# Copyright 2000-2002 Katipo Communications
# Copyright 2002 Paul Poulain
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

=head1 admin/itemtypes.pl

=cut

use Modern::Perl;
use CGI qw ( -utf8 );

use File::Spec;

use C4::Koha;
use C4::Context;
use C4::Auth;
use C4::Output;
use Koha::ItemTypes;
use Koha::ItemType;
use Koha::Localizations;

my $input         = new CGI;
my $searchfield   = $input->param('description');
my $itemtype_code = $input->param('itemtype');
my $op            = $input->param('op') // 'list';
my @messages;
$searchfield =~ s/\,//g if $searchfield;
my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {   template_name   => "admin/itemtypes.tt",
        query           => $input,
        type            => "intranet",
        flagsrequired   => { parameters => 'manage_itemtypes' },
        debug           => 1,
    }
);

my $dbh = C4::Context->dbh;

my $sip_media_type = $input->param('sip_media_type');
undef($sip_media_type) if defined($sip_media_type) and $sip_media_type =~ /^\s*$/;

if ( $op eq 'add_form' ) {
    my $itemtype = Koha::ItemTypes->find($itemtype_code);

    my $selected_branches = $itemtype ? $itemtype->get_library_limits : undef;
    my $branches = Koha::Libraries->search( {}, { order_by => ['branchname'] } )->unblessed;
    my @branches_loop;
    foreach my $branch ( @$branches ) {
        my $selected = ($selected_branches && grep {$_->branchcode eq $branch->{branchcode}} @{ $selected_branches->as_list } ) ? 1 : 0;
        push @branches_loop, {
            branchcode => $branch->{branchcode},
            branchname => $branch->{branchname},
            selected   => $selected,
        };
    }

    my $imagesets = C4::Koha::getImageSets( checked => ( $itemtype ? $itemtype->imageurl : undef ) );
    my $searchcategory = GetAuthorisedValues("ITEMTYPECAT");
    my $translated_languages = C4::Languages::getTranslatedLanguages( undef , C4::Context->preference('template') );
    $template->param(
        itemtype  => $itemtype,
        imagesets => $imagesets,
        searchcategory => $searchcategory,
        can_be_translated => ( scalar(@$translated_languages) > 1 ? 1 : 0 ),
        branches_loop    => \@branches_loop,
    );
} elsif ( $op eq 'add_validate' ) {
    my $is_a_modif   = $input->param('is_a_modif');
    my $itemtype     = Koha::ItemTypes->find($itemtype_code);
    my $description  = $input->param('description');
    my $rentalcharge = $input->param('rentalcharge');
    my $rentalcharge_daily = $input->param('rentalcharge_daily');
    my $rentalcharge_hourly = $input->param('rentalcharge_hourly');
    my $defaultreplacecost = $input->param('defaultreplacecost');
    my $processfee = $input->param('processfee');
    my $image = $input->param('image') || q||;
    my @branches = grep { $_ ne q{} } $input->multi_param('branches');

    my $notforloan = $input->param('notforloan') ? 1 : 0;
    my $imageurl =
      $image eq 'removeImage' ? ''
      : (
          $image eq 'remoteImage' ? $input->param('remoteImage')
        : $image
      );
    my $summary        = $input->param('summary');
    my $checkinmsg     = $input->param('checkinmsg');
    my $checkinmsgtype = $input->param('checkinmsgtype');
    my $hideinopac     = $input->param('hideinopac') // 0;
    my $searchcategory = $input->param('searchcategory');
    my $rentalcharge_daily_calendar  = $input->param('rentalcharge_daily_calendar') // 0;
    my $rentalcharge_hourly_calendar = $input->param('rentalcharge_hourly_calendar') // 0;

    if ( $itemtype and $is_a_modif ) {    # it's a modification
        $itemtype->description($description);
        $itemtype->rentalcharge($rentalcharge);
        $itemtype->rentalcharge_daily($rentalcharge_daily);
        $itemtype->rentalcharge_hourly($rentalcharge_hourly);
        $itemtype->defaultreplacecost($defaultreplacecost);
        $itemtype->processfee($processfee);
        $itemtype->notforloan($notforloan);
        $itemtype->imageurl($imageurl);
        $itemtype->summary($summary);
        $itemtype->checkinmsg($checkinmsg);
        $itemtype->checkinmsgtype($checkinmsgtype);
        $itemtype->sip_media_type($sip_media_type);
        $itemtype->hideinopac($hideinopac);
        $itemtype->searchcategory($searchcategory);
        $itemtype->rentalcharge_daily_calendar($rentalcharge_daily_calendar);
        $itemtype->rentalcharge_hourly_calendar($rentalcharge_hourly_calendar);

        eval {
          $itemtype->store;
          $itemtype->replace_library_limits( \@branches );
        };

        if ($@) {
            push @messages, { type => 'alert', code => 'error_on_update' };
        } else {
            push @messages, { type => 'message', code => 'success_on_update' };
        }
    } elsif ( not $itemtype and not $is_a_modif ) {
        my $itemtype = Koha::ItemType->new(
            {
                itemtype            => $itemtype_code,
                description         => $description,
                rentalcharge        => $rentalcharge,
                rentalcharge_daily  => $rentalcharge_daily,
                rentalcharge_hourly => $rentalcharge_hourly,
                defaultreplacecost  => $defaultreplacecost,
                processfee          => $processfee,
                notforloan          => $notforloan,
                imageurl            => $imageurl,
                summary             => $summary,
                checkinmsg          => $checkinmsg,
                checkinmsgtype      => $checkinmsgtype,
                sip_media_type      => $sip_media_type,
                hideinopac          => $hideinopac,
                searchcategory      => $searchcategory,
                rentalcharge_daily_calendar  => $rentalcharge_daily_calendar,
                rentalcharge_hourly_calendar => $rentalcharge_hourly_calendar,
            }
        );
        eval {
          $itemtype->store;
          $itemtype->replace_library_limits( \@branches );
        };

        if ($@) {
            push @messages, { type => 'alert', code => 'error_on_insert' };
        } else {
            push @messages, { type => 'message', code => 'success_on_insert' };
        }
    } else {
        push @messages,
          { type => 'alert',
            code => 'already_exists',
          };
    }

    $searchfield = '';
    $op          = 'list';

 } elsif ( $op eq 'delete_confirm' ) {
    my $itemtype = Koha::ItemTypes->find($itemtype_code);
    my $can_be_deleted = $itemtype->can_be_deleted();
    if ($can_be_deleted == 0) {
        push @messages, { type => 'alert', code => 'cannot_be_deleted'};
        $op = 'list';
    } else {
        $template->param( itemtype => $itemtype, );
    }

} elsif ( $op eq 'delete_confirmed' ) {

    my $itemtype = Koha::ItemTypes->find($itemtype_code);
    my $deleted = eval { $itemtype->delete };
    if ( $@ or not $deleted ) {
        push @messages, { type => 'alert', code => 'error_on_delete' };
    } else {
        push @messages, { type => 'message', code => 'success_on_delete' };
    }

    $op = 'list';
}

if ( $op eq 'list' ) {
    my @itemtypes = Koha::ItemTypes->search->as_list;
    $template->param(
        itemtypes => \@itemtypes,
        messages  => \@messages,
    );
}

$template->param( op => $op );

output_html_with_http_headers $input, $cookie, $template->output;
