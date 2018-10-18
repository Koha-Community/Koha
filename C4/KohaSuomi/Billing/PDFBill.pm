package C4::KohaSuomi::Billing::PDFBill;

# This file is part of Koha.
#
# Copyright (C) 2016 Koha-Suomi Oy
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use strict;
use warnings;

use C4::Context;
use C4::Debug;
use C4::Letters;
use Koha::DateUtils;
use Koha::Logger;
use HTML::Template;
use C4::Templates;
use Koha::Patron::Message;
use File::Spec;
use Getopt::Long;
use Encode;
use Data::Dumper;
use C4::KohaSuomi::Billing::BillingManager;
use POSIX qw(strftime);

my $logger = Koha::Logger->get({category => __PACKAGE__});

use vars qw($VERSION @ISA @EXPORT);

BEGIN {
	# set the version for version checking
    $VERSION = 1.0;
	require Exporter;
	@ISA    = qw(Exporter);
	@EXPORT = qw(create_pdf check_item_fine check_billing_fine);
}

sub create_pdf {
	my (@billingdata) = @_;

    my $printed;
    my $fileplace = C4::Context->config('intranetdir');
    my $today = output_pref({ dt => dt_from_string, dateonly => 1, dateformat => 'iso' });
    my $letterTemplate = HTML::Template->new(filename => $fileplace.'/misc/cronjobs/iPostPDF/pdf_bill.tmpl');

    my $pdfFile;
    my $error;

	my ($letters, $lettercount) = parse_issues(@billingdata);
    foreach my $letterdata ($letters) {
        my $number = 0;
        if ($lettercount > 1) {
            $number = 1;
        }
        for (my $i=$number; $i <= $lettercount; $i++) {
            my $output_directory = $fileplace.'/koha-tmpl/static_content/claiming/';
            my ($letter, $borrowernumber, $branchdetail) = set_message($letterdata->{"letter".$i});
            if ($letter) {
                if ($borrowernumber || $borrowernumber ne '0') {
                    my $message_id = C4::Letters::EnqueueLetter(
                        {   letter                 => $letter,
                            borrowernumber         => $borrowernumber,
                            message_transport_type => 'print',
                            from_address           => $branchdetail->{branchemail},
                            to_address             => ''
                        }
                    );
                    my $message = GetMessage($message_id);

                    $message = claimingTemplate($message, $borrowernumber);

                    $pdfFile = $branchdetail->{branchcode}.$borrowernumber."_".$today. ".pdf";

                    $output_directory = $output_directory.$borrowernumber."/";

                    unless (mkdir ($output_directory, 0777)){
                        $logger->error("$output_directory could not be created!") if $logger->is_error();
                    }

                    $printed = print_pdf($message, $pdfFile, $letterTemplate, $output_directory);

                    if ($printed) {
                        my $pdfPath = "<a href = '/static_content/claiming/".$borrowernumber."/".$pdfFile."' target='_blank'>Print</a>";
                        if (!CheckMessageDate($borrowernumber, 'Asiakkaalla on laskutettua aineistoa', $today)) {
                            Koha::Patron::Message->new(
                                {
                                    borrowernumber => $borrowernumber,
                                    branchcode     => $branchdetail->{branchcode},
                                    message_type   => 'L',
                                    message        => 'Asiakkaalla on laskutettua aineistoa',
                                }
                            )->store;
                        }
                        C4::Letters::_set_message_status(
                            { message_id => $message->{'message_id'},
                            status => 'sent',
                            delivery_note => $pdfPath } );
                    } else {
                        $error = "PDF could not be created";
                        $logger->error("Something went wrong while creating the PDF!") if $logger->is_error();
                    }


                } else {
                    $error = "No borrowernumber";
                    $logger->error("Borrowernumber missing!") if $logger->is_error();
                }
            } else {
                $error = "Item was missing a replacement price, please fix it and try again!";
                $logger->error("Replacement price wasn't set!") if $logger->is_error();
            }
        }
    }
    unless ($error) {
        return 1;
    } else {
        return $error;
    }

}

