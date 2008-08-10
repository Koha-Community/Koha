#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Context;
use C4::Output;
use C4::Labels;
use HTML::Template::Pro;
use POSIX;

#use Data::Dumper;
#use Smart::Comments;

my $dbh       = C4::Context->dbh;
my $query     = new CGI;
my $layout_id = $query->param('layout_id');

### $query;

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "labels/label-edit-layout.tmpl",
        query           => $query,
        type            => "intranet",
        authnotrequired => 1,
        flagsrequired   => { catalogue => 1 },
        debug           => 1,
    }
);

my $layout        = get_layout($layout_id);
my @barcode_types = get_barcode_types($layout_id);
my @printingtypes = get_printingtypes($layout_id);
### @printingtypes 
### $layout

   $layout_id  = $layout->{'id'};	# has it changed since we set it above?  --joe
my $layoutname = $layout->{'layoutname'};
my $guidebox   = $layout->{'guidebox'};
my $startlabel = $layout->{'startlabel'};

my @title          = build_text_dropbox( $layout->{'title'} );
my @subtitle       = build_text_dropbox( $layout->{'subtitle'} );
my @author         = build_text_dropbox( $layout->{'author'} );
my @barcode        = build_text_dropbox( $layout->{'barcode'} );
my @isbn           = build_text_dropbox( $layout->{'isbn'} );
my @issn           = build_text_dropbox( $layout->{'issn'} );
my @itemtype       = build_text_dropbox( $layout->{'itemtype'} );
my @dewey          = build_text_dropbox( $layout->{'dewey'} );
my @class          = build_text_dropbox( $layout->{'class'} );
my @subclass       = build_text_dropbox( $layout->{'subclass'} );
my @itemcallnumber = build_text_dropbox( $layout->{'itemcallnumber'} );

### @subclass 

$template->param(
	barcode_types => \@barcode_types,
	printingtypes => \@printingtypes,
	layoutname    => $layoutname,
	layout_id     => $layout_id,
	guidebox      => $guidebox,
	startlabel    => $startlabel,
    formatstring    =>  $layout->{'formatstring'},
    callnum_split   =>  $layout->{'callnum_split'},
    'justify_' . $layout->{'text_justify'} => 1,
    tx_title          => \@title,
    tx_subtitle       => \@subtitle,
    tx_author         => \@author,
    tx_isbn           => \@isbn,
    tx_issn           => \@issn,
    tx_itemtype       => \@itemtype,
    tx_dewey          => \@dewey,
    tx_barcode        => \@barcode,
    tx_classif        => \@class,
    tx_subclass       => \@subclass,
    tx_itemcallnumber => \@itemcallnumber,
);

output_html_with_http_headers $query, $cookie, $template->output;
