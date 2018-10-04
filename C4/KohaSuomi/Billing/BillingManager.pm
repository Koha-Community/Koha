package C4::KohaSuomi::Billing::BillingManager;

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

use C4::Biblio;
use C4::Context;
use Data::Dumper;

use vars qw($VERSION @ISA @EXPORT);

BEGIN {
	# set the version for version checking
    $VERSION = 1.0;
	require Exporter;
	@ISA    = qw(Exporter);
	@EXPORT = qw(
				GetOverduedIssues
                GetTotalPages
				CheckOverduerules
				GetBranchBillingAccount
				ModOverdueBills
				GetSSN
				OverduePrice
				RemovePayment
                CheckMessageDate
                CheckBillCategory
				);
}

sub GetOverduedIssues {
	my ($branch, $resultnumber, $results, $delay, $showall, $showbilled, $shownotbilled, $bypatron, $group, $branchcategory) = @_;

    my @issues;
    my $branches;
    if ($group) {
        my @fields =  Koha::LibraryCategories->find($branchcategory)->libraries;
        $branches = branch_string(@fields);
    }

    my $dbh = C4::Context->dbh;
    my $sth;

    my $query="SELECT
        issues.issue_id,
        issues.borrowernumber,
        issues.date_due,
        issues.itemnumber,
        items.barcode,
        items.replacementprice
        FROM issues
        LEFT JOIN items ON issues.itemnumber=items.itemnumber ";
    if($showbilled || $shownotbilled) {
        $query .= "LEFT JOIN overduebills ON overduebills.issue_id=issues.issue_id ";
    }
    $query .= "WHERE (NOW() > DATE_ADD(issues.date_due,INTERVAL ".$delay->{delaytime}." DAY))
        AND issues.date_due > (NOW() - INTERVAL 1 YEAR) ";
    if ($group) {
        $query .= "AND (".$branches.") ";
    } else {
        $query .= "AND ".C4::Context->config("billingSetup")->{"branch"}." = ? ";
    }
    if ($showbilled) {$query.= "AND overduebills.billingdate IS NOT NULL ";}
    if ($shownotbilled) {$query.= "AND overduebills.billingdate IS NULL ";}
    if ($bypatron) {
        $query .= "GROUP BY issues.issue_id ORDER BY issues.borrowernumber ASC, issues.date_due DESC ";
    } else {
       $query.= "GROUP BY issues.issue_id ORDER BY issues.date_due DESC, issues.borrowernumber ASC ";
    }

    unless ($showall){$query .= " LIMIT ?,?";}

    $sth = $dbh->prepare($query);
    if ($group) {
        if ($showall) {
            $sth->execute();
        } else {
            $sth->execute($resultnumber, $results);
        }

    } else {
        if ($showall) {
            $sth->execute($branch);
        } else {
            $sth->execute($branch, $resultnumber, $results);
        }

    }


    while (my $issue = $sth->fetchrow_hashref) {
        my $borrower = GetBorrower($issue->{borrowernumber});

        my $ssnkey;

        $issue->{firstname} = trim($borrower->{firstname});
        $issue->{surname} = trim($borrower->{surname});
        $issue->{address} = trim($borrower->{address});
        $issue->{city} = trim($borrower->{city});
        $issue->{zipcode} = trim($borrower->{zipcode});
        $issue->{phone} = trim($borrower->{phone});
        $issue->{email} = trim($borrower->{email});
        $issue->{dateofbirth} = trim($borrower->{dateofbirth});
        $issue->{guarantorid} = trim($borrower->{guarantorid});

        my $guarantorid = $issue->{guarantorid};
        if ($guarantorid) {
            my $guarantor = GetGuarantor($guarantorid);
            $issue->{gfirstname} = trim($guarantor->{gfirstname});
            $issue->{gsurname} = trim($guarantor->{gsurname});
            $issue->{gaddress} = trim($guarantor->{gaddress});
            $issue->{gcity} = trim($guarantor->{gcity});
            $issue->{gzipcode} = trim($guarantor->{gzipcode});
            $issue->{gphone} = trim($guarantor->{gphone});
            $issue->{gemail} = trim($guarantor->{gemail});
            $ssnkey = GetSsnKey($guarantorid);
        } else {
            $ssnkey = GetSsnKey($issue->{borrowernumber});
        }
        $issue->{ssnkey} = trim($ssnkey);
        my $biblio = GetBiblioFromItemNumber($issue->{itemnumber});

        $issue->{title} = $biblio->{title};
        $issue->{author} = $biblio->{author};
        $issue->{copyrightdate} = $biblio->{copyrightdate};
        $issue->{biblionumber} = $biblio->{biblionumber};

        if (!$showbilled || !$shownotbilled) {
            my $billingdate = GetOverdueBill($issue->{issue_id});
            $issue->{billingdate} = $billingdate;
        }

        push @issues, $issue;

    }
    $sth->finish;

    return \@issues;

}