sub parse_issues {
	my (@billingdata) = @_;

    $logger->trace("Parsing arrays") if $logger->is_trace();

	my %letterdata;
    my $index = 0;
    my $lettercount = 0;

	foreach my $data (@billingdata) {
        if ($data->{borrowernumber} ne $billingdata[$index-1]->{borrowernumber}) {
            $lettercount++;
        }
        push(@{$letterdata{"letter".$lettercount}}, $data);
        $index++;
	}

	return \%letterdata, $lettercount;

}

sub set_message {
    my ($content) = @_;

    $logger->trace("Setting letter") if $logger->is_trace();

    my $borrowernumber = $content->[0]->{borrowernumber};
    my $patron = Koha::Patrons->find($content->[0]->{issueborrower});
    my $substitute = {
        issueborname => $patron->firstname.' '.$patron->surname,
        issueborbarcode => $patron->cardnumber
    };

    my $branch = $content->[0]->{branchcode};

    my @items = set_content($content, $borrowernumber);

    my %tables = ( 'borrowers' => $borrowernumber, 'branches' => $branch );

    my $branchdetail = Koha::Libraries->find( $branch )->unblessed;
    unless(@items) {
        return (0, undef, undef);
    } else {
        return C4::Letters::GetPreparedLetter (
            module => 'circulation',
            letter_code => 'ODUECLAIM',
            branchcode => $branch,
            substitute => $substitute,
            tables => \%tables,
            repeat => { item => \@items },
            message_transport_type => 'print',
        ),
        $borrowernumber,
        $branchdetail
    }
}

