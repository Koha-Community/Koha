#!/usr/bin/perl

#  This script loops through each overdue item, determines the fine,
#  and updates the total amount of fines due by each user.  It relies on
#  the existence of /tmp/fines, which is created by ???
# Doesnt really rely on it, it relys on being able to write to /tmp/
# It creates the fines file
#
#  This script is meant to be run nightly out of cron.

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


# FIXME: use FinesMode as described or change syspref description
use strict;

BEGIN {
    # find Koha's Perl modules
    # test carefully before changing this
    use FindBin;
    eval { require "$FindBin::Bin/kohalib.pl" };
}

use Date::Calc qw/Date_to_Days/;

use C4::Context;
use C4::Circulation;
use C4::Overdues;
use C4::Calendar qw();  # don't need any exports from Calendar
use C4::Biblio;
use C4::Debug;  # supplying $debug and $cgi_debug

use vars qw(@borrower_fields @item_fields @other_fields);
use vars qw($fldir $libname $control $mode $delim $dbname $today $today_iso $today_days);
use vars qw($filename $summary);

CHECK {
    @borrower_fields = qw(cardnumber categorycode surname firstname email phone address citystate);
        @item_fields = qw(itemnumber barcode date_due);
       @other_fields = qw(type days_overdue fine);
    $libname = C4::Context->preference('LibraryName');
    $control = C4::Context->preference('CircControl');
    $mode    = C4::Context->preference('finesMode');
    $dbname  = C4::Context->config('database');
    $delim   = "\t"; # ?  C4::Context->preference('delimiter') || "\t";

    $today = C4::Dates->new();
    $today_iso = $today->output('iso');
    $today_days = Date_to_Days(split(/-/,$today_iso));
    $fldir = $ENV{TMPDIR} || "/tmp"; # TODO: use GetOpt
    $filename = $dbname;
    $filename =~ s/\W//;
    $filename = $fldir . '/'. $filename . '_' .  $today_iso . ".log";
    $summary = 1;  # TODO: use GetOpt
}

INIT {
    $debug and print "Each line will contain the following fields:\n",
        "From borrowers : ", join(', ', @borrower_fields), "\n",
        "From items : ", join(', ', @item_fields), "\n",
        "Per overdue: ", join(', ', @other_fields), "\n",
        "Delimiter: '$delim'\n";
}

open (FILE, ">$filename") or die "Cannot write file $filename: $!";
print FILE join $delim, (@borrower_fields, @item_fields, @other_fields);
print FILE "\n";

my $data = Getoverdues();
my $overdueItemsCounted = 0;
my %calendars = ();

for (my $i=0; $i<scalar(@$data); $i++) {
    my $datedue = C4::Dates->new($data->[$i]->{'date_due'},'iso');
    my $datedue_days = Date_to_Days(split(/-/,$datedue->output('iso')));
    my $due_str = $datedue->output();
    my $borrower = BorType($data->[$i]->{'borrowernumber'});
    my $branchcode = ($control eq 'ItemHomeLibrary') ? $data->[$i]->{homebranch} :
                     ($control eq 'PatronLibrary'  ) ?   $borrower->{branchcode} :
                                                       $data->[$i]->{branchcode} ;
    # In final case, CircControl must be PickupLibrary. (branchcode comes from issues table here).
    my $calendar;
    unless (defined ($calendars{$branchcode})) {
        $calendars{$branchcode} = C4::Calendar->new(branchcode => $branchcode);
    }
    $calendar = $calendars{$branchcode};
    my $isHoliday = $calendar->isHoliday(split '/', $today->output('metric'));
      
    ($datedue_days <= $today_days) or next; # or it's not overdue, right?

    $overdueItemsCounted++;
    my ($amount,$type,$daycounttotal,$daycount)=
  		CalcFine($data->[$i], $borrower->{'categorycode'}, $branchcode,undef,undef, $datedue, $today);
        # FIXME: $type NEVER gets populated by anything.
    (defined $type) or $type = '';
	# Don't update the fine if today is a holiday.  
  	# This ensures that dropbox mode will remove the correct amount of fine.
	if ($mode eq 'production' and  ! $isHoliday) {
		UpdateFine($data->[$i]->{'itemnumber'},$data->[$i]->{'borrowernumber'},$amount,$type,$due_str) if( $amount > 0 ) ;
 	}
    my @cells = ();
    push @cells, map {$borrower->{$_}} @borrower_fields;
    push @cells, map {$data->[$i]->{$_}} @item_fields;
    push @cells, $type, $daycounttotal, $amount;
    print FILE join($delim, @cells), "\n";
}

my $numOverdueItems = scalar(@$data);
if ($summary) {
   print <<EOM;
Fines assessment -- $today_iso -- Saved to $filename
Number of Overdue Items:
     counted $overdueItemsCounted
    reported $numOverdueItems

EOM
}

close FILE;