sub GetBorrower {
    my ($borrowernumber) = @_;

    my $dbh = C4::Context->dbh;
    my $sth;

    my $query="SELECT
        borrowers.surname,
        borrowers.firstname,
        borrowers.address,
        borrowers.city,
        borrowers.zipcode,
        borrowers.phone,
        borrowers.email,
        borrowers.dateofbirth,
        borrowers.guarantorid
        FROM borrowers
        WHERE borrowernumber = ?";

    $sth = $dbh->prepare($query);
    $sth->execute($borrowernumber);
    return $sth->fetchrow_hashref();
}

sub GetSsnKey {
    my ($borrowernumber) = @_;

    my $dbh = C4::Context->dbh;
    my $sth;

    my $query="SELECT
        attribute
        FROM borrower_attributes
        WHERE borrowernumber = ? and code = 'SSN'";

    $sth = $dbh->prepare($query);
    $sth->execute($borrowernumber);
    return $sth->fetchrow;
}


sub GetGuarantor {
    my ($guarantorid) = @_;

    my $dbh = C4::Context->dbh;
    my $sth;

    my $query="SELECT
        guarantor.firstname as gfirstname,
        guarantor.surname as gsurname,
        guarantor.address as gaddress,
        guarantor.city as gcity,
        guarantor.zipcode as gzipcode,
        guarantor.phone as gphone,
        guarantor.email as gemail
        FROM borrowers guarantor
        WHERE guarantor.borrowernumber = ?";

    $sth = $dbh->prepare($query);
    $sth->execute($guarantorid);
    return $sth->fetchrow_hashref();
}

sub GetOverdueBill {
    my ($issue_id) = @_;
    my $dbh = C4::Context->dbh;
    my $sth;

    my $query="SELECT billingdate
        FROM overduebills
        WHERE issue_id = ?";

    $sth = $dbh->prepare($query);
    $sth->execute($issue_id);
    return $sth->fetchrow();

}

sub CheckSSN {
    my ($borrowernumber) = @_;
    my $dbh = C4::Context->dbh;
    my $sth;

    my $query="SELECT attribute
        FROM borrower_attributes
        WHERE borrowernumber = ?
        AND attribute like 'sotu%'";

    $sth = $dbh->prepare($query);
    $sth->execute($borrowernumber);
    return $sth->fetchrow();
}

