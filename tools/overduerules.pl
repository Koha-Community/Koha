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

use strict;
use CGI;
use C4::Context;
use C4::Output;
use C4::Auth;
use C4::Koha;
use C4::Branch; # GetBranches
use C4::Letters;
use C4::Members;

my $input = new CGI;
my $dbh = C4::Context->dbh;

my $type=$input->param('type');
my $branch = $input->param('branch');
$branch="" unless $branch;
my $op = $input->param('op');

# my $flagsrequired;
# $flagsrequired->{circulation}=1;
my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "tools/overduerules.tmpl",
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
    foreach my $key (@names){
            # ISSUES
            if ($key =~ /(.*)([1-3])-(.*)/) {
                    my $type = $1; # data type
                    my $num = $2; # From 1 to 3
                    my $bor = $3; # borrower category
                    $temphash{$bor}->{"$type$num"}=$input->param("$key") if (($input->param("$key") ne "") or ($input->param("$key")>0));
            }
    }
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
                            ($temphash{$bor}->{"delay1"}?$temphash{$bor}->{"delay1"}:0),
                            ($temphash{$bor}->{"letter1"}?$temphash{$bor}->{"letter1"}:""),
                            ($temphash{$bor}->{"debarred1"}?$temphash{$bor}->{"debarred1"}:0),
                            ($temphash{$bor}->{"delay2"}?$temphash{$bor}->{"delay2"}:0),
                            ($temphash{$bor}->{"letter2"}?$temphash{$bor}->{"letter2"}:""),
                            ($temphash{$bor}->{"debarred2"}?$temphash{$bor}->{"debarred2"}:0),
                            ($temphash{$bor}->{"delay3"}?$temphash{$bor}->{"delay3"}:0),
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
                }
        }
    }
    unless ($err) {
        $template->param(datasaved=>1);
        $input_saved = 1;
    }
}
my $branches = GetBranches();
my @branchloop;
foreach my $thisbranch (sort { $branches->{$a}->{branchname} cmp $branches->{$b}->{branchname} } keys %$branches) {
        my $selected = 1 if $thisbranch eq $branch;
        my %row =(value => $thisbranch,
                                selected => $selected,
                                branchname => $branches->{$thisbranch}->{'branchname'},
                        );
        push @branchloop, \%row;
}

my $letters = GetLetters("circulation");

my $countletters = scalar $letters;

my $sth=$dbh->prepare("SELECT description,categorycode FROM categories WHERE overduenoticerequired>0 ORDER BY description");
$sth->execute;
my @line_loop;
my $toggle= 1;
# my $i=0;
while (my $data=$sth->fetchrow_hashref){
    if ( $toggle eq 1 ) {
        $toggle = 0;
    } else {
        $toggle = 1;
    }
    my %row = ( overduename => $data->{'categorycode'},
                toggle => $toggle,
                line => $data->{'description'}
                );
    if (%temphash and not $input_saved){
        # if we managed to save the form submission, don't
        # reuse %temphash, but take the values from the
        # database - this makes it easier to identify
        # bugs where the form submission was not correctly saved
        for (my $i=1;$i<=3;$i++){
            $row{"delay$i"}=$temphash{$data->{'categorycode'}}->{"delay$i"};
            $row{"debarred$i"}=$temphash{$data->{'categorycode'}}->{"debarred$i"};
            if ($countletters){
                my @letterloop;
                foreach my $thisletter (sort { $letters->{$a} cmp $letters->{$b} } keys %$letters) {
                    my $selected = 1 if $thisletter eq $temphash{$data->{'categorycode'}}->{"letter$i"};
                    my %letterrow =(value => $thisletter,
                                    selected => $selected,
                                    lettername => $letters->{$thisletter},
                                    );
                    push @letterloop, \%letterrow;
                }
                $row{"letterloop$i"}=\@letterloop;
            } else {
                $row{"noletter"}=1;
                $row{"letter$i"}=$temphash{$data->{'categorycode'}}->{"letter$i"};
            }
        }
    } else {
    #getting values from table
        my $sth2=$dbh->prepare("SELECT * from overduerules WHERE branchcode=? AND categorycode=?");
        $sth2->execute($branch,$data->{'categorycode'});
        my $dat=$sth2->fetchrow_hashref;
        for (my $i=1;$i<=3;$i++){
            if ($countletters){
                my @letterloop;
                foreach my $thisletter (sort { $letters->{$a} cmp $letters->{$b} } keys %$letters) {
                    my $selected = 1 if $thisletter eq $dat->{"letter$i"};
                    my %letterrow =(value => $thisletter,
                                    selected => $selected,
                                    lettername => $letters->{$thisletter},
                                    );
                    push @letterloop, \%letterrow;
                }
                $row{"letterloop$i"}=\@letterloop;
            } else {
                $row{"noletter"}=1;
                if ($dat->{"letter$i"}){$row{"letter$i"}=$dat->{"letter$i"};}
            }
            if ($dat->{"delay$i"}){$row{"delay$i"}=$dat->{"delay$i"};}
            if ($dat->{"debarred$i"}){$row{"debarred$i"}=$dat->{"debarred$i"};}
        }
        $sth2->finish;
    }
    push @line_loop,\%row;
}
$sth->finish;

$template->param(table=> \@line_loop,
                branchloop => \@branchloop,
                branch => $branch);
output_html_with_http_headers $input, $cookie, $template->output;
