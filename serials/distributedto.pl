#!/usr/bin/perl

# Copyright 2000-2002 Katipo Communications
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA


=head1 NAME

distributedto

=head1 DESCRIPTION

this script is launched as a popup. It allows to choose for who the subscription can be distributed.

=head1 PARAMETERS

=over 4

=item searchfield
to filter on the members.

=item distributedto
to know if there are already some members to in the distributed list

=item subscriptionid
to know what subscription this scrpit have to distribute.

=item SaveList

=back

=cut


use strict;
use CGI;
use C4::Dates;
use C4::Auth;
use C4::Context;
use C4::Output;

use C4::Serials;
use C4::Members;

my $input = new CGI;
my $searchfield=$input->param('searchfield');
defined $searchfield or $searchfield='';
my $distributedto=$input->param('distributedto');
my $subscriptionid = $input->param('subscriptionid');
$searchfield=~ s/\,//g;
my $SaveList=$input->param('SaveList');
my $dbh = C4::Context->dbh;

$distributedto = GetDistributedTo($subscriptionid) unless $distributedto;

SetDistributedto($distributedto,$subscriptionid) if ($SaveList) ;

my ($template, $borrowernumber, $cookie)
    = get_template_and_user({template_name => "serials/distributedto.tmpl",
                 query => $input,
                 type => "intranet",
                 authnotrequired => 0,
                 flagsrequired => {serials => 1},
                 debug => 1,
                 });

my ($count,$results)=SearchMember($searchfield,"firstname","simple",) if $searchfield;
my $toggle="0";
my @loop_data =();
for (my $i=0; $i < $count; $i++){
    if ($i % 2){
            $toggle=1;
    } else {
            $toggle=0;
    }
    my %row_data;
    $row_data{toggle} = $toggle;
    $row_data{firstname} = $results->[$i]{'firstname'};
    $row_data{surname} = $results->[$i]{'surname'};
    push(@loop_data, \%row_data);
}
$template->param(borlist => \@loop_data,
                searchfield => $searchfield,
                distributedto => $distributedto,
                SaveList => $SaveList,
                subscriptionid => $subscriptionid,
                );
output_html_with_http_headers $input, $cookie, $template->output;