sub set_content{
    my ($content, $borrowernumber) = @_;

    my @items;
    my @accountlines;
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("SELECT i.*, iss.*, b.*, bi.itemtype FROM items i
    JOIN issues iss on i.itemnumber = iss.itemnumber
    JOIN biblio b on i.biblionumber = b.biblionumber
    JOIN biblioitems bi on i.biblioitemnumber = bi.biblioitemnumber
    WHERE i.itemnumber = ?");
    my @item_tables;
    foreach my $data (@{$content}) {
        $sth->execute($data->{itemnumber});
        while (my $item = $sth->fetchrow_hashref) {
            $item->{replacementprice} = $data->{replacementprice};
            if ($item->{replacementprice} eq '0.00' or $item->{replacementprice} eq '0') {
                return;
            }
            unless(check_item_fine($borrowernumber, $item->{itemnumber}, $item->{replacementprice}, 'Korvaushinta', 'B')) {
                push @accountlines, {
                    'borrowernumber' => $borrowernumber,
                    'itemnumber' => $item->{itemnumber},
                    'replacementprice' => $item->{replacementprice},
                    'accounttype' => 'B',
                    'note' => 'Korvaushinta',
                    'biblionumber' => $item->{'biblionumber'},
                    'itemnumber' => $item->{'itemnumber'},
                }
            }


            push @item_tables, {
                'biblio' => $item->{'biblionumber'},
                'biblioitems' => $item->{'biblionumber'},
                'items' => $item,
                'issues' => $item->{'itemnumber'},
            };
        }

    }
    add_replacement_price(@accountlines);
    return @item_tables;
}

sub print_pdf {
    my ($message, $pdfFile, $template, $output_directory) = @_;

    $logger->trace("Printing message to PDF") if $logger->is_trace();

    $template->param(ITEMINFO => Encode::encode( "utf8", $message->{'content'}));

    open PDF, "| wkhtmltopdf.sh -q - " . $output_directory.$pdfFile or return 0;
    print PDF $template->output or return 0;
    close(PDF) or return 0;

    return 1;

}

sub claimingTemplate {
    my ($message, $borrowernumber) = @_;

    $logger->trace("Adding additional data to letter") if $logger->is_trace();

    my $now = strftime "%d%m%Y", localtime;
    my $timestamp = strftime "%d.%m.%Y %H:%M", localtime;

    my $totalfines = 0;

    my $billNumberTag = "MessageID";
    my $billNumber = $message->{message_id};

    $message->{'content'} =~ s/$billNumberTag/$billNumber/g;

    my $referenseNumberTag = "ReferenceNumber";
    my $referenseNumber = $message->{message_id}." ".$message->{'borrowernumber'}." ".$now;

    $message->{'content'} =~ s/$referenseNumberTag/$referenseNumber/g;

    my $DueDateTag = "DueDate";
    my $date = time;
    $date = $date + (14 * 24 * 60 * 60);
    my $DueDate = strftime "%d.%m.%Y", localtime($date);

    $message->{'content'} =~ s/$DueDateTag/$DueDate/g;

    my $removestart = "<code";
    my $removeend = "</code>";
    my @removematches = $message->{'content'} =~ /$removestart(.*?)$removeend/g;
    foreach my $removematch (@removematches) {
        my $itemnumber = substr($removematch, index($removematch, '"')+1, index($removematch, '">'));
        $itemnumber =~ s/\D//g;
        my $overduefine = OverduePrice($itemnumber);
        if(!check_item_fine($borrowernumber, $itemnumber, $overduefine, undef, 'FU')) {
            $message->{'content'} =~ s/$removestart$removematch$removeend//;
        }
    }
    my $start = "<var>";
    my $end = "</var>";

    my @matches = $message->{'content'} =~ /$start(.*?)$end/g;

    foreach my $match (@matches) {
        my $fine = $match;
        my $description;
        my $itemnumber;

        if ($match =~ /[\:]/g) {
            if ($match =~ /[\<]/g) {
                $fine = substr($match, index($match, ':')+1, index($match, '<'));
                $itemnumber = substr($match, index($match, '>')+1, index($match, '<'));
                $itemnumber =~ s/\D//g;
            }
            $fine = substr($match, index($match, ':')+2, length($match));

            $description = substr($match, 0, index($match, ':'));
            $description =~ s/^\s+|\s+$//g;
            if ($itemnumber) {
                unless (check_item_fine($borrowernumber, $itemnumber, $fine, $description, 'B')) {
                    C4::Accounts::manualinvoice($borrowernumber, $itemnumber, $description, 'B', $fine, $description);
                }
            } else {
                unless (check_billing_fine($borrowernumber, $fine, $description, 'B')) {
                    C4::Accounts::manualinvoice($borrowernumber, undef, $description, 'B', $fine, $description);
                }
            }

        }
        $totalfines = $totalfines + $fine;
        my $new_fine = $fine;
        $new_fine =~ tr/./,/;
        $message->{'content'} =~ s/$fine/$new_fine/g;
    }

    $totalfines = sprintf("%.2f", $totalfines);
    $totalfines =~ tr/./,/;

    $message->{'content'} =~ s/TotalFines/$totalfines/g;

    return $message;

}

sub check_item_fine {
    my ($borrowernumber, $itemnumber, $fine, $note, $accounttype) = @_;

    my $dbh = C4::Context->dbh;
    my $sth;
    if ($note && $fine) {
        $sth = $dbh->prepare("SELECT * FROM accountlines WHERE borrowernumber = ? and itemnumber = ? and amountoutstanding <= ? and amount = ? and accounttype = ? and note = ?");
        $sth->execute($borrowernumber, $itemnumber, $fine, $fine, $accounttype, $note);

    } else {
        $sth = $dbh->prepare("SELECT * FROM accountlines WHERE borrowernumber = ? and itemnumber = ? and accounttype = ? and amountoutstanding = ?");
        $sth->execute($borrowernumber, $itemnumber, $accounttype, $fine);
    }
    
    if (my $overdueprice = $sth->fetchrow_hashref){
        return 1;
    }
    $sth->finish;

    return;

}

sub check_billing_fine {
    my ($borrowernumber, $fine, $note, $accounttype) = @_;

    my $now = strftime "%Y-%m-%d", localtime;

    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("SELECT * FROM accountlines WHERE borrowernumber = ? and date = ? and amountoutstanding = ? and accounttype = ? and note = ?");
    $sth->execute($borrowernumber, $now, $fine, $accounttype, $note);
    if (my $overdueprice = $sth->fetchrow_hashref){
        return 1;
    }
    $sth->finish;

    return;

}

sub add_replacement_price {
    my (@accountlines) = @_;
    my $replacementConf = C4::Context->config("billingSetup")->{"replacementPrice"};
    if (defined $replacementConf && $replacementConf eq "yes") {
        foreach my $line (@accountlines) {
            C4::Accounts::manualinvoice($line->{borrowernumber}, $line->{itemnumber}, $line->{note}, $line->{accounttype}, $line->{replacementprice}, $line->{note});
            C4::Items::ModItem({ notforloan => '6' }, $line->{biblionumber}, $line->{itemnumber});
        }
    }
}

1;