sub GetTotalPages {
    my ($branch, $showall, $showbilled, $shownotbilled, $delay, $group, $branchcategory) = @_;

    my $branches;
    if ($group) {
        my @fields =  Koha::LibraryCategories->find($branchcategory)->libraries;
        $branches = branch_string(@fields);
    }

    my $dbh = C4::Context->dbh;
    my $sth;

    my $query="SELECT COUNT(DISTINCT issues.issue_id) AS sqlrows
        FROM issues
        LEFT JOIN borrowers ON issues.borrowernumber=borrowers.borrowernumber
        LEFT JOIN overduebills ON overduebills.issue_id=issues.issue_id
        LEFT JOIN items ON issues.itemnumber=items.itemnumber
        WHERE ";
        if ($group) {
            $query .= "(".$branches.") ";
        } else {
            $query .= C4::Context->config("billingSetup")->{"branch"}." = ? ";
        }
        $query .= "AND (NOW() > DATE_ADD(issues.date_due, INTERVAL ".$delay->{delaytime}." DAY))
        AND issues.date_due > (NOW() - INTERVAL 1 YEAR) ";
        if ($showbilled) {$query.= "AND overduebills.billingdate IS NOT NULL ";}
        if ($shownotbilled) {$query.= "AND overduebills.billingdate IS NULL ";}

    $sth = $dbh->prepare($query);
    if ($group) {
        $sth->execute();
    }else {
        $sth->execute($branch);
    }

    my $count = $sth->fetchrow;
    if ($showall) {
        $count = 1;
    }

    return $count;

}

sub CheckOverduerules {
    my ($branch) = @_;

    my %delay;
    my $fine;
    my $delayperiod;
    my $delaytime;

    my $dbh = C4::Context->dbh;
    my $sth;
    $sth = $dbh->prepare("SELECT * FROM overduerules WHERE branchcode = ?");
    $sth->execute($branch);
    if (my $data = $sth->fetchrow_hashref) {
        if ($data->{delay3}) {
            $delaytime = $data->{delay3};
            $delayperiod = '3';
            $fine = $data->{fine3};
        } elsif ($data->{delay2}) {
            $delaytime =$data->{delay2};
            $delayperiod= '2';
            $fine = $data->{fine2};
        } elsif ($data->{delay1}) {
            $delaytime =$data->{delay1};
            $delayperiod = '1';
            $fine = $data->{fine1};
        }
        $sth->finish;
    } else {
        my $isth = $dbh->prepare("SELECT * FROM overduerules");
        $isth->execute();
        if (my $idata = $isth->fetchrow_hashref) {
            if ($idata->{delay3}) {
                $delaytime = $idata->{delay3};
                $delayperiod = '3';
                $fine = $idata->{fine3};
            } elsif ($idata->{delay2}) {
                $delaytime = $idata->{delay2};
                $delayperiod = '2';
                $fine = $idata->{fine2};
            } elsif ($idata->{delay1}) {
                $delaytime = $idata->{delay1};
                $delayperiod = '1';
                $fine = $idata->{fine1};
            }
        }
        $isth->finish;
    }

    $delay{delaytime} = $delaytime;
    $delay{delayperiod} = $delayperiod;
    $delay{delayfine} = $fine;

    return \%delay;

}

sub GetBranchBillingAccount {
    my ($branch) = @_;

    my $categorycode;

    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("SELECT * FROM branchcategories WHERE categorytype = 'properties'");
    $sth->execute();
    while (my $property = $sth->fetchrow_hashref) {
        $categorycode = $property->{categorycode};
        if ($categorycode =~ /SAP/i || $categorycode =~ /PDF/i) {
            my @branches = Koha::LibraryCategories->find($categorycode)->libraries;
            foreach my $br (@branches) {
                if ($branch eq $br->branchcode) {
                    return $categorycode;
                }
            }
        }
    }
    $sth->finish;
    return;
}

sub ModOverdueBills {
	my ($function, $issue_id) = @_;

	my $dbh = C4::Context->dbh;
	my $sth;

	if ($function eq 'insert') {
		$sth = $dbh->prepare("INSERT INTO overduebills (issue_id,billingdate) VALUES (?,NOW())");
		$sth->execute($issue_id);
	} elsif ($function eq 'update') {
		$sth = $dbh->prepare("UPDATE overduebills SET billingdate=NOW() WHERE issue_id=?");
		$sth->execute($issue_id);
	} else {
		warn "Undefined function, cannot process!\n";
	}
    $sth->finish;
}

