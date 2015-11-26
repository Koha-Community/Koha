#!/usr/bin/perl

use strict;
use warnings;

use C4::SMS;
use C4::Auth;
use C4::Context;
use C4::Members;
use C4::Circulation;

my ($res,$ua);
my $message;
my $result;
my $errorcode;
my $smsid;
my $wait=600;## 10 mn. wait between sms checking
my $dbh=C4::Context->dbh;

STARTAGAIN:
($res,$ua)=get_sms_auth();
AGAIN:
$errorcode=0;
if ($res->{pRetCode}==200){
	$result=read_sms($ua,$res->{pSessionId});
	$errorcode=$result->{pErrCode};
	print "connected\n";
} else {
	kill_sms($ua,$res->{pSessionId});
	warn (error_codes($res->{pErrCode}),$res->{pErrcode}) ;
#	sleep $wait;
	goto FINISH;
}
if ($errorcode && $errorcode !=-9005){
	kill_sms($ua,$res->{pSessionId});
	warn error_codes($errorcode) ;
	# sleep $wait;
	goto FINISH;
} elsif ($errorcode ==-9005){
	print "no more messages to read\n";
	goto WAITING;
}


#Parse the message to a useful hash
my @action=parse_message( $result->{pContent});
## Log the request in our database;
$smsid=write_sms($action[1], $result->{pContent},$result->{pMsisdn});
print "message logged\n";
##Now do the service required
if (uc($action[0]) eq "RN"){
	print "dealing request\n";
	my ($ok,$cardnumber)=C4::Auth::checkpw($dbh,$action[1],$action[2]);
    unless ($ok) {
		##wrong user/pass
		$message="Yanlis kullanici/sifre! :Wrong username/password!";
		my $send=send_message($result,$message,$smsid);
		goto AGAIN;
    }
	my $item=getiteminformation(undef,0,$action[3]);
	if ($item){
		my $borrower=getmember($cardnumber);
		my $status=renewstatus(undef,$borrower->{borrowernumber},$item->{itemnumber});
		if ($status==1) {
			my $date=renewbook(undef,$borrower->{borrowernumber},$item->{itemnumber});
			$message="Uzatildi :Renewed ".$item->{barcode}." : ".$date;
		} elsif($status==2) {
			$message="Cok erken- yenilenmedi! :Too early-not renewed:".$item->{barcode};
		} elsif($status==3) {
			$message="Uzatamazsiniz GERI getiriniz! :No more renewals RETURN the item:".$item->{barcode};
		} elsif($status==4) {
			$message="Ayirtildi GERI getiriniz! :Reserved RETURN the item:".$item->{barcode};
		} elsif($status==0) {
			$message="Uzatilamaz! :Can not renew:".$item->{barcode};
		}
	} else {
	   $message="Yanlis barkot! :Wrong barcode!";
	}	
} else {
	## reply about error
	$message="Yanlis mesaj formati! :Wrong message! :
		 RN usercardno password barcode";
}	### wrong service
send_message($result,$message,$smsid);

goto AGAIN;


WAITING:
##Now send the messages waiting in queue
my $smssth=$dbh->prepare("SELECT smsid,user_phone,message from sms_messages where date_replied like '0000-00-00%' ");
$smssth->execute();
my @phones;
while (my $data=$smssth->fetchrow_hashref){
	push @phones,$data;
}
$smssth->finish;

foreach my $user(@phones){
	print "replying $user->{user_phone}";
	my $send=send_sms($ua,$user->{user_phone},$user->{message},$res->{pSessionId});
	my $reply="--failed\n";
	if ($send->{pRetCode}==200){
		$reply= "--replied\n";
		mod_sms($user->{smsid},"Sent");
	}
	print $reply;
}

sub send_message {
	my ($mes,$message,$smsid)=@_;
	my $send=send_sms($ua,$mes->{pMsisdn},$message,$res->{pSessionId});
	if ($send->{pRetCode}==200){
		mod_sms($smsid,$message);
	} else {
		my $error=error_codes($send->{pErrCode});
		mod_sms($smsid,"Not replied error:".$error);
	}
	return $send;
}
FINISH:
1;
__END__
