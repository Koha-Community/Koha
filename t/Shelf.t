BEGIN { $| = 1; print "1..25\n"; }
END {print "not ok 1\n" unless $loaded;}
use C4::Shelf;
use C4::Context;
$loaded = 1;
print "ok 1\n";



# Load some sample data from the items table
my $itemdata;
my $dbh=C4::Context->dbh();
my $sth=$dbh->prepare("select biblionumber,biblioitemnumber,itemnumber from items limit 30");
$sth->execute;
while (my ($biblionumber, $biblioitemnumber, $itemnumber) = $sth->fetchrow) {
    push @$itemdata, { biblionumber=>$biblionumber, biblioitemnumber=>$biblioitemnumber, itemnumber=>$itemnumber };
}

if ($itemdata=~/^ARRAY/) {
    print "ok 2\n";
} else {
    print "not ok 2\n";
}



# Create a couple of new shelves

my $shelf=Shelf->new('Shelf1', -1);
my $shelf2=Shelf->new('Shelf2', -1);

if (defined $shelf) {
    print "ok 3\n";
} else {
    print "not ok 3\n";
}


# Add an item to a shelf


for ($i=1; $i<20; $i++) {
    $shelf->addtoshelf( -add => [[ $$itemdata[$i]->{biblionumber},
				   $$itemdata[$i]->{biblioitemnumber},
				   $$itemdata[$i]->{itemnumber} ]]);
}