sub GetSSN {
	my ($borrowernumber) = @_;

	my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("SELECT attribute FROM borrower_attributes WHERE borrowernumber = ? and code = 'SSN'");
    $sth->execute($borrowernumber);
    my $ssnkey = $sth->fetchrow;
    $ssnkey =~ s/\D//g;

	my $host = C4::Context->config('ssnProvider')->{'directDB'}->{'host'};
	my $port = C4::Context->config('ssnProvider')->{'directDB'}->{'port'};
	my $user = C4::Context->config('ssnProvider')->{'directDB'}->{'user'};
	my $password = C4::Context->config('ssnProvider')->{'directDB'}->{'password'};

	my $dsn = "dbi:mysql:ssn:".$host.":".$port;

	my $connect_ssn = DBI->connect($dsn, $user, $password);

	my $sth_dsn = $connect_ssn->prepare("SELECT ssnvalue FROM ssn WHERE ssnkey = ?");
	$sth_dsn->execute($ssnkey);
	my $ssnvalue = $sth_dsn->fetchrow;
    $sth_dsn->finish;

	return $ssnvalue;
}

sub OverduePrice {
	my ($itemnumber) = @_;

	my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("SELECT amountoutstanding FROM accountlines WHERE itemnumber = ? and accounttype = 'FU' order by date desc limit 1");
    $sth->execute($itemnumber);
    my $overdueprice = $sth->fetchrow;
    $sth->finish;

	return $overdueprice;
}

sub RemovePayment {
	my ($borrowernumber, $itemnumber) = @_;

	my $dbh = C4::Context->dbh;
	my $csth = $dbh->prepare("SELECT guarantorid FROM borrowers WHERE borrowernumber = ?");
	$csth->execute($borrowernumber);
    my $guarantor = $csth->fetchrow;
    $csth->finish;

    if ($guarantor) {
	$borrowernumber = $guarantor;
    }

    my $RemoveFineOnReturn = C4::Context->preference("RemoveFineOnReturn");
    my @notes = $RemoveFineOnReturn ? split( /\|/, $RemoveFineOnReturn ) : undef;

    foreach my $note (@notes) {
        my $msth = $dbh->prepare("UPDATE accountlines SET amountoutstanding = 0 WHERE itemnumber = ? and borrowernumber = ? and accounttype = 'B' and note = ?");
        $msth->execute( $itemnumber, $borrowernumber, $note );
        $msth->finish;
    }

}

sub CheckMessageDate {
    my ($borrowernumber, $message, $message_date) = @_;

    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("SELECT message_id FROM messages WHERE borrowernumber = ? and message = ? and DATE(message_date) = ?");
    $sth->execute($borrowernumber, $message, $message_date);
    if (my $message_id = $sth->fetchrow){
        return $message_id;
    }
    $sth->finish;

    return;
}

sub CheckBillCategory {
   my ($branchcode) = @_;

    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("SELECT categorycode FROM branchrelations WHERE branchcode = ?");
    $sth->execute($branchcode);
    while (my $categorycode = $sth->fetchrow_array) {
        if ($categorycode =~ /LASKU/i) {
            return $categorycode;
        }
    }

    $sth->finish;
    return;
}

sub branch_string {
    my (@fields) = @_;

    my $string;

    foreach my $field (@fields) {
        if (\$field == \$fields[-1]) {
            $string .= C4::Context->config("billingSetup")->{"branch"}." = '".$field->branchcode."'";
        }else{
            $string .= C4::Context->config("billingSetup")->{"branch"}." = '".$field->branchcode."' or ";
        }
    }

    return $string;

}

sub  trim {
    my $s = shift;
    if (defined $s) {$s =~ s/^\s+|\s+$//g;}
    return $s
};

1;
