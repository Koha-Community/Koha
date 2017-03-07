package C4::KohaSuomi::Billing::SapErp;

# This file is part of Koha.
#
# Copyright (C) 2016 Observis Oy
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
use Modern::Perl;
use XML::LibXML;
use XML::Compile::Schema;
use Net::FTP;
use POSIX;

use DBI;
use DBD::mysql;

use C4::Accounts;
use C4::Members;
use Koha::Patron::Message;
use C4::KohaSuomi::Billing::BillingManager;
use C4::KohaSuomi::Billing::PDFBill qw(check_item_fine check_billing_fine);
use Koha::DateUtils;
use Data::Dumper;

use vars qw($VERSION @ISA @EXPORT);

BEGIN {
	# set the version for version checking
    $VERSION = 1.0;
	require Exporter;
	@ISA    = qw(Exporter);
	@EXPORT = qw(
		send_xml);
}

sub send_xml{

	my (@billingdata) = @_;

	#Create and validate xml
	my($path, $name) = create_xml(@billingdata);

	# Now since Net::SFTP is complete and utter rubbish,
	# we'll just spawn a shell and use "real" sftp instead. sshpass is needed for this.
	my $usesftp = C4::Context->config("sap_use_sftp");

	#Get the ftp-connection.
	my $providerConfig = {host=>C4::Context->config("sap_ftp_host"),
							port=>C4::Context->config("sap_ftp_port"),
							timeout=>C4::Context->config("sap_ftp_timeout"),
							ispassive=>C4::Context->config("sap_ftp_ispassive"),
							user=>C4::Context->config("sap_ftp_user"),
							pw=>C4::Context->config("sap_ftp_pw")};

	if ( $usesftp == 1 ) {
		return 1;
	} else {

	    my ($ftpcon, $error) = get_ftp($providerConfig);
	    warn $error;
	    if ($error) {
	        return(undef, $error);
	    } else {
		$ftpcon->binary();
		$ftpcon->put($path.$name, $name) or die ("Can't put $path to ftp server");
			return 1;
	    }
	}
}

