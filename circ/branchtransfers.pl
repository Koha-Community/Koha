#!/usr/bin/perl

#written 11/3/2002 by Finlay
#script to execute branch transfers of books

use strict;
use CGI;
use C4::Circulation::Circ2;
use C4::Search;
use C4::Output;


my %env;
my $headerbackgroundcolor='#99cc33';
my $circbackgroundcolor='#ffffcc';
my $circbackgroundcolor='white';
my $linecolor1='#ffffcc';
my $linecolor2='white';
my $backgroundimage="/images/background-mem.gif";

my $query=new CGI;
my $branches=getbranches(\%env);

my $tobranchcd=$query->param('tobranchcd');
my $frbranchcd='';

$env{'tobranchcd'}=$tobranchcd;


my $tobranchoptions;
foreach (keys %$branches) {
        (next) unless ($_);
        (next) if (/^TR$/);
        my $selected='';
        ($selected='selected') if ($_ eq $tobranchcd);
        $tobranchoptions.="<option value=$_ $selected>$branches->{$_}->{'branchname'}\n";
}

# collect the stack of books already transfered so they can printed...
my %transfereditems;
my $ritext = '';
my %frbranchcds;
my %tobranchcds;
foreach ($query->param){
    (next) unless (/bc-(\d*)/);
    my $counter=$1;
    (next) if ($counter>20);
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

#if the barcode has been entered action that and write a message and onto the top of the stack...
my $iteminformation;
my @messages;
my $todaysdate;
if (my $barcode=$query->param('barcode')) {
    my $iteminformation = getiteminformation(\%env,0, $barcode);
    my $fail=0;
    if (not $iteminformation) {
	$fail=1;
	@messages = ("There is no book with barcode: $barcode ", @messages);
    }
    $frbranchcd = $iteminformation->{'holdingbranch'};
    %env->{'frbranchcd'} = $frbranchcd;
    if ($frbranchcd eq $tobranchcd) {
	$fail=1;
	@messages = ("You can't transfer the book to the branch it is already at!", @messages);
    }
# should add some more tests ... like is the book already out, maybe it cant be moved....
    if (not $fail) {
	my ($transfered, $message) = transferbook(\%env, $iteminformation, $barcode);
	if (not $transfered) {@messages = ($message, @messages);}
	else {
	    $ritext.="<input type=hidden name=bc-0 value=$barcode>\n";
	    $ritext.="<input type=hidden name=fb-0 value=$frbranchcd>\n";
	    $ritext.="<input type=hidden name=tb-0 value=$tobranchcd>\n";
	    $transfereditems{0}=$barcode;
	    $frbranchcds{0}=$frbranchcd;
	    $tobranchcds{0}=$tobranchcd;
	    @messages = ("Book: $barcode has been transfered", @messages);
	}
    }
}

my $entrytext= << "EOF";
<form method=post action=/cgi-bin/koha/circ/branchtransfers.pl>
<table border=0 cellpadding=5 cellspacing=0 bgcolor=#dddddd >
<tr><td colspan=2 bgcolor=$headerbackgroundcolor align=center background=$backgroundimage>
<font color=black><b>Select Branch</b></font></td></tr>
<tr><td>Destination Branch:</td><td>
 <select name=tobranchcd> $tobranchoptions </select>
</td></tr>

</table><table border=0 cellpadding=5 cellspacing=0 bgcolor=#dddddd >
<tr><td colspan=2 bgcolor=$headerbackgroundcolor align=center background=$backgroundimage>
<font color=black><b>Enter Book Barcode</b></font></td></tr>
<tr><td>Item Barcode:</td><td><input name=barcode size=10></td></tr>
</table>

<input type=hidden name=tobranchcd value=$tobranchcd>
$ritext
EOF

my $messagetable;
if (@messages) {
    my $messagetext='';
    foreach (@messages) {
	$messagetext.="$_<p>\n";
    }
    $messagetable = << "EOF";
<table border=0 cellpadding=5 cellspacing=0 bgcolor='#dddddd'>
<tr><th bgcolor=$headerbackgroundcolor background=$backgroundimage><font color=black>Messages</font></th></tr>
<tr><td> $messagetext </td></tr></table>
EOF
}



print $query->header;
print startpage;
print startmenu('circulation');
print "<h3>Branch Transfers</h3>";


print $messagetable if (@messages);


print $entrytext;

if (%transfereditems) {
    print << "EOF"; 
<p>
<table border=0 cellpadding=5 cellspacing=0 bgcolor=#dddddd>                                                                
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


############################################################################
#
# this is the database query that will go into C4::Circuation::Circ2
#

use DBI;
use C4::Database;

sub transferbook {
    my ($env, $iteminformation, $barcode) = @_;
    my $messages;
    my $dbh=&C4Connect;
    #new entry in branchtransfers....
    my $sth = $dbh->prepare("insert into branchtransfers (itemnumber, frombranch, datearrived, tobranch) values($iteminformation->{'itemnumber'}, '$env->{'frbranchcd'}', now(), '$env->{'tobranchcd'}')");
    $sth->execute || return (0,"database error: $sth->errstr");
    $sth->finish;
    #update holdingbranch in items .....
    $sth = $dbh->prepare("update items set holdingbranch='$env->{'tobranchcd'}' where items.itemnumber=$iteminformation->{'itemnumber'}");
    $sth->execute || return (0,"database error: $sth->errstr");
    $sth->execute;
    $sth->finish;
    $dbh->disconnect;
    return (1, $messages);
}


