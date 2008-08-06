#!/usr/bin/perl

# Copyright 2007 Liblime Ltd
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

# Script to take some borrowers data in a known format and load it into Koha
#
# File format
#
# cardnumber,surname,firstname,title,othernames,initials,streetnumber,streettype,
# address line , address line 2, city, zipcode, email, phone, mobile, fax, work email, work phone,
# alternate streetnumber, alternate streettype, alternate address line 1, alternate city,
# alternate zipcode, alternate email, alternate phone, date of birth, branchcode,
# categorycode, enrollment date, expiry date, noaddress, lost, debarred, contact surname,
# contact firstname, contact title, borrower notes, contact relationship, ethnicity, ethnicity notes
# gender, username, opac note, contact note, password, sort one, sort two
#
# any fields except cardnumber can be blank but the number of fields must match
# dates should be in the format you have set up Koha to expect
# branchcode and categorycode need to be valid

use strict;
use C4::Auth;
use C4::Output;
use C4::Dates qw(format_date_in_iso);
use C4::Context;
use C4::Members;
use C4::Members::Attributes;
use C4::Members::AttributeTypes;

use Text::CSV;
use CGI;

my @errors;
my $extended = C4::Context->preference('ExtendedPatronAttributes');
my @columnkeys = C4::Members->columns;
if ($extended) {
    push @columnkeys, 'patron_attributes';
}
my $columnkeystpl = [ map { {'key' => $_} } @columnkeys ];  # ref. to array of hashrefs.

my $input = CGI->new();
my $csv   = Text::CSV->new();

my ( $template, $loggedinuser, $cookie ) = get_template_and_user({
        template_name   => "tools/import_borrowers.tmpl",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { tools => 'import_patrons' },
        debug           => 1,
});

$template->param(columnkeys => $columnkeystpl);

if ($input->param('sample')) {
    print $input->header(
        -type       => 'application/vnd.sun.xml.calc', # 'application/vnd.ms-excel' ?
        -attachment => 'patron_import.csv',
    );
    $csv->combine(@columnkeys);
    print $csv->string, "\n";
    exit 1;
}
my $uploadborrowers      = $input->param('uploadborrowers');
my $matchpoint           = $input->param('matchpoint');
if ($matchpoint) {
    $matchpoint =~ s/^patron_attribute_//;
}
my $overwrite_cardnumber = $input->param('overwrite_cardnumber');

$template->param( SCRIPT_NAME => $ENV{'SCRIPT_NAME'} );

($extended) and $template->param(ExtendedPatronAttributes => 1);

