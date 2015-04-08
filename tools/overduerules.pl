#!/usr/bin/perl

# Copyright 2000-2002 Katipo Communications
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

use strict;
use warnings;
use CGI;
use C4::Context;
use C4::Output;
use C4::Auth;
use C4::Koha;
use C4::Branch;
use C4::Letters;
use C4::Members;
use C4::Overdues;

our $input = new CGI;
my $dbh = C4::Context->dbh;

my @categories = @{$dbh->selectall_arrayref(
    'SELECT description, categorycode FROM categories WHERE overduenoticerequired > 0',
    { Slice => {} }
)};
my @category_codes  = map { $_->{categorycode} } @categories;
our @rule_params     = qw(delay letter debarred);

# blank_row($category_code) - return true if the entire row is blank.
sub blank_row {
    my ($category_code) = @_;
    for my $rp (@rule_params) {
        for my $n (1 .. 3) {
            my $key   = "${rp}${n}-$category_code";

            if (utf8::is_utf8($key)) {
              utf8::encode($key);
            }

            my $value = $input->param($key);
            if ($value) {
                return 0;
            }
        }
    }
    return 1;
}

my $type=$input->param('type');
my $branch = $input->param('branch');
$branch ||= q{};
my $op = $input->param('op');
$op ||= q{};

my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "tools/overduerules.tt",
                            query => $input,
                            type => "intranet",
                            authnotrequired => 0,
                            flagsrequired => { tools => 'edit_notice_status_triggers'},
                            debug => 1,
                            });
my $err=0;

