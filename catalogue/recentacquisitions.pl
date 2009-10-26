#!/usr/bin/perl

#attention fichier pour notices MARC21

use strict;
use warnings;

use C4::Context;
use C4::Search;
use MARC::File::XML;
#use XML::LibXML;
#use XML::LibXSLT;
use CGI;
use C4::Dates;
use Date::Calc;
use C4::Auth;
use C4::Output;
use C4::Koha;

my $query= new CGI;
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "catalogue/recentacquisitions.tmpl",
        query           => $query,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => {catalogue => 1},
        debug           => 1,
    }
);

my $op = $query->param('op') || '';
if ($op eq "show_list"){

    my $datebegin           = C4::Dates->new($query->param('datebegin'));
    my $dateend             = C4::Dates->new($query->param('dateend')) if ($query->param('dateend'));

    my $orderby             = $query->param('orderby') if ($query->param('orderby'));
    my $criteria            = $query->param('criteria');
    my @itemtypes           = $query->param('itemtypes');
    
    
    my $loopacquisitions = SearchAcquisitions($datebegin, $dateend, \@itemtypes,
                                                $criteria, $orderby);
    
    $template->param(loopacquisitions=>$loopacquisitions,
                     show_list=>1);
} else {
    my $period      = C4::Context->preference("recentacquisitionregularPeriod")||30;
    my $dateend     = C4::Dates->new();
    #warn " dateend :".$dateend->output("syspref");
    my @dateend     = Date::Calc::Today;
    my @datebegin   = Date::Calc::Add_Delta_Days(@dateend,-$period) if ($period);
    my $datebegin   = C4::Dates->new(sprintf("%04d-%02d-%02d",@datebegin[0..2]),'iso');
    #warn 'datebegin :'.$datebegin->output("syspref")." dateend :".$dateend->output("syspref");
    my $itemtypes   = GetItemTypes;
    
    my @itemtypesloop;
    my $selected=1;
    my $cnt;
    my $imgdir = getitemtypeimagesrc();
    
    foreach my $thisitemtype ( sort {$itemtypes->{$a}->{'description'} cmp $itemtypes->{$b}->{'description'} } keys %$itemtypes ) {
        my %row =(  number=>$cnt++,
                    imageurl=> $itemtypes->{$thisitemtype}->{'imageurl'}?($imgdir."/".$itemtypes->{$thisitemtype}->{'imageurl'}):"",
                    code => $thisitemtype,
                    selected => $selected,
                    description => $itemtypes->{$thisitemtype}->{'description'},
                    count5 => $cnt % 4,
                );
        $selected = 0 if ($selected) ;
        push @itemtypesloop, \%row;
    }
    
    $template->param(datebegin  => $datebegin->output("syspref"),
                     dateend    => $dateend->output("syspref"),);
    $template->param(period                   => $period,
                     itemtypeloop             => \@itemtypesloop,
                     DHTMLcalendar_dateformat => C4::Dates->DHTMLcalendar(),        
                    );
          
}
output_html_with_http_headers $query, $cookie, $template->output;