if ( $uploadborrowers && length($uploadborrowers) > 0 ) {
    my $imported    = 0;
    my $alreadyindb = 0;
    my $overwritten = 0;
    my $invalid     = 0;
    my $matchpoint_attr_type; 
    my %defaults = $input->Vars;

    # use header line to construct key to column map
    my $borrowerline = <$uploadborrowers>;
    my $status = $csv->parse($borrowerline);
    ($status) or push @errors, {badheader=>1,line=>$., lineraw=>$borrowerline};
    my @csvcolumns = $csv->fields();
    my %csvkeycol;
    my $col = 0;
    foreach my $keycol (@csvcolumns) {
    	# columnkeys don't contain whitespace, but some stupid tools add it
    	$keycol =~ s/ +//g;
        $csvkeycol{$keycol} = $col++;
    }
    #warn($borrowerline);

    if ($extended) {
        $matchpoint_attr_type = C4::Members::AttributeTypes->fetch($matchpoint);
    }

    my @criticals = qw(surname);    # there probably should be others
    my @errors;
    LINE: while ( my $borrowerline = <$uploadborrowers> ) {
        my %borrower;
        my @missing_criticals;
        my $patron_attributes;
        my $status  = $csv->parse($borrowerline);
        my @columns = $csv->fields();
        if (! $status) {
            push @missing_criticals, {badparse=>1, line=>$., lineraw=>$borrowerline};
        } elsif (@columns == @columnkeys) {
            @borrower{@columnkeys} = @columns;
        } else {
            # MJR: try to recover gracefully by using default values
            foreach my $key (@columnkeys) {
            	if (defined($csvkeycol{$key}) and $columns[$csvkeycol{$key}] =~ /\S/) { 
            	    $borrower{$key} = $columns[$csvkeycol{$key}];
            	} elsif ( $defaults{$key} ) {
            	    $borrower{$key} = $defaults{$key};
            	} elsif ( scalar grep {$key eq $_} @criticals ) {
            	    # a critical field is undefined
            	    push @missing_criticals, {key=>$key, line=>$., lineraw=>$borrowerline};
            	} else {
            		$borrower{$key} = '';
            	}
            }
        }
        #warn join(':',%borrower);
        if (@missing_criticals) {
            foreach (@missing_criticals) {
                $_->{borrowernumber} = $borrower{borrowernumber} || 'UNDEF';
                $_->{surname}        = $borrower{surname} || 'UNDEF';
            }
            $invalid++;
            (25 > scalar @errors) and push @errors, {missing_criticals=>\@missing_criticals};
            # The first 25 errors are enough.  Keeping track of 30,000+ would destroy performance.
            next LINE;
        }
        my @attrs;
        if ($extended) {
            my $attr_str = $borrower{patron_attributes};
            delete $borrower{patron_attributes};
            my $ok = $csv->parse($attr_str);
            my @list = $csv->fields();
            # FIXME error handling
            $patron_attributes = [ map { map { my @arr = split /:/, $_, 2; { code => $arr[0], value => $arr[1] } } $_ } @list ];
        }
        foreach (qw(dateofbirth dateenrolled dateexpiry)) {
            my $tempdate = $borrower{$_} or next;
            $borrower{$_} = format_date_in_iso($tempdate) || '';
        }
        my $borrowernumber;
        if ($matchpoint eq 'cardnumber') {
            my $member = GetMember( $borrower{'cardnumber'}, 'cardnumber' );
            if ($member) {
                $borrowernumber = $member->{'borrowernumber'};
            }
        } elsif ($extended) {
            if (defined($matchpoint_attr_type)) {
                foreach my $attr (@$patron_attributes) {
                    if ($attr->{code} eq $matchpoint and $attr->{value} ne '') {
                        my @borrowernumbers = $matchpoint_attr_type->get_patrons($attr->{value});
                        $borrowernumber = $borrowernumbers[0] if scalar(@borrowernumbers) == 1;
                        last;
                    }
                }
            }
        }
            
        if ($borrowernumber) {
            # borrower exists
            unless ($overwrite_cardnumber) {
                $alreadyindb++;
                $template->param('lastalreadyindb'=>$borrower{'surname'}.' / '.$borrowernumber);
                next LINE;
            }
            $borrower{'borrowernumber'} = $borrowernumber;
            unless (ModMember(%borrower)) {
                $invalid++;
                $template->param('lastinvalid'=>$borrower{'surname'}.' / '.$borrowernumber);
                next LINE;
            }
            if ($extended) {
                C4::Members::Attributes::SetBorrowerAttributes($borrower{'borrowernumber'}, $patron_attributes);
            }
            $overwritten++;
            $template->param('lastoverwritten'=>$borrower{'surname'}.' / '.$borrowernumber);
        } else {
            # FIXME: fixup_cardnumber says to lock table, but the web interface doesn't so this doesn't either.
            # At least this is closer to AddMember than in members/memberentry.pl
            if (!$borrower{'cardnumber'}) {
                $borrower{'cardnumber'} = fixup_cardnumber('');
            }
            if ($borrowernumber = AddMember(%borrower)) {
                if ($extended) {
                    C4::Members::Attributes::SetBorrowerAttributes($borrowernumber, $patron_attributes);
                }
                $imported++;
                $template->param('lastimported'=>$borrower{'surname'}.' / '.$borrowernumber);
            } else {
                $invalid++;		# was just "$invalid", I assume incrementing was the point --atz
                $template->param('lastinvalid'=>$borrower{'surname'}.' / AddMember');
            }
        }
    }
    (@errors) and $template->param(ERRORS=>\@errors);
    $template->param(
        'uploadborrowers' => 1,
        'imported'        => $imported,
        'overwritten'     => $overwritten,
        'alreadyindb'     => $alreadyindb,
        'invalid'         => $invalid,
        'total'           => $imported + $alreadyindb + $invalid + $overwritten,
    );

} else {
    if ($extended) {
        my @matchpoints = ();
        my @attr_types = C4::Members::AttributeTypes::GetAttributeTypes();
        foreach my $type (@attr_types) {
            my $attr_type = C4::Members::AttributeTypes->fetch($type->{code});
            if ($attr_type->unique_id()) {
            push @matchpoints, { code =>  "patron_attribute_" . $attr_type->code(), description => $attr_type->description() };
            }
        }
        $template->param(matchpoints => \@matchpoints);
    }
}

output_html_with_http_headers $input, $cookie, $template->output;

