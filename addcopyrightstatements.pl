#!/usr/bin/perl
#
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

my $copyrightstatement=qq|
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

|;

open (PL, "find -name '*.pl' -o -name '*.pm'|");
while (<PL>) {
    my $filename=$_;
    chomp $filename;
    my $holder='';
    my $newversion='';
    open (IN, "$filename");
    my $begin='';
    my $end='';
    my $alreaddone=0;
    while (<IN>) {
	if ((/^\s*#/ || /^\s*$/ || /^\s*package/) && $end eq '') {
	    $begin.=$_;
	} else {
	    $end.=$_;
	}
	if (/^\s*#\s*Copyright/) {
	    print "$filename already has a copyright statement\n";
	    $alreadydone=1;
	}
    }
    close IN;
    unless ($alreadydone) {
	open (OUT, ">$filename");
	print OUT "$begin$copyrightstatement$end";
	close OUT;
    }
}