# save the values entered into tables
my %temphash;
my $input_saved = 0;
if ($op eq 'save') {
    my @names=$input->param();
    my $sth_search = $dbh->prepare("SELECT count(*) AS total FROM overduerules WHERE branchcode=? AND categorycode=?");

    my $sth_insert = $dbh->prepare("INSERT INTO overduerules (branchcode,categorycode, delay1,letter1,debarred1, delay2,letter2,debarred2, delay3,letter3,debarred3) VALUES (?,?,?,?,?,?,?,?,?,?,?)");
    my $sth_update=$dbh->prepare("UPDATE overduerules SET delay1=?, letter1=?, debarred1=?, delay2=?, letter2=?, debarred2=?, delay3=?, letter3=?, debarred3=? WHERE branchcode=? AND categorycode=?");
    my $sth_delete=$dbh->prepare("DELETE FROM overduerules WHERE branchcode=? AND categorycode=?");
    my $sth_insert_mtt = $dbh->prepare("
        INSERT INTO overduerules_transport_types(
            branchcode, categorycode, letternumber, message_transport_type
        ) VALUES (
            ?, ?, ?, ?
        )
    ");
    my $sth_delete_mtt = $dbh->prepare("
        DELETE FROM overduerules_transport_types
        WHERE branchcode = ? AND categorycode = ?
    ");

    foreach my $key (@names){
            # ISSUES
            if ($key =~ /(delay|letter|debarred)([1-3])-(.*)/) {
                    my $type = $1; # data type
                    my $num = $2; # From 1 to 3
                    my $bor = $3; # borrower category
                    my $value = $input->param($key);
                    if ($type eq 'delay') {
                        $temphash{$bor}->{"$type$num"} = ($value =~ /^\d+$/ && int($value) > 0) ? int($value) : '';
                    } else {
                        # type is letter
                        $temphash{$bor}->{"$type$num"} = $value if $value ne '';
                    }
            }
    }

    # figure out which rows need to be deleted
    my @rows_to_delete = grep { blank_row($_) } @category_codes;

    foreach my $bor (keys %temphash){
        # get category name if we need it for an error message
        my $bor_category = GetBorrowercategory($bor);
        my $bor_category_name = defined($bor_category) ? $bor_category->{description} : $bor;

        # Do some Checking here : delay1 < delay2 <delay3 all of them being numbers
        # Raise error if not true
        if ($temphash{$bor}->{delay1}=~/[^0-9]/ and $temphash{$bor}->{delay1} ne ""){
            $template->param("ERROR"=>1,"ERRORDELAY"=>"delay1","BORERR"=>$bor_category_name);
            $err=1;
        } elsif ($temphash{$bor}->{delay2}=~/[^0-9]/ and $temphash{$bor}->{delay2} ne ""){
            $template->param("ERROR"=>1,"ERRORDELAY"=>"delay2","BORERR"=>$bor_category_name);
            $err=1;
        } elsif ($temphash{$bor}->{delay3}=~/[^0-9]/ and $temphash{$bor}->{delay3} ne ""){
            $template->param("ERROR"=>1,"ERRORDELAY"=>"delay3","BORERR"=>$bor_category_name);
            $err=1;
        } elsif ($temphash{$bor}->{delay1} and not ($temphash{$bor}->{"letter1"} or $temphash{$bor}->{"debarred1"})) {
            $template->param("ERROR"=>1,"ERRORUSELESSDELAY"=>"delay1","BORERR"=>$bor_category_name);
            $err=1;
        } elsif ($temphash{$bor}->{delay2} and not ($temphash{$bor}->{"letter2"} or $temphash{$bor}->{"debarred2"})) {
            $template->param("ERROR"=>1,"ERRORUSELESSDELAY"=>"delay2","BORERR"=>$bor_category_name);
            $err=1;
        } elsif ($temphash{$bor}->{delay3} and not ($temphash{$bor}->{"letter3"} or $temphash{$bor}->{"debarred3"})) {
            $template->param("ERROR"=>1,"ERRORUSELESSDELAY"=>"delay3","BORERR"=>$bor_category_name);
            $err=1;
        }elsif ($temphash{$bor}->{delay3} and
                ($temphash{$bor}->{delay3}<=$temphash{$bor}->{delay2} or $temphash{$bor}->{delay3}<=$temphash{$bor}->{delay1})
                or $temphash{$bor}->{delay2} and ($temphash{$bor}->{delay2}<=$temphash{$bor}->{delay1})){
                    $template->param("ERROR"=>1,"ERRORORDER"=>1,"BORERR"=>$bor_category_name);
                        $err=1;
        }
        unless ($err){
            if (($temphash{$bor}->{delay1} and ($temphash{$bor}->{"letter1"} or $temphash{$bor}->{"debarred1"}))
                or ($temphash{$bor}->{delay2} and ($temphash{$bor}->{"letter2"} or $temphash{$bor}->{"debarred2"}))
                or ($temphash{$bor}->{delay3} and ($temphash{$bor}->{"letter3"} or $temphash{$bor}->{"debarred3"}))) {
                    $sth_search->execute($branch,$bor);
                    my $res = $sth_search->fetchrow_hashref();
                    if ($res->{'total'}>0) {
                        $sth_update->execute(
                            ($temphash{$bor}->{"delay1"}?$temphash{$bor}->{"delay1"}:undef),
                            ($temphash{$bor}->{"letter1"}?$temphash{$bor}->{"letter1"}:""),
                            ($temphash{$bor}->{"debarred1"}?$temphash{$bor}->{"debarred1"}:0),
                            ($temphash{$bor}->{"delay2"}?$temphash{$bor}->{"delay2"}:undef),
                            ($temphash{$bor}->{"letter2"}?$temphash{$bor}->{"letter2"}:""),
                            ($temphash{$bor}->{"debarred2"}?$temphash{$bor}->{"debarred2"}:0),
                            ($temphash{$bor}->{"delay3"}?$temphash{$bor}->{"delay3"}:undef),
                            ($temphash{$bor}->{"letter3"}?$temphash{$bor}->{"letter3"}:""),
                            ($temphash{$bor}->{"debarred3"}?$temphash{$bor}->{"debarred3"}:0),
                            $branch ,$bor
                            );
                    } else {
                        $sth_insert->execute($branch,$bor,
                            ($temphash{$bor}->{"delay1"}?$temphash{$bor}->{"delay1"}:0),
                            ($temphash{$bor}->{"letter1"}?$temphash{$bor}->{"letter1"}:""),
                            ($temphash{$bor}->{"debarred1"}?$temphash{$bor}->{"debarred1"}:0),
                            ($temphash{$bor}->{"delay2"}?$temphash{$bor}->{"delay2"}:0),
                            ($temphash{$bor}->{"letter2"}?$temphash{$bor}->{"letter2"}:""),
                            ($temphash{$bor}->{"debarred2"}?$temphash{$bor}->{"debarred2"}:0),
                            ($temphash{$bor}->{"delay3"}?$temphash{$bor}->{"delay3"}:0),
                            ($temphash{$bor}->{"letter3"}?$temphash{$bor}->{"letter3"}:""),
                            ($temphash{$bor}->{"debarred3"}?$temphash{$bor}->{"debarred3"}:0)
                            );
                    }

                    $sth_delete_mtt->execute( $branch, $bor );
                    for my $letternumber ( 1..3 ) {
                        my @mtt = $input->param( "mtt${letternumber}-$bor" );
                        next unless @mtt;
                        for my $mtt ( @mtt ) {
                            $sth_insert_mtt->execute( $branch, $bor, $letternumber, $mtt);
                        }
                    }
                }
        }
    }
    unless ($err) {
        for my $category_code (@rows_to_delete) {
            $sth_delete->execute($branch, $category_code);
        }
        $template->param(datasaved => 1);
        $input_saved = 1;
    }
}
my $branchloop = GetBranchesLoop($branch);

my $letters = C4::Letters::GetLettersAvailableForALibrary(
    {
        branchcode => $branch,
        module => "circulation",
    }
);

my @line_loop;

my $message_transport_types = C4::Letters::GetMessageTransportTypes();
my ( @first, @second, @third );
for my $data (@categories) {
    if (%temphash and not $input_saved){
        # if we managed to save the form submission, don't
        # reuse %temphash, but take the values from the
        # database - this makes it easier to identify
        # bugs where the form submission was not correctly saved
        for my $i ( 1..3 ){
            my %row = (
                overduename => $data->{'categorycode'},
                line        => $data->{'description'}
            );
            $row{delay}=$temphash{$data->{'categorycode'}}->{"delay$i"};
            $row{debarred}=$temphash{$data->{'categorycode'}}->{"debarred$i"};
            $row{selected_lettercode} = $temphash{ $data->{categorycode} }->{"letter$i"};
            my @selected_mtts = @{ GetOverdueMessageTransportTypes( $branch, $data->{'categorycode'}, $i) };
            my @mtts;
            for my $mtt ( @$message_transport_types ) {
                push @mtts, {
                    value => $mtt,
                    selected => ( grep {/$mtt/} @selected_mtts ) ? 1 : 0 ,
                }
            }
            $row{message_transport_types} = \@mtts;
            if ( $i == 1 ) {
                push @first, \%row;
            } elsif ( $i == 2 ) {
                push @second, \%row;
            } else {
                push @third, \%row;
            }
        }
    } else {
    #getting values from table
        my $sth2=$dbh->prepare("SELECT * from overduerules WHERE branchcode=? AND categorycode=?");
        $sth2->execute($branch,$data->{'categorycode'});
        my $dat=$sth2->fetchrow_hashref;
        for my $i ( 1..3 ){
            my %row = (
                overduename => $data->{'categorycode'},
                line        => $data->{'description'}
            );

            $row{selected_lettercode} = $dat->{"letter$i"};

            if ($dat->{"delay$i"}){$row{delay}=$dat->{"delay$i"};}
            if ($dat->{"debarred$i"}){$row{debarred}=$dat->{"debarred$i"};}
            my @selected_mtts = @{ GetOverdueMessageTransportTypes( $branch, $data->{'categorycode'}, $i) };
            my @mtts;
            for my $mtt ( @$message_transport_types ) {
                push @mtts, {
                    value => $mtt,
                    selected => ( grep {/$mtt/} @selected_mtts ) ? 1 : 0 ,
                }
            }
            $row{message_transport_types} = \@mtts;
            if ( $i == 1 ) {
                push @first, \%row;
            } elsif ( $i == 2 ) {
                push @second, \%row;
            } else {
                push @third, \%row;
            }

        }
    }
}

my @tabs = (
    {
        id => 'first',
        number => 1,
        values => \@first,
    },
    {
        id => 'second',
        number => 2,
        values => \@second,
    },
    {
        id => 'third',
        number => 3,
        values => \@third,
    },
);

$template->param(
    table => ( @first or @second or @third ? 1 : 0 ),
    branchloop => $branchloop,
    branch => $branch,
    tabs => \@tabs,
    message_transport_types => $message_transport_types,
    letters => $letters,
);
output_html_with_http_headers $input, $cookie, $template->output;