sub create_xml {

	my (@billingdata) = @_;

	my $timestamp = POSIX::strftime '%y%m%d', gmtime();
	my $datum = POSIX::strftime '%Y%m%d', gmtime();
	my $year = POSIX::strftime '%Y', gmtime();
	my $today = output_pref({ dt => dt_from_string, dateonly => 1, dateformat => 'iso' });

	my $time = POSIX::strftime '%m%d', gmtime();

	my $i = 0;
	my $index = 0;
	my $filenumber = sprintf("%04d", $i);
	my $filename = "KOH_1402LS".$filenumber.$timestamp.".xml";
	my $filepath = C4::Context->config("sendoverduebills_pathtoxml");

	#Test if file exists
    while(-e $filepath.$filename."_old" or -e $filepath.$filename){
	$filenumber = sprintf("%04d", $i=$i+1);
        $filename = "KOH_1402LS".$filenumber.$timestamp.".xml";
    }

	my $doc = XML::LibXML::Document->new( '1.0', 'UTF-8' );
	my $root = $doc->createElement("ZORDERS5"); #Root element

	my $element; #Level 1 element
	my $tag; #Level 2 element
	my $rowtag; #Level 3 element
	my $lastrowtag; #Level 4 element

	my $start; #Starting index when cutting strings
	my $rounds; #Number how many time to cut a given string

	while (my $data = shift @billingdata){

		my $idoc = $doc->createElement("IDOC");
		my $i = 10; #Used to form rowstring
		my $rowstring = sprintf("%06d", $i);

		# Getting ssn for the bill
		my $ssn = C4::KohaSuomi::Billing::BillingManager::GetSSN($data->{borrowernumber});
		if (!CheckMessageDate($data->{borrowernumber}, 'Asiakkaalla on laskutettua aineistoa', $today)) {
            Koha::Patron::Message->new(
                                {
                                    borrowernumber => $data->{borrowernumber},
                                    branchcode     => 'MLI_PK',
                                    message_type   => 'L',
                                    message        => 'Asiakkaalla on laskutettua aineistoa',
                                }
                            )->store;
        }

		$idoc->setAttribute("BEGIN", "1");

		#EDI_DC40
			$element = $doc->createElement("EDI_DC40");
			$element->setAttribute("SEGMENT", "1");

			$tag = $doc->createElement("TABNAM");$tag->appendTextNode("EDI_DC40");
			$element->appendChild($tag);

			$tag = $doc->createElement("DIRECT");$tag->appendTextNode("2");
			$element->appendChild($tag);

			$tag = $doc->createElement("IDOCTYP");$tag->appendTextNode("ORDERS05");
			$element->appendChild($tag);

			$tag = $doc->createElement("CIMTYP");$tag->appendTextNode("ZORDERS5");
			$element->appendChild($tag);

			$tag = $doc->createElement("SNDPOR");
			$element->appendChild($tag);

			$tag = $doc->createElement("SNDPRT");$tag->appendTextNode("LS");
			$element->appendChild($tag);

			$tag = $doc->createElement("SNDPRN");$tag->appendTextNode("KOH_1402");
			$element->appendChild($tag);

			$tag = $doc->createElement("RCVPOR");
			$element->appendChild($tag);

			$tag = $doc->createElement("RCVPRN");
			$element->appendChild($tag);

			$idoc->appendChild($element);

		#E1EDK01
			$element = $doc->createElement("E1EDK01");
			$element->setAttribute("SEGMENT", "1");

			$tag = $doc->createElement("ZTERM");$tag->appendTextNode("");
			$element->appendChild($tag);

			$idoc->appendChild($element);

		#E1EDK14
			$element = $doc->createElement("E1EDK14");
			$element->setAttribute("SEGMENT", "1");

			$tag = $doc->createElement("QUALF");$tag->appendTextNode("006");
			$element->appendChild($tag);

			$tag = $doc->createElement("ORGID");$tag->appendTextNode("00");
			$element->appendChild($tag);

			$idoc->appendChild($element);

		#E1EDK14
			$element = $doc->createElement("E1EDK14");
			$element->setAttribute("SEGMENT", "1");

			$tag = $doc->createElement("QUALF");$tag->appendTextNode("007");
			$element->appendChild($tag);

			$tag = $doc->createElement("ORGID");$tag->appendTextNode("00");
			$element->appendChild($tag);

			$idoc->appendChild($element);

		#E1EDK14
			$element = $doc->createElement("E1EDK14");
			$element->setAttribute("SEGMENT", "1");

			$tag = $doc->createElement("QUALF");$tag->appendTextNode("008");
			$element->appendChild($tag);

			$tag = $doc->createElement("ORGID");$tag->appendTextNode("1402");
			$element->appendChild($tag);

			$idoc->appendChild($element);

		#E1EDK14
			$element = $doc->createElement("E1EDK14");
			$element->setAttribute("SEGMENT", "1");

			$tag = $doc->createElement("QUALF");$tag->appendTextNode("012");
			$element->appendChild($tag);

			$tag = $doc->createElement("ORGID");$tag->appendTextNode("ZVT");
			$element->appendChild($tag);

			$idoc->appendChild($element);

		#E1EDK14
			$element = $doc->createElement("E1EDK14");
			$element->setAttribute("SEGMENT", "1");

			$tag = $doc->createElement("QUALF");$tag->appendTextNode("016");
			$element->appendChild($tag);

			$tag = $doc->createElement("ORGID");$tag->appendTextNode("C007");
			$element->appendChild($tag);

			$idoc->appendChild($element);

		#E1EDK14
			$element = $doc->createElement("E1EDK14");
			$element->setAttribute("SEGMENT", "1");

			$tag = $doc->createElement("QUALF");$tag->appendTextNode("019");
			$element->appendChild($tag);

			$tag = $doc->createElement("ORGID");$tag->appendTextNode("KOH");
			$element->appendChild($tag);

			$idoc->appendChild($element);

		#E1EDK03
			$element = $doc->createElement("E1EDK03");
			$element->setAttribute("SEGMENT", "1");

			$tag = $doc->createElement("IDDAT");$tag->appendTextNode("016");
			$element->appendChild($tag);

			$tag = $doc->createElement("DATUM");$tag->appendTextNode($datum);
			$element->appendChild($tag);

			$idoc->appendChild($element);

		#E1EDKA1
			$element = $doc->createElement("E1EDKA1");
			$element->setAttribute("SEGMENT", "1");

			$tag = $doc->createElement("PARVW");$tag->appendTextNode("AG");
			$element->appendChild($tag);

			$tag = $doc->createElement("PARTN");$tag->appendTextNode($ssn);
			$element->appendChild($tag);

			$tag = $doc->createElement("NAME1");$tag->appendTextNode($data->{surname}." ".$data->{firstname});
			$element->appendChild($tag);

			$tag = $doc->createElement("STRAS");$tag->appendTextNode($data->{address});
			$element->appendChild($tag);

			$tag = $doc->createElement("ORT01");$tag->appendTextNode($data->{city});
			$element->appendChild($tag);

			$tag = $doc->createElement("PSTLZ");$tag->appendTextNode($data->{zipcode});
			$element->appendChild($tag);

			#$tag = $doc->createElement("BNAME");$tag->appendTextNode("Mari Haatainen");
			#$element->appendChild($tag);

			$idoc->appendChild($element);

		#E1EDK02
			$element = $doc->createElement("E1EDK02");
			$element->setAttribute("SEGMENT", "1");

			$tag = $doc->createElement("QUALF");$tag->appendTextNode("001");
			$element->appendChild($tag);

			$tag = $doc->createElement("BELNR");$tag->appendTextNode($year."C007".$time.$data->{issue_id});
			$element->appendChild($tag);

			$idoc->appendChild($element);

		#E1EDKT1
			$element = $doc->createElement("E1EDKT1");
			$element->setAttribute("SEGMENT", "1");

			$tag = $doc->createElement("TDID");$tag->appendTextNode("0001");
			$element->appendChild($tag);

			#E1EDKT2
				$tag = $doc->createElement("E1EDKT2");
				$tag->setAttribute("SEGMENT", "1");

				$rowtag = $doc->createElement("TDLINE");$rowtag->appendTextNode("Mari Haatainen, 0447942467");
				$tag->appendChild($rowtag);

				$rowtag = $doc->createElement("TDFORMAT");$rowtag->appendTextNode("*");
				$tag->appendChild($rowtag);

			$element->appendChild($tag);

			$idoc->appendChild($element);

		#E1EDP01 Row level begins!
			$element = $doc->createElement("E1EDP01");
			$element->setAttribute("SEGMENT", "1");

			$tag = $doc->createElement("POSEX");$tag->appendTextNode($rowstring);
			$element->appendChild($tag);

			$tag = $doc->createElement("MENGE");$tag->appendTextNode("1.000");
			$element->appendChild($tag);

			#ZE1EDP02
				$tag = $doc->createElement("ZE1EDP02");
				$tag->setAttribute("SEGMENT", "1");

				#$rowtag = $doc->createElement("POSNR");$rowtag->appendTextNode($rowstring);
				#$tag->appendChild($rowtag);

				$element->appendChild($tag);

			#E1EDP02
				$tag = $doc->createElement("E1EDP02");
				$tag->setAttribute("SEGMENT", "1");

				$rowtag = $doc->createElement("QUALF");$rowtag->appendTextNode("048");
				$tag->appendChild($rowtag);

				$rowtag = $doc->createElement("ZEILE");$rowtag->appendTextNode($rowstring);
				$tag->appendChild($rowtag);

				$rowtag = $doc->createElement("BSARK");$rowtag->appendTextNode("0140255101");
				$tag->appendChild($rowtag);

				$element->appendChild($tag);

			#E1EDP03
				$tag = $doc->createElement("E1EDP03");
				$tag->setAttribute("SEGMENT", "1");

				$rowtag = $doc->createElement("IDDAT");$rowtag->appendTextNode("002");
				$tag->appendChild($rowtag);

				$rowtag = $doc->createElement("DATUM");$rowtag->appendTextNode($datum);
				$tag->appendChild($rowtag);

				$element->appendChild($tag);

			#E1EDP05
				$tag = $doc->createElement("E1EDP05");
				$tag->setAttribute("SEGMENT", "1");

				$rowtag = $doc->createElement("ALCKZ");$rowtag->appendTextNode("+");
				$tag->appendChild($rowtag);

				$rowtag = $doc->createElement("KSCHL");$rowtag->appendTextNode("ZPR0");
				$tag->appendChild($rowtag);

				$rowtag = $doc->createElement("KRATE");$rowtag->appendTextNode($data->{fine});
				unless (check_billing_fine($data->{borrowernumber}, $data->{fine}, 'Laskutuslisä', 'B') ||
					check_billing_fine($data->{borrowernumber}, $data->{fine}, 'Laskutuslisä', 'F')) {
					C4::Accounts::manualinvoice($data->{borrowernumber}, undef, 'Laskutuslisä', 'B', $data->{fine}, 'Laskutuslisä');
				}
				$tag->appendChild($rowtag);

				$element->appendChild($tag);

			#E1EDP19
				$tag = $doc->createElement("E1EDP19");
				$tag->setAttribute("SEGMENT", "1");

				$rowtag = $doc->createElement("QUALF");$rowtag->appendTextNode("002");
				$tag->appendChild($rowtag);

				$rowtag = $doc->createElement("IDTNR");$rowtag->appendTextNode("7445");
				$tag->appendChild($rowtag);

				$element->appendChild($tag);

			#E1EDPT1
				$tag = $doc->createElement("E1EDPT1");
				$tag->setAttribute("SEGMENT", "1");

				$rowtag = $doc->createElement("TDID");$rowtag->appendTextNode("0001");
				$tag->appendChild($rowtag);

				#E1EDPT2
					$rowtag = $doc->createElement("E1EDPT2");
					$rowtag->setAttribute("SEGMENT", "1");

					#$lastrowtag = $doc->createElement("TDLINE");$lastrowtag->appendTextNode("Laskutuslisä");
					#$rowtag->appendChild($lastrowtag);

					#$lastrowtag = $doc->createElement("TDFORMAT");$lastrowtag->appendTextNode("*");
					#$rowtag->appendChild($lastrowtag);

					$tag->appendChild($rowtag);

				$element->appendChild($tag);

			$idoc->appendChild($element);

		#New row
		$rowstring = sprintf("%06d", $i=$i+10);

			#E1EDP01 Borrower's first item
			$element = $doc->createElement("E1EDP01");
			$element->setAttribute("SEGMENT", "1");

			$tag = $doc->createElement("POSEX");$tag->appendTextNode($rowstring);
			$element->appendChild($tag);

			$tag = $doc->createElement("MENGE");$tag->appendTextNode("1.000");
			$element->appendChild($tag);

			#ZE1EDP02
				$tag = $doc->createElement("ZE1EDP02");
				$tag->setAttribute("SEGMENT", "1");

				#$rowtag = $doc->createElement("POSNR");$rowtag->appendTextNode($rowstring);
				#$tag->appendChild($rowtag);

				$element->appendChild($tag);

			#E1EDP02
				$tag = $doc->createElement("E1EDP02");
				$tag->setAttribute("SEGMENT", "1");

				$rowtag = $doc->createElement("QUALF");$rowtag->appendTextNode("048");
				$tag->appendChild($rowtag);

				$rowtag = $doc->createElement("ZEILE");$rowtag->appendTextNode($rowstring);
				$tag->appendChild($rowtag);

				$rowtag = $doc->createElement("BSARK");$rowtag->appendTextNode("0140255101");
				$tag->appendChild($rowtag);

				$element->appendChild($tag);

			#E1EDP03
				$tag = $doc->createElement("E1EDP03");
				$tag->setAttribute("SEGMENT", "1");

				$rowtag = $doc->createElement("IDDAT");$rowtag->appendTextNode("002");
				$tag->appendChild($rowtag);

				$rowtag = $doc->createElement("DATUM");$rowtag->appendTextNode($datum);
				$tag->appendChild($rowtag);

				$element->appendChild($tag);

			#E1EDP05
				$tag = $doc->createElement("E1EDP05");
				$tag->setAttribute("SEGMENT", "1");

				$rowtag = $doc->createElement("ALCKZ");$rowtag->appendTextNode("+");
				$tag->appendChild($rowtag);

				$rowtag = $doc->createElement("KSCHL");$rowtag->appendTextNode("ZPR0");
				$tag->appendChild($rowtag);

				$rowtag = $doc->createElement("KRATE");$rowtag->appendTextNode($data->{replacementprice});
				unless(check_item_fine($data->{borrowernumber}, $data->{itemnumber}, $data->{replacementprice}, 'Korvaushinta', 'B') ||
					check_item_fine($data->{borrowernumber}, $data->{itemnumber}, $data->{replacementprice}, 'Perintä', 'F')) {
					C4::Accounts::manualinvoice($data->{borrowernumber}, $data->{itemnumber}, 'Lasku', 'B', $data->{replacementprice}, 'Korvaushinta');
				}
				$tag->appendChild($rowtag);

				$element->appendChild($tag);

			#E1EDP19
				$tag = $doc->createElement("E1EDP19");
				$tag->setAttribute("SEGMENT", "1");

				$rowtag = $doc->createElement("QUALF");$rowtag->appendTextNode("002");
				$tag->appendChild($rowtag);

				$rowtag = $doc->createElement("IDTNR");$rowtag->appendTextNode("9690");
				$tag->appendChild($rowtag);

				$element->appendChild($tag);

			#E1EDPT1
				$tag = $doc->createElement("E1EDPT1");
				$tag->setAttribute("SEGMENT", "1");

				$rowtag = $doc->createElement("TDID");$rowtag->appendTextNode("0001");
				$tag->appendChild($rowtag);

				if(length($data->{title}) > 70){

					$start = 0;
					$rounds = POSIX::ceil(length($data->{title})/70);

					for(my $j=0;$j<$rounds;$j++){
						#E1EDPT2
							$rowtag = $doc->createElement("E1EDPT2");
							$rowtag->setAttribute("SEGMENT", "1");

							$lastrowtag = $doc->createElement("TDLINE");$lastrowtag->appendTextNode(substr($data->{title}, $start, 70));
							$rowtag->appendChild($lastrowtag);

							$lastrowtag = $doc->createElement("TDFORMAT");$lastrowtag->appendTextNode("*");
							$rowtag->appendChild($lastrowtag);

							$tag->appendChild($rowtag);

						$element->appendChild($tag);

						$start = $start+70;
					}
				}
				else{
					#E1EDPT2
						$rowtag = $doc->createElement("E1EDPT2");
						$rowtag->setAttribute("SEGMENT", "1");

						$lastrowtag = $doc->createElement("TDLINE");$lastrowtag->appendTextNode($data->{title});
						$rowtag->appendChild($lastrowtag);

						$lastrowtag = $doc->createElement("TDFORMAT");$lastrowtag->appendTextNode("*");
						$rowtag->appendChild($lastrowtag);

						$tag->appendChild($rowtag);

					$element->appendChild($tag);
				}
			$idoc->appendChild($element);

			if ($data->{overdue_price} && $data->{overdue_price} > 0) {
				$rowstring = sprintf("%06d", $i=$i+10);
				#E1EDP01 Borrower's overdue price
				$element = $doc->createElement("E1EDP01");
				$element->setAttribute("SEGMENT", "1");

				$tag = $doc->createElement("POSEX");$tag->appendTextNode($rowstring);
				$element->appendChild($tag);

				$tag = $doc->createElement("MENGE");$tag->appendTextNode("1.000");
				$element->appendChild($tag);
				#ZE1EDP02
					$tag = $doc->createElement("ZE1EDP02");
					$tag->setAttribute("SEGMENT", "1");

					#$rowtag = $doc->createElement("POSNR");$rowtag->appendTextNode($rowstring);
					#$tag->appendChild($rowtag);

					$element->appendChild($tag);

				#E1EDP02
					$tag = $doc->createElement("E1EDP02");
					$tag->setAttribute("SEGMENT", "1");

					$rowtag = $doc->createElement("QUALF");$rowtag->appendTextNode("048");
					$tag->appendChild($rowtag);

					$rowtag = $doc->createElement("ZEILE");$rowtag->appendTextNode($rowstring);
					$tag->appendChild($rowtag);

					$rowtag = $doc->createElement("BSARK");$rowtag->appendTextNode("0140255101");
					$tag->appendChild($rowtag);

					$element->appendChild($tag);

				#E1EDP03
					$tag = $doc->createElement("E1EDP03");
					$tag->setAttribute("SEGMENT", "1");

					$rowtag = $doc->createElement("IDDAT");$rowtag->appendTextNode("002");
					$tag->appendChild($rowtag);

					$rowtag = $doc->createElement("DATUM");$rowtag->appendTextNode($datum);
					$tag->appendChild($rowtag);

					$element->appendChild($tag);

				#E1EDP05
					$tag = $doc->createElement("E1EDP05");
					$tag->setAttribute("SEGMENT", "1");

					$rowtag = $doc->createElement("ALCKZ");$rowtag->appendTextNode("+");
					$tag->appendChild($rowtag);

					$rowtag = $doc->createElement("KSCHL");$rowtag->appendTextNode("ZPR0");
					$tag->appendChild($rowtag);

					$rowtag = $doc->createElement("KRATE");$rowtag->appendTextNode($data->{overdue_price});

					$tag->appendChild($rowtag);

					$element->appendChild($tag);

				#E1EDP19
					$tag = $doc->createElement("E1EDP19");
					$tag->setAttribute("SEGMENT", "1");

					$rowtag = $doc->createElement("QUALF");$rowtag->appendTextNode("002");
					$tag->appendChild($rowtag);

					$rowtag = $doc->createElement("IDTNR");$rowtag->appendTextNode("7359");
					$tag->appendChild($rowtag);

					$element->appendChild($tag);

				#E1EDPT1
					$tag = $doc->createElement("E1EDPT1");
					$tag->setAttribute("SEGMENT", "1");

					$rowtag = $doc->createElement("TDID");$rowtag->appendTextNode("0001");
					$tag->appendChild($rowtag);

					#E1EDPT2
						$rowtag = $doc->createElement("E1EDPT2");
						$rowtag->setAttribute("SEGMENT", "1");

						$tag->appendChild($rowtag);

					$element->appendChild($tag);

				$idoc->appendChild($element);
			}

			$rowstring = sprintf("%06d", $i=$i+10);

			#E1EDP01 Borrower's first plastic fine
			$element = $doc->createElement("E1EDP01");
			$element->setAttribute("SEGMENT", "1");

			$tag = $doc->createElement("POSEX");$tag->appendTextNode($rowstring);
			$element->appendChild($tag);

			$tag = $doc->createElement("MENGE");$tag->appendTextNode("1.000");
			$element->appendChild($tag);

			#ZE1EDP02
				$tag = $doc->createElement("ZE1EDP02");
				$tag->setAttribute("SEGMENT", "1");

				#$rowtag = $doc->createElement("POSNR");$rowtag->appendTextNode($rowstring);
				#$tag->appendChild($rowtag);

				$element->appendChild($tag);

			#E1EDP02
				$tag = $doc->createElement("E1EDP02");
				$tag->setAttribute("SEGMENT", "1");

				$rowtag = $doc->createElement("QUALF");$rowtag->appendTextNode("048");
				$tag->appendChild($rowtag);

				$rowtag = $doc->createElement("ZEILE");$rowtag->appendTextNode($rowstring);
				$tag->appendChild($rowtag);

				$rowtag = $doc->createElement("BSARK");$rowtag->appendTextNode("0140255101");
				$tag->appendChild($rowtag);

				$element->appendChild($tag);

			#E1EDP03
				$tag = $doc->createElement("E1EDP03");
				$tag->setAttribute("SEGMENT", "1");

				$rowtag = $doc->createElement("IDDAT");$rowtag->appendTextNode("002");
				$tag->appendChild($rowtag);

				$rowtag = $doc->createElement("DATUM");$rowtag->appendTextNode($datum);
				$tag->appendChild($rowtag);

				$element->appendChild($tag);

			#E1EDP05
				$tag = $doc->createElement("E1EDP05");
				$tag->setAttribute("SEGMENT", "1");

				$rowtag = $doc->createElement("ALCKZ");$rowtag->appendTextNode("+");
				$tag->appendChild($rowtag);

				$rowtag = $doc->createElement("KSCHL");$rowtag->appendTextNode("ZPR0");
				$tag->appendChild($rowtag);

				$rowtag = $doc->createElement("KRATE");$rowtag->appendTextNode($data->{plastic});
				unless(check_item_fine($data->{borrowernumber}, $data->{itemnumber}, $data->{plastic}, 'Muovitusmaksu', 'B') ||
					check_item_fine($data->{borrowernumber}, $data->{itemnumber}, $data->{plastic}, 'Muovitusmaksu', 'F')) {
					C4::Accounts::manualinvoice($data->{borrowernumber}, $data->{itemnumber}, 'Muovitusmaksu', 'B', $data->{plastic}, 'Muovitusmaksu');
				}
				$tag->appendChild($rowtag);

				$element->appendChild($tag);

			#E1EDP19
				$tag = $doc->createElement("E1EDP19");
				$tag->setAttribute("SEGMENT", "1");

				$rowtag = $doc->createElement("QUALF");$rowtag->appendTextNode("002");
				$tag->appendChild($rowtag);

				$rowtag = $doc->createElement("IDTNR");$rowtag->appendTextNode("9665");
				$tag->appendChild($rowtag);

				$element->appendChild($tag);

			#E1EDPT1
				$tag = $doc->createElement("E1EDPT1");
				$tag->setAttribute("SEGMENT", "1");

				$rowtag = $doc->createElement("TDID");$rowtag->appendTextNode("0001");
				$tag->appendChild($rowtag);

				#E1EDPT2
					$rowtag = $doc->createElement("E1EDPT2");
					$rowtag->setAttribute("SEGMENT", "1");

					#$lastrowtag = $doc->createElement("TDLINE");$lastrowtag->appendTextNode("Muovitusmaksu");
					#$rowtag->appendChild($lastrowtag);

					#$lastrowtag = $doc->createElement("TDFORMAT");$lastrowtag->appendTextNode("*");
					#$rowtag->appendChild($lastrowtag);

					$tag->appendChild($rowtag);

				$element->appendChild($tag);

			$idoc->appendChild($element);

		# All borrower's items
		while($data->{borrowernumber} eq $billingdata[0]->{borrowernumber}){

				$data = shift @billingdata;
				#New row
				$rowstring = sprintf("%06d", $i=$i+10);

				#E1EDP01 Borrower's item
				$element = $doc->createElement("E1EDP01");
				$element->setAttribute("SEGMENT", "1");

				$tag = $doc->createElement("POSEX");$tag->appendTextNode($rowstring);
				$element->appendChild($tag);

				$tag = $doc->createElement("MENGE");$tag->appendTextNode("1.000");
				$element->appendChild($tag);

				#ZE1EDP02
					$tag = $doc->createElement("ZE1EDP02");
					$tag->setAttribute("SEGMENT", "1");

					#$rowtag = $doc->createElement("POSNR");$rowtag->appendTextNode($rowstring);
					#$tag->appendChild($rowtag);

					$element->appendChild($tag);

				#E1EDP02
					$tag = $doc->createElement("E1EDP02");
					$tag->setAttribute("SEGMENT", "1");

					$rowtag = $doc->createElement("QUALF");$rowtag->appendTextNode("048");
					$tag->appendChild($rowtag);

					$rowtag = $doc->createElement("ZEILE");$rowtag->appendTextNode($rowstring);
					$tag->appendChild($rowtag);

					$rowtag = $doc->createElement("BSARK");$rowtag->appendTextNode("0140255101");
					$tag->appendChild($rowtag);

					$element->appendChild($tag);

				#E1EDP03
					$tag = $doc->createElement("E1EDP03");
					$tag->setAttribute("SEGMENT", "1");

					$rowtag = $doc->createElement("IDDAT");$rowtag->appendTextNode("002");
					$tag->appendChild($rowtag);

					$rowtag = $doc->createElement("DATUM");$rowtag->appendTextNode($datum);
					$tag->appendChild($rowtag);

					$element->appendChild($tag);

				#E1EDP05
					$tag = $doc->createElement("E1EDP05");
					$tag->setAttribute("SEGMENT", "1");

					$rowtag = $doc->createElement("ALCKZ");$rowtag->appendTextNode("+");
					$tag->appendChild($rowtag);

					$rowtag = $doc->createElement("KSCHL");$rowtag->appendTextNode("ZPR0");
					$tag->appendChild($rowtag);

					$rowtag = $doc->createElement("KRATE");$rowtag->appendTextNode($data->{replacementprice});
					unless(check_item_fine($data->{borrowernumber}, $data->{itemnumber}, $data->{replacementprice}, 'Korvaushinta', 'B') ||
						check_item_fine($data->{borrowernumber}, $data->{itemnumber}, $data->{replacementprice}, 'Perintä', 'F')) {
						C4::Accounts::manualinvoice($data->{borrowernumber}, $data->{itemnumber}, 'Lasku', 'B', $data->{replacementprice}, 'Korvaushinta');
					}
					$tag->appendChild($rowtag);

					$element->appendChild($tag);

				#E1EDP19
					$tag = $doc->createElement("E1EDP19");
					$tag->setAttribute("SEGMENT", "1");

					$rowtag = $doc->createElement("QUALF");$rowtag->appendTextNode("002");
					$tag->appendChild($rowtag);

					$rowtag = $doc->createElement("IDTNR");$rowtag->appendTextNode("9690");
					$tag->appendChild($rowtag);

					$element->appendChild($tag);

				#E1EDPT1
					$tag = $doc->createElement("E1EDPT1");
					$tag->setAttribute("SEGMENT", "1");

					$rowtag = $doc->createElement("TDID");$rowtag->appendTextNode("0001");
					$tag->appendChild($rowtag);

					if(length($data->{title}) > 70){

						$start = 0;
						$rounds = POSIX::ceil(length($data->{title})/70);

						for(my $j=0;$j<$rounds;$j++){
							#E1EDPT2
								$rowtag = $doc->createElement("E1EDPT2");
								$rowtag->setAttribute("SEGMENT", "1");

								$lastrowtag = $doc->createElement("TDLINE");$lastrowtag->appendTextNode(substr($data->{title}, $start, 70));
								$rowtag->appendChild($lastrowtag);

								$lastrowtag = $doc->createElement("TDFORMAT");$lastrowtag->appendTextNode("*");
								$rowtag->appendChild($lastrowtag);

								$tag->appendChild($rowtag);

							$element->appendChild($tag);

							$start = $start+70;
						}
					}
					else{
						#E1EDPT2
							$rowtag = $doc->createElement("E1EDPT2");
							$rowtag->setAttribute("SEGMENT", "1");

							$lastrowtag = $doc->createElement("TDLINE");$lastrowtag->appendTextNode($data->{title});
							$rowtag->appendChild($lastrowtag);

							$lastrowtag = $doc->createElement("TDFORMAT");$lastrowtag->appendTextNode("*");
							$rowtag->appendChild($lastrowtag);

							$tag->appendChild($rowtag);

						$element->appendChild($tag);
					}


				$idoc->appendChild($element);

				if ($data->{overdue_price} && $data->{overdue_price} > 0) {
					$rowstring = sprintf("%06d", $i=$i+10);

					#E1EDP01 Borrower's overdue price
					$element = $doc->createElement("E1EDP01");
					$element->setAttribute("SEGMENT", "1");

					$tag = $doc->createElement("POSEX");$tag->appendTextNode($rowstring);
					$element->appendChild($tag);

					$tag = $doc->createElement("MENGE");$tag->appendTextNode("1.000");
					$element->appendChild($tag);

					#ZE1EDP02
						$tag = $doc->createElement("ZE1EDP02");
						$tag->setAttribute("SEGMENT", "1");

						#$rowtag = $doc->createElement("POSNR");$rowtag->appendTextNode($rowstring);
						#$tag->appendChild($rowtag);

						$element->appendChild($tag);

					#E1EDP02
						$tag = $doc->createElement("E1EDP02");
						$tag->setAttribute("SEGMENT", "1");

						$rowtag = $doc->createElement("QUALF");$rowtag->appendTextNode("048");
						$tag->appendChild($rowtag);

						$rowtag = $doc->createElement("ZEILE");$rowtag->appendTextNode($rowstring);
						$tag->appendChild($rowtag);

						$rowtag = $doc->createElement("BSARK");$rowtag->appendTextNode("0140255101");
						$tag->appendChild($rowtag);

						$element->appendChild($tag);

					#E1EDP03
						$tag = $doc->createElement("E1EDP03");
						$tag->setAttribute("SEGMENT", "1");

						$rowtag = $doc->createElement("IDDAT");$rowtag->appendTextNode("002");
						$tag->appendChild($rowtag);

						$rowtag = $doc->createElement("DATUM");$rowtag->appendTextNode($datum);
						$tag->appendChild($rowtag);

						$element->appendChild($tag);

					#E1EDP05
						$tag = $doc->createElement("E1EDP05");
						$tag->setAttribute("SEGMENT", "1");

						$rowtag = $doc->createElement("ALCKZ");$rowtag->appendTextNode("+");
						$tag->appendChild($rowtag);

						$rowtag = $doc->createElement("KSCHL");$rowtag->appendTextNode("ZPR0");
						$tag->appendChild($rowtag);

						$rowtag = $doc->createElement("KRATE");$rowtag->appendTextNode($data->{overdue_price});

						$tag->appendChild($rowtag);

						$element->appendChild($tag);

					#E1EDP19
						$tag = $doc->createElement("E1EDP19");
						$tag->setAttribute("SEGMENT", "1");

						$rowtag = $doc->createElement("QUALF");$rowtag->appendTextNode("002");
						$tag->appendChild($rowtag);

						$rowtag = $doc->createElement("IDTNR");$rowtag->appendTextNode("7359");
						$tag->appendChild($rowtag);

						$element->appendChild($tag);

					#E1EDPT1
						$tag = $doc->createElement("E1EDPT1");
						$tag->setAttribute("SEGMENT", "1");

						$rowtag = $doc->createElement("TDID");$rowtag->appendTextNode("0001");
						$tag->appendChild($rowtag);

						#E1EDPT2
							$rowtag = $doc->createElement("E1EDPT2");
							$rowtag->setAttribute("SEGMENT", "1");

							$tag->appendChild($rowtag);

						$element->appendChild($tag);

					$idoc->appendChild($element);
				}

				$rowstring = sprintf("%06d", $i=$i+10);

				#E1EDP01 Borrower's next plastic fine
				$element = $doc->createElement("E1EDP01");
				$element->setAttribute("SEGMENT", "1");

				$tag = $doc->createElement("POSEX");$tag->appendTextNode($rowstring);
				$element->appendChild($tag);

				$tag = $doc->createElement("MENGE");$tag->appendTextNode("1.000");
				$element->appendChild($tag);

				#ZE1EDP02
					$tag = $doc->createElement("ZE1EDP02");
					$tag->setAttribute("SEGMENT", "1");

					#$rowtag = $doc->createElement("POSNR");$rowtag->appendTextNode($rowstring);
					#$tag->appendChild($rowtag);

					$element->appendChild($tag);

				#E1EDP02
					$tag = $doc->createElement("E1EDP02");
					$tag->setAttribute("SEGMENT", "1");

					$rowtag = $doc->createElement("QUALF");$rowtag->appendTextNode("048");
					$tag->appendChild($rowtag);

					$rowtag = $doc->createElement("ZEILE");$rowtag->appendTextNode($rowstring);
					$tag->appendChild($rowtag);

					$rowtag = $doc->createElement("BSARK");$rowtag->appendTextNode("0140255101");
					$tag->appendChild($rowtag);

					$element->appendChild($tag);

				#E1EDP03
					$tag = $doc->createElement("E1EDP03");
					$tag->setAttribute("SEGMENT", "1");

					$rowtag = $doc->createElement("IDDAT");$rowtag->appendTextNode("002");
					$tag->appendChild($rowtag);

					$rowtag = $doc->createElement("DATUM");$rowtag->appendTextNode($datum);
					$tag->appendChild($rowtag);

					$element->appendChild($tag);

				#E1EDP05
					$tag = $doc->createElement("E1EDP05");
					$tag->setAttribute("SEGMENT", "1");

					$rowtag = $doc->createElement("ALCKZ");$rowtag->appendTextNode("+");
					$tag->appendChild($rowtag);

					$rowtag = $doc->createElement("KSCHL");$rowtag->appendTextNode("ZPR0");
					$tag->appendChild($rowtag);

					$rowtag = $doc->createElement("KRATE");$rowtag->appendTextNode($data->{plastic});
					unless(check_item_fine($data->{borrowernumber}, $data->{itemnumber}, $data->{plastic}, 'Muovitusmaksu', 'B') ||
						check_item_fine($data->{borrowernumber}, $data->{itemnumber}, $data->{plastic}, 'Muovitusmaksu', 'F') ) {
						C4::Accounts::manualinvoice($data->{borrowernumber}, $data->{itemnumber}, 'Muovitusmaksu', 'B', $data->{plastic}, 'Muovitusmaksu');
					}
					$tag->appendChild($rowtag);

					$element->appendChild($tag);

				#E1EDP19
					$tag = $doc->createElement("E1EDP19");
					$tag->setAttribute("SEGMENT", "1");

					$rowtag = $doc->createElement("QUALF");$rowtag->appendTextNode("002");
					$tag->appendChild($rowtag);

					$rowtag = $doc->createElement("IDTNR");$rowtag->appendTextNode("9665");
					$tag->appendChild($rowtag);

					$element->appendChild($tag);

				#E1EDPT1
					$tag = $doc->createElement("E1EDPT1");
					$tag->setAttribute("SEGMENT", "1");

					$rowtag = $doc->createElement("TDID");$rowtag->appendTextNode("0001");
					$tag->appendChild($rowtag);

					#E1EDPT2
						$rowtag = $doc->createElement("E1EDPT2");
						$rowtag->setAttribute("SEGMENT", "1");

						#$lastrowtag = $doc->createElement("TDLINE");$lastrowtag->appendTextNode("Muovitusmaksu");
						#$rowtag->appendChild($lastrowtag);

						#$lastrowtag = $doc->createElement("TDFORMAT");$lastrowtag->appendTextNode("*");
						#$rowtag->appendChild($lastrowtag);

						$tag->appendChild($rowtag);

					$element->appendChild($tag);

				$idoc->appendChild($element);

		}

		$root->appendChild($idoc);

		$data = shift @billingdata;
	}

	$doc->setDocumentElement($root);
	#Write xml to file
	open my $out, '>', $filepath.$filename or die("Can't open file  : $!");
	binmode $out; # as above
	print {$out} $doc->toString(C4::Context->config("sendoverduebills_xmlwritemode"));
	close $out;

	my $xsd = C4::Context->config("sendoverduebills_pathtoxsd");
	my $xmlschema = XML::LibXML::Schema->new(location => $xsd);
	$xmlschema->validate($doc);

	return ($filepath, $filename);
}

sub get_ftp {

	my ($providerConfig) = @_;

    my $ftpcon = Net::FTP->new( Host => $providerConfig->{host},
							Port => $providerConfig->{port},
                                Timeout => $providerConfig->{timeout},
                                Passive => $providerConfig->{ispassive});
    unless ($ftpcon) {
        return (undef, "Cannot connect to ftp server: $@");
    }

    if ($ftpcon->login($providerConfig->{user},$providerConfig->{pw})){
        return ($ftpcon, undef);
    }
    else {
        return (undef, "Cannot login to ftp server: $@");
    }
}

1;
__END__
