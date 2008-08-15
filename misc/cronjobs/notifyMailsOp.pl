#!/usr/bin/perl
use strict;
BEGIN {
    # find Koha's Perl modules
    # test carefully before changing this
    use FindBin;
    eval { require "$FindBin::Bin/../kohalib.pl" };
}
use C4::Context;
use C4::Dates qw/format_date/;
use Mail::Sendmail;  # comment out if not doing e-mail notices
use Getopt::Long;
use C4::Circulation;
# use C4::Members;
#  this module will notify only the mail case
# Now it's only programmed for ouest provence, you can modify it for yourself
# sub function for get all notifications are not sends
sub GetNotifys {
# 	my($branch) = @_;
 	my $dbh = C4::Context->dbh;
	my $sth=$dbh->prepare("SELECT DISTINCT notifys.borrowernumber , borrowers.surname , borrowers.firstname , borrowers.title AS borrower_title , categories.category_type AS categorycode , borrowers.email , borrowers.contacttitle , borrowers.contactname , borrowers.contactfirstname ,
	notifys.notify_level , notifys.method
	FROM notifys,borrowers,categories WHERE (notifys.borrowernumber=borrowers.borrowernumber) AND (notifys.notify_send_date IS NULL) AND (borrowers.categorycode = categories.categorycode)");
	
	$sth->execute();
		my @getnotifys;
		my $i=0;
		while (my $data=$sth->fetchrow_hashref){
			$getnotifys[$i]=$data;
			$i++;	
		}
		$sth->finish;
		return(@getnotifys);

}

sub GetBorrowerNotifys{
	my ($borrowernumber) = @_;
	my $dbh = C4::Context->dbh;
	my @getnotifys2;
	my $sth2=$dbh->prepare("SELECT notifys.itemnumber,notifys.notify_level,biblio.title ,itemtypes.description,
			issues.date_due
			FROM notifys,biblio,items,itemtypes,biblioitems,issues 
			WHERE
			(items.itemnumber=notifys.itemnumber
			AND biblio.biblionumber=items.biblionumber)
			AND (itemtypes.itemtype=biblioitems.itemtype AND biblioitems.biblionumber=biblio.biblionumber)
			AND
			(notifys.borrowernumber=issues.borrowernumber AND notifys.itemnumber=issues.itemnumber)
			AND
			notifys.borrowernumber=?
			AND notify_send_date IS NULL");
			$sth2->execute($borrowernumber);
			my $j=0;
			while (my $data2=$sth2->fetchrow_hashref){
				$getnotifys2[$j]=$data2;
				$j++;
			}
			$sth2->finish;
			return(@getnotifys2);

}

sub GetOverduerules{
	my($category,$notify_level) = @_;
	my $dbh = C4::Context->dbh;
    	my $sth=$dbh->prepare("SELECT letter".$notify_level.",debarred".$notify_level." FROM overduerules WHERE categorycode=?");
    	$sth->execute($category);
    	my (@overduerules)=$sth->fetchrow_array;
    	$sth->finish;
    	return(@overduerules);

}

sub GetLetter{

	my($letterid) = @_;
	my $dbh = C4::Context->dbh;
    	my $sth=$dbh->prepare("SELECT title,content FROM letter WHERE code=?");
    	$sth->execute($letterid);
    	my (@getletter)=$sth->fetchrow_array;
    	$sth->finish;
    	return(@getletter);

}

sub UpdateBorrowerDebarred{
	my($borrowernumber) = @_;
	my $dbh = C4::Context->dbh;
    	my $sth=$dbh->prepare("UPDATE borrowers SET debarred='1' WHERE borrowernumber=?");
    	$sth->execute($borrowernumber);
    	$sth->finish;
    	return 1;
}

sub UpdateNotifySendDate{
	my($borrowernumber,$itemnumber,$notifyLevel) = @_;
	my $dbh = C4::Context->dbh;
    	my $sth=$dbh->prepare("UPDATE notifys SET notify_send_date=now() 
    	WHERE borrowernumber=? AND itemnumber=? AND notify_send_date IS NULL AND notify_level=?");
    	$sth->execute($borrowernumber,$itemnumber,$notifyLevel);
    	$sth->finish;
    	return 1;

}

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 

# work with get notifys
my $smtpserver = 'smtp.yoursmtpserver'; # your smtp server (the server who sent mails)
my $from = 'your@librarymailadress'; # all the mails sent to the borrowers will appear coming from here.


# initiate file for wrong_mails
my $outfile = 'wrong_mails.txt';
open( OUT, ">$outfile" );
binmode(OUT, 'utf8');

my @getnofifys = GetNotifys();
foreach my $num (@getnofifys) {
	my %notify;	
# 	if we have a method mail, we check witch mail letter we launch
	if ($num->{'method'} eq 'mail'){
		my ($letterid,$debarred) = GetOverduerules($num->{'categorycode'},$num->{'notify_level'});
# 			now, we get the letter associated to letterid
			my($title,$content) = GetLetter($letterid);
			my $email = $num->{'email'};
			#my $email = 'alaurin@ouestprovence.fr';
			my $mailtitle = $title; # the title of the mails
# Work with the adult category code
				if ($num->{'categorycode'} eq 'A') {
	# 			now deal with $content
					$content =~ s/\<<borrowers.title>\>/$num->{'borrower_title'}/g ;
					$content =~ s/\<<borrowers.surname>\>/$num->{'surname'}/g ;
					$content =~ s/\<<borrowers.firstname>\>/$num->{'firstname'}/g ;
					
					my @getborrowernotify=GetBorrowerNotifys($num->{'borrowernumber'});
					my $overdueitems;
					foreach my $notif(@getborrowernotify){
						my $date=format_date($notif->{'date_due'});
						if ($notif->{'notify_level'} eq $num->{'notify_level'}){
						$overdueitems .= " - <b>".$notif->{'title'}."</b>" ;
						$overdueitems .= "  ( ".$notif->{'description'}." )  " ;
						$overdueitems .= "emprunté le :".$date;
						$overdueitems .= "<br>";
						
# FIXME at this time, the program consider the mail is send (in notify_send_date) but with no real check must be improved , we don't know if the mail was really to a real adress, and if there is a problem, we don't know how to return the notification to koha...
	UpdateNotifySendDate($num->{'borrowernumber'},$notif->{'itemnumber'},$num->{'notify_level'});
}
					}
				# if we don't have overdueitem replace content by nonotifys value, deal with it later
					if ($overdueitems){	
					$content =~ s/\<<items.content>\>/$overdueitems/g;
				}
				else {
				$content = 'nonotifys';
				}
			}
# Work with the child category code (we add the parents infos)
				if ($num->{'categorycode'} eq 'C') {
					$content =~ s/\<<borrowers.contacttitle>\>/$num->{'contacttitle'}/g ;
					$content =~ s/\<<borrowers.contactname>\>/$num->{'contactname'}/g ;
					$content =~ s/\<<borrowers.contactfirstname>\>/$num->{'contactfirstname'}/g ;
					$content =~ s/\<<borrowers.title>\>/$num->{'borrower_title'}/g ;
					$content =~ s/\<<borrowers.surname>\>/$num->{'surname'}/g ;
					$content =~ s/\<<borrowers.firstname>\>/$num->{'firstname'}/g ;
					
					my @getborrowernotify=GetBorrowerNotifys($num->{'borrowernumber'});
					my $overdueitems;
					foreach my $notif(@getborrowernotify){
						my $date=format_date($notif->{'date_due'});
						
						$overdueitems .= " - <b>".$notif->{'title'}."</b>" ;
						$overdueitems .= "  ( ".$notif->{'description'}." )  " ;
						$overdueitems .= "emprunté le :".$date;
						$overdueitems .= "<br>";
# FIXME at this time, the program consider the mail is send (in notify_send_date) but with no real check must be improved ...
				UpdateNotifySendDate($num->{'borrowernumber'},$notif->{'itemnumber'},$num->{'notify_level'});
						}
					
					if ($overdueitems){
						$content =~ s/\<<items.content>\>/$overdueitems/g;
					}
					else {
					$content = 'nonotifys';
					}
				}
# initiate the send mail

#       decoding mailtitle for lisibility of mailtitle (bug with utf-8 values, so decoding it)
        utf8::decode($mailtitle);

			my $mailtext = $content;
				unshift @{$Mail::Sendmail::mailcfg{'smtp'}} , $smtpserver;
#                                         set your own mail server name here
					my %mail = ( To      => $email,
								From    => $from,
								Subject => $mailtitle,
								Message => $mailtext,
								'content-type' => 'text/html; charset="utf-8"',
					);
				# if we don't have any content for the mail, we don't launch mail, but notify it in a file
					if ($mailtext ne 'nonotifys') {
					sendmail(%mail);
					}
					else {
					print OUT $email ;
					}
					
# now deal with the debarred mode
#		if ($debarred eq 1) {
# 		�ajouter : si le lecteur est en mode debarred, ajouter la fonction qui nous permettra cela
#		UpdateBorrowerDebarred($num->{'borrowernumber'});
#		}
	close(OUT);
	}
}
