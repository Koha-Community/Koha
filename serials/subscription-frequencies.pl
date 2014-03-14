#!/usr/bin/perl

# Copyright 2011-2013 Biblibre SARL
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

subscription-frequencies.pl

=head1 DESCRIPTION

Manage subscription frequencies

=cut

use Modern::Perl;

use CGI qw ( -utf8 );

use C4::Auth;
use C4::Output;
use C4::Serials;
use C4::Serials::Frequency;

my $input = new CGI;
my ($template, $loggedinuser, $cookie, $flags) = get_template_and_user( {
    template_name   => 'serials/subscription-frequencies.tt',
    query           => $input,
    type            => 'intranet',
    authnotrequired => 0,
    flagsrequired   => { 'serials' => 1 },
    debug           => 1,
} );

my $op = $input->param('op');

if($op && ($op eq 'new' || $op eq 'modify')) {
    my @units_loop;
    push @units_loop, {val => $_} for (qw/ day week month year /);

    if($op eq 'modify') {
        my $frequencyid = $input->param('frequencyid');
        my $frequency = GetSubscriptionFrequency($frequencyid);
        foreach (@units_loop) {
            if($frequency->{unit} and $_->{val} eq $frequency->{unit}) {
                $_->{selected} = 1;
                last;
            }
        }
        $template->param( %$frequency );
    }

    $template->param(
        units_loop => \@units_loop,
        $op        => 1,
    );
    output_html_with_http_headers $input, $cookie, $template->output;
    exit;
}

if($op && ($op eq 'savenew' || $op eq 'savemod')) {
    my $frequency;
    foreach (qw/ description unit issuesperunit unitsperissue displayorder /) {
        $frequency->{$_} = $input->param($_);
    }
    $frequency->{unit} = undef if $frequency->{unit} eq '';
    foreach (qw/issuesperunit unitsperissue/) {
        $frequency->{$_} = 1 if $frequency->{$_} !~ /\d+/;
    }
    $frequency->{issuesperunit} = 1 if $frequency->{issuesperunit} < 1;
    $frequency->{unitsperissue} = 1 if $frequency->{issuesperunit} != 1;

    if($op eq 'savemod') {
        $frequency->{id} = $input->param('id');
        ModSubscriptionFrequency($frequency);
    } else {
        AddSubscriptionFrequency($frequency);
    }
} elsif($op && $op eq 'del') {
    my $frequencyid = $input->param('frequencyid');

    if ($frequencyid) {
        my $confirm = $input->param('confirm');
        if ($confirm) {
            DelSubscriptionFrequency($frequencyid);
        } else {
            my @subs = GetSubscriptionsWithFrequency($frequencyid);
            if (@subs) {
                $template->param(
                    frequencyid => $frequencyid,
                    still_used => 1,
                    subscriptions => \@subs
                );
            } else {
                DelSubscriptionFrequency($frequencyid);
            }
        }
    }
}


my @frequencies = GetSubscriptionFrequencies();

$template->param(frequencies_loop => \@frequencies);
$template->param($op => 1) if $op;

output_html_with_http_headers $input, $cookie, $template->output;
