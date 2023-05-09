#!/usr/bin/perl


# Copyright 2005 Biblibre
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

lateorders.pl

=head1 DESCRIPTION

this script shows late orders for a specific supplier, branch and delay
given on input arg.

=head1 CGI PARAMETERS

=over 4

=item booksellerid
To know on which supplier this script have to display late order.

=item delay
To know the time boundary. Default value is 30 days.

=item branch
To know on which branch this script have to display late order.

=back

=cut

use Modern::Perl;
use CGI qw ( -utf8 );
use C4::Auth qw( get_template_and_user );
use C4::Output qw( output_html_with_http_headers );
use C4::Context;
use C4::Letters qw( SendAlerts GetLetters );
use Koha::DateUtils qw( dt_from_string );
use Koha::Acquisition::Orders;
use Koha::CsvProfiles;

my $input = CGI->new;
my ($template, $loggedinuser, $cookie) = get_template_and_user(
    {
        template_name   => "acqui/lateorders.tt",
        query           => $input,
        type            => "intranet",
        flagsrequired   => { acquisition => 'order_receive' },
    }
);

my $booksellerid = $input->param('booksellerid');
my $delay        = $input->param('delay') // 0;

# Get the "date from" param if !defined is today
my $estimateddeliverydatefrom = $input->param('estimateddeliverydatefrom');
my $estimateddeliverydateto   = $input->param('estimateddeliverydateto');

# Get the "date to" param. If it is not defined and $delay is not defined too, it is the today's date.
$estimateddeliverydateto ||=
  ( not defined $delay and not defined $estimateddeliverydatefrom )
  ? dt_from_string()
  : undef;

my $branch     = $input->param('branch');
my $op         = $input->param('op');

my @errors = ();
if ( $delay and not $delay =~ /^\d{1,3}$/ ) {
    push @errors, {delay_digits => 1, bad_delay => $delay};
}

if ($op and $op eq "send_alert"){
    my @ordernums = $input->multi_param("ordernumber");
    my $err;
    eval {
        $err = SendAlerts( 'claimacquisition', \@ordernums, $input->param("letter_code") );
        if ( not ref $err or not exists $err->{error} ) {
            Koha::Acquisition::Orders->find($_)->claim() for @ordernums;
        }
    };

    if ( ref $err and exists $err->{error} and $err->{error} eq "no_email" ) {
        $template->{VARS}->{'error_claim'} = "no_email";
    } elsif ( ref $err and exists $err->{error} and $err->{error} eq "no_order_selected"){
        $template->{VARS}->{'error_claim'} = "no_order_selected";
    } elsif ( $@ or ref $err and exists $err->{error} ) {
        $template->param(error_claim => $@ || $err->{error});
    } else {
        $template->{VARS}->{'info_claim'} = 1;
    }
}

my @lateorders = Koha::Acquisition::Orders->filter_by_lates(
    {
        delay        => $delay,
        (
            $estimateddeliverydatefrom
            ? ( estimated_from => dt_from_string($estimateddeliverydatefrom, 'iso') )
            : ()
        ),
        (
            $estimateddeliverydateto
            ? ( estimated_to => dt_from_string($estimateddeliverydateto, 'iso') )
            : ()
        )
    },
)->as_list;

my $booksellers = Koha::Acquisition::Booksellers->search(
    {
        id => {
            -in => [ map { $_->basket->booksellerid } @lateorders ]
        },
    }
);

@lateorders = grep { $_->basket->booksellerid eq $booksellerid } @lateorders if $booksellerid;

my $letters = GetLetters({ module => "claimacquisition" });

$template->param(ERROR_LOOP => \@errors) if (@errors);
$template->param(
    lateorders => \@lateorders,
    booksellers => $booksellers,
    bookseller_filter => ( $booksellerid ? $booksellers->find($booksellerid) : undef),
	delay => $delay,
    letters => $letters,
    estimateddeliverydatefrom => $estimateddeliverydatefrom,
    estimateddeliverydateto   => $estimateddeliverydateto,
	intranetcolorstylesheet => C4::Context->preference("intranetcolorstylesheet"),
    csv_profiles         => Koha::CsvProfiles->search({ type => 'sql', used_for => 'late_orders' }),
);
output_html_with_http_headers $input, $cookie, $template->output;
