#!/usr/bin/perl

#written 11/3/2002 by Finlay
#script to execute branch transfers of books

use strict;
use CGI;
use C4::Circulation::Circ2;
use C4::Output;

###############################################
# constants

my %env;
my $headerbackgroundcolor='#99cc33';
my $circbackgroundcolor='#ffffcc';
my $circbackgroundcolor='white';
my $linecolor1='#ffffcc';
my $linecolor2='white';
my $backgroundimage="/images/background-mem.gif";

my $branches=getbranches();

###############################################
#  Getting state

my $query=new CGI;

my $tobranchcd=$query->param('tobranchcd');
my $frbranchcd='';


# set up the branchselect options....
my $tobranchoptions;
foreach my $br (keys %$branches) {
    (next) if $branches->{$br}->{'PE'};
    my $selected='';
    ($selected='selected') if ($br eq $tobranchcd);
    $tobranchoptions.="<option value=$br $selected>$branches->{$br}->{'branchname'}\n";
}

# collect the stack of books already transfered so they can printed...
my %transfereditems;
my $ritext = '';
my %frbranchcds;
my %tobranchcds;
foreach ($query->param){
    (next) unless (/bc-(\d*)/);
    my $counter=$1;
    my $barcode=$query->param("bc-$counter");
    my $frbcd=$query->param("fb-$counter");
    my $tobcd=$query->param("tb-$counter");
    $counter++;
    $transfereditems{$counter}=$barcode;
    $frbranchcds{$counter}=$frbcd;
    $tobranchcds{$counter}=$tobcd;
    $ritext.="<input type=hidden name=bc-$counter value=$barcode>\n";
    $ritext.="<input type=hidden name=fb-$counter value=$frbcd>\n";
    $ritext.="<input type=hidden name=tb-$counter value=$tobcd>\n";
    }

# Warnings etc that get displayed at top of next page....
my @messages;

#if the barcode has been entered action that and write a message and onto the top of the stack...
my $iteminformation;
if (my $barcode=$query->param('barcode')) {
    my $iteminformation = getiteminformation(\%env,0 ,$barcode);
    my ($transfered, $message, $iteminformation) = transferbook($tobranchcd, $barcode);
    if (not $transfered) {
	push(@messages, $message);
    }
    else {
	my $frbranchcd = $iteminformation->{'holdingbranch'};
	$ritext.="<input type=hidden name=bc-0 value=$barcode>\n";
	$ritext.="<input type=hidden name=fb-0 value=$frbranchcd>\n";
	$ritext.="<input type=hidden name=tb-0 value=$tobranchcd>\n";
	$transfereditems{0}=$barcode;
	$frbranchcds{0}=$frbranchcd;
	$tobranchcds{0}=$tobranchcd;
	push(@messages, "Book: $barcode has been transfered");
    }
}

#################################################################################
# Html code....

my $entrytext= << "EOF";
<form method=post action=/cgi-bin/koha/circ/branchtransfers.pl>
<table border=1 cellpadding=5 cellspacing=0 align=left>
<tr><td colspan=2 align=center background=$backgroundimage>
<font color=black><b>Select Branch</b></font></td></tr>
<tr><td>Destination Branch:</td>
    <td><select name=tobranchcd> $tobranchoptions </select></td></tr></table>    

<img src="/images/holder.gif" width=24 height=50 align=left>

<table border=1 cellpadding=5 cellspacing=0 ><tr>
<td colspan=2 align=center background=$backgroundimage>
<font color=black><b>Enter Book Barcode</b></font></td></tr>
<tr><td>Item Barcode:</td><td><input name=barcode size=10></td></tr>
</table>
<input type=hidden name=tobranchcd value=$tobranchcd>
$ritext
</form>
EOF

my $messagetable;
if (@messages) {
    my $messagetext='';
    foreach (@messages) {
	$messagetext.="$_<br>";
    }
    $messagetext = substr($messagetext, 0, -4);
    $messagetable = << "EOF";
<table border=1 cellpadding=5 cellspacing=0 bgcolor='#dddddd'>
<tr><th bgcolor=$headerbackgroundcolor background=$backgroundimage><font>Messages</font></th></tr>
<tr><td> $messagetext </td></tr></table>
EOF
}

#######################################################################################
# Make the page .....

print $query->header;
print startpage;
print startmenu('circulation');
print <<"EOF";
<p align=right>
<FONT SIZE=2  face="arial, helvetica">
<a href=circulationold.pl?module=issues>Next Borrower</a> ||
<a href=returns.pl>Returns</a> ||
<a href=branchtransfers.pl>Transfers</a></font></p><FONT SIZE=6><em>Circulation: Transfers</em></FONT><br>
EOF

print $messagetable;

print $entrytext;

if (%transfereditems) {
    print << "EOF"; 
<p>
<table border=1 cellpadding=5 cellspacing=0 bgcolor=#dddddd>                                                                
<tr><th colspan=6 bgcolor=$headerbackgroundcolor background=$backgroundimage><font color=black>Transfered Items</font></th></tr>
<tr><th>Bar Code</th><th>Title</th><th>Author</th><th>Type</th><th>From</th><th>To</th></tr>
EOF
    my $color='';
    foreach (keys %transfereditems) {
	($color eq $linecolor1) ? ($color=$linecolor2) : ($color=$linecolor1);
	my $barcode=$transfereditems{$_};
	my $frbcd=$frbranchcds{$_};
	my $tobcd=$tobranchcds{$_};
	my ($iteminformation) = getiteminformation(\%env, 0, $barcode);
	print << "EOF";
<tr><td bgcolor=$color align=center>
<a href=/cgi-bin/koha/detail.pl?bib=$iteminformation->{'biblionumber'}
&type=intra onClick=\"openWindow(this, 'Item', 480, 640)\">$barcode</a></td>
<td bgcolor=$color>$iteminformation->{'title'}</td>
<td bgcolor=$color>$iteminformation->{'author'}</td>
<td bgcolor=$color align=center>$iteminformation->{'itemtype'}</td>
<td bgcolor=$color align=center>$branches->{$frbcd}->{'branchname'}</td>
<td bgcolor=$color align=center>$branches->{$tobcd}->{'branchname'}</td>
</tr>\n
EOF
}
    print "</table>\n";
}

print endmenu('circulation');
print endpage;

