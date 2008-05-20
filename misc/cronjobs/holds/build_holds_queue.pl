#!/usr/bin/perl 
#-----------------------------------
# Script Name: build_holds_queue.pl
# Description: builds a holds queue in the tmp_holdsqueue table
#-----------------------------------

use strict;
BEGIN {
    # find Koha's Perl modules
    # test carefully before changing this
    use FindBin;
    eval { require "$FindBin::Bin/../kohalib.pl" };
}

use C4::Context;
use C4::Search;
use C4::Items;
use C4::Branch;

# load the branches
my $branches = GetBranches();

# obtain the ranked list of weights for the case of static weighting
my $syspref = C4::Context->preference("StaticHoldsQueueWeight");
my @branch_loop;
#@branch_loop = split(/,/, $syspref) if $syspref;

# TODO: Add Randomization Option

# If no syspref is set, use system-order to determine priority
unless ($syspref) {
	for my $branch_hash (sort keys %$branches) {
    	push @branch_loop, $branch_hash;
		#{value => "$branch_hash" , branchname => $branches->{$branch_hash}->{'branchname'}, };
	}
}

# if Randomization is enabled, randomize this array
@branch_loop = randarray(@branch_loop) if  C4::Context->preference("RandomizeHoldsQueueWeight");;

my ($biblionumber,$itemnumber,$barcode,$holdingbranch,$pickbranch,$notes,$cardnumber,$surname,$firstname,$phone,$title,$callno,$rdate,$borrno);

my $dbh   = C4::Context->dbh;

$dbh->do("DELETE FROM tmp_holdsqueue");  # clear the old table for new info

my $sth=$dbh->prepare("
SELECT biblionumber,itemnumber,reserves.branchcode,reservenotes,borrowers.borrowernumber,cardnumber,surname,firstname,phone,reservedate
    FROM reserves,borrowers 
WHERE reserves.found IS NULL 
    AND reserves.borrowernumber=borrowers.borrowernumber 
    AND priority=1 
GROUP BY biblionumber");

my $sth_load=$dbh->prepare("
INSERT INTO tmp_holdsqueue (biblionumber,itemnumber,barcode,surname,firstname,phone,borrowernumber,cardnumber,reservedate,title,itemcallnumber,holdingbranch,pickbranch,notes)
    VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?)");

$sth->execute();      # get the list of biblionumbers for unfilled holds

GETIT: 
while (my $data=$sth->fetchrow_hashref){
    # get the basic hold info
    $biblionumber = $data->{'biblionumber'};
    $pickbranch = $data->{'branchcode'};
    $notes = $data->{'reservenotes'};
    $borrno = $data->{'borrowernumber'};
    $cardnumber = $data->{'cardnumber'};
    $surname = $data->{'surname'};
    $firstname = $data->{'firstname'};
    $phone = $data->{'phone'};
    $rdate = $data->{'reservedate'};

    my @items = GetItemsInfo($biblionumber,''); # get the items for this biblio
    my @itemorder;   #  prepare a new array to hold re-ordered items
        
    # Make sure someone(else) doesn't already have this item waiting for them
    my $found_sth = $dbh->prepare("
	SELECT found FROM reserves WHERE itemnumber=? AND found = ? AND cancellationdate IS NULL");
        
    # The following lines take the retrieved items and run them through various
    # tests to decide if they are to be used and then put them in the preferred
    # 'pick' order.
    foreach my $itm (@items) {

        $found_sth->execute($itm->{itemnumber},"W");
        my $found = $found_sth->fetchrow_hashref();
        if ($found) {
            $itm->{"found"} = $found->{"found"};
        }
        if ($itm->{"notforloan"}) {
			# item is on order
            next if $itm->{"notforloan"}== -1;
        }
        if ( ( (!$itm->{"binding"}) || 
		# Item is at not at bindery, not checked out, and not lost
		($itm->{"binding"}<1)) && (!$itm->{"found"}) && (!$itm->{"datedue"}) && ( (!$itm->{"itemlost"}) || 

		# Item is not lost and not notforloan
		($itm->{"itemlost"}==0) ) && ( ($itm->{"notforloan"}==0) || 

		# Item is not notforloan
		(!$itm->{"notforloan"}) ) ) {

            warn "patron requested pickup at $pickbranch for item in ".$itm->{'holdingbranch'};

			# This selects items for fulfilment, and weights them based on
			# a static list
			my $weight=0;
			# always prefer a direct match
            if ($itm->{'holdingbranch'} eq $pickbranch) {
				warn "Found match in pickuplibrary";
                $itemorder[$weight]=$itm;
            } 
			else {
				for my $branchcode (@branch_loop) {
					$weight++;
					if ($itm->{'homebranch'} eq $branchcode) {
						warn "Match found with weight $weight in ".$branchcode;
                		$itemorder[$weight]=$itm;
					}
				}
            }
        }
    }
    my $count = @itemorder;
	warn "Empty array" if $count<1;
    next GETIT if $count<1;  # if the re-ordered array is empty, skip to next

    PREP: 
    foreach my $itmlist (@itemorder) {
        if ($itmlist) {
            $barcode = $itmlist->{'barcode'};
			$itemnumber = $itmlist->{'itemnumber'};
            $holdingbranch = $itmlist->{'holdingbranch'};
            $title = $itmlist->{'title'};
            $callno = $itmlist->{'itemcallnumber'};
            last PREP;    # we only want the first def item in the array
        }
    }
    $sth_load->execute($biblionumber,$itemnumber,$barcode,$surname,$firstname,$phone,$borrno,$cardnumber,$rdate,$title,$callno,$holdingbranch,$pickbranch,$notes);
    $sth_load->finish;
}
$sth->finish;
$dbh->disconnect;

sub randarray {
        my @array = @_;
        my @rand = undef;
        my $seed = $#array + 1;
        my $randnum = int(rand($seed));
        $rand[$randnum] = shift(@array);
        while (1) {
                my $randnum = int(rand($seed));
                if ($rand[$randnum] eq undef) {
                        $rand[$randnum] = shift(@array);
                }
                last if ($#array == -1);
        }
        return @rand;
}


print "finished\n";
