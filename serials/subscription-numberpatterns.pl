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

subscription-numberpatterns.pl

=head1 DESCRIPTION

Manage numbering patterns

=cut

use Modern::Perl;
use CGI qw ( -utf8 );

use C4::Auth;
use C4::Output;
use C4::Serials::Numberpattern;
use C4::Serials::Frequency;

my $input = new CGI;
my ($template, $loggedinuser, $cookie, $flags) = get_template_and_user( {
    template_name   => 'serials/subscription-numberpatterns.tt',
    query           => $input,
    type            => 'intranet',
    authnotrequired => 0,
    flagsrequired   => { 'serials' => 1 }
} );

my $op = $input->param('op');

if($op && $op eq 'savenew') {
    my $label = $input->param('label');
    my $numberpattern;
    foreach(qw/ label description numberingmethod displayorder
      label1 label2 label3 add1 add2 add3 every1 every2 every3
      setto1 setto2 setto3 whenmorethan1 whenmorethan2 whenmorethan3
      numbering1 numbering2 numbering3 /) {
        $numberpattern->{$_} = $input->param($_);
        if($numberpattern->{$_} and $numberpattern->{$_} eq '') {
            $numberpattern->{$_} = undef;
        }
    }
    my $numberpattern2 = GetSubscriptionNumberpatternByName($label);

    if(!defined $numberpattern2) {
        AddSubscriptionNumberpattern($numberpattern);
    } else {
        $op = 'new';
        $template->param(error_existing_numberpattern => 1);
        $template->param(%$numberpattern);
    }
} elsif ($op && $op eq 'savemod') {
    my $id = $input->param('id');
    my $label = $input->param('label');
    my $numberpattern = GetSubscriptionNumberpattern($id);
    my $mod_ok = 1;
    if($numberpattern->{'label'} ne $label) {
        my $numberpattern2 = GetSubscriptionNumberpatternByName($label);
        if(defined $numberpattern2 && $id != $numberpattern2->{'id'}) {
            $mod_ok = 0;
        }
    }
    if($mod_ok) {
        foreach(qw/ id label description numberingmethod displayorder
          label1 label2 label3 add1 add2 add3 every1 every2 every3
          setto1 setto2 setto3 whenmorethan1 whenmorethan2 whenmorethan3
          numbering1 numbering2 numbering3 /) {
            $numberpattern->{$_} = $input->param($_) || undef;
        }
        ModSubscriptionNumberpattern($numberpattern);
    } else {
        $op = 'modify';
        $template->param(error_existing_numberpattern => 1);
    }
}

if($op && ($op eq 'new' || $op eq 'modify')) {
    if($op eq 'modify') {
        my $id = $input->param('id');
        if(defined $id) {
            my $numberpattern = GetSubscriptionNumberpattern($id);
            $template->param(%$numberpattern);
        } else {
            $op = 'new';
        }
    }
    my @frequencies = GetSubscriptionFrequencies();
    my @subtypes;
    push @subtypes, { value => $_ } for (qw/ issues weeks months /);

    my $languages = [ map {
        {
            language => $_->{iso639_2_code},
            description => $_->{language_description} || $_->{language}
        }
    } @{ C4::Languages::getAllLanguages() } ];

    $template->param(
        $op => 1,
        frequencies_loop => \@frequencies,
        subtypes_loop => \@subtypes,
        locales => $languages,
    );
    output_html_with_http_headers $input, $cookie, $template->output;
    exit;
}

if($op && $op eq 'del') {
    my $id = $input->param('id');
    if ($id) {
        my $confirm = $input->param('confirm');
        if ($confirm) {
            DelSubscriptionNumberpattern($id);
        } else {
            my @subs = GetSubscriptionsWithNumberpattern($id);
            if (@subs) {
                $template->param(
                    id => $id,
                    still_used => 1,
                    subscriptions => \@subs
                );
            } else {
                DelSubscriptionNumberpattern($id);
            }
        }
    }
}

my @numberpatterns_loop = GetSubscriptionNumberpatterns();

$template->param(
    numberpatterns_loop => \@numberpatterns_loop,
);

output_html_with_http_headers $input, $cookie, $template->output;
