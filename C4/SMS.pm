package C4::SMS;
#Written by tgarip@neu.edu.tr for SMS message sending and other SMS related services

use strict;
use warnings;

use LWP::UserAgent;
use C4::Context;

use vars qw($VERSION @ISA @EXPORT);

BEGIN {
	require Exporter;
	@ISA = qw(Exporter);
	$VERSION = 0.03;
	@EXPORT = qw(
		&get_sms_auth 
		&send_sms 
		&read_sms
		&error_codes
		&parse_phone
		&parse_message
		&write_sms
		&mod_sms
		&kill_sms
	);
}

our $user = C4::Context->config('smsuser');
our $pwd  = C4::Context->config('smspass');
our $uri  = "https://spgw.kktcell.com/smshttpproxy/SmsHttpProxyServlet";


sub get_sms_auth {
    my $ua = LWP::UserAgent->new;
	my $commands;
	my $res=$ua->post($uri,[cmd=>'REGISTER',pUser=>$user,pPwd=>$pwd]);
	if ($res->is_success){	
		$commands=parse_content($res->content);
	}
	return($commands,$ua);
}

sub send_sms {
	my $ua = shift or return undef;
	my $phone=shift;
	my $message=shift;
	my $session=shift;
	my $res=$ua->post($uri,[cmd=>'SENDSMS',pUser=>$user,pPwd=>$pwd,pSessionId=>$session,pService_Code=>4130,pMsisdn=>$phone,
		pContent=>$message]);
	return parse_content($res->content);
}

sub read_sms {
	my $ua = shift or return undef;
	my $session=shift;
	my $res=$ua->post($uri,[cmd=>'GETSMS',pUser=>$user,pPwd=>$pwd,pSessionId=>$session,pService_Code=>4130]);
	return parse_content($res->content);
}

sub parse_content {
	my $content = shift;
	my %commands;
	my @attributes = split /&/,$content;
	foreach my $params(@attributes){
		my (@param) = split /=/,$params;
		$commands{$param[0]}=$param[1];
	}
	return(\%commands);
}

sub error_codes {
	my $error = shift;
	($error==    -1) and return	"Closed session - Retry";
	($error==    -2) and return	"Invalid session - Retry";
	($error==    -3) and return	"Invalid password";
	($error==  -103) and return	"Invalid user";
	($error==  -422) and return	"Invalid Parameter";
	($error==  -426) and return	"User does not have permission to send message";
	($error==  -700) and return	"No permission";
	($error==  -801) and return	"Msdisn count differs - warn administartor";
	($error==  -803) and return	"Content count differs from XSER count";
	($error== -1101) and return	"Insufficient Credit -  Do not retry";
	($error== -1104) and return	"Invalid Phone number";
	($error==-10001) and return	"Internal system error - Notify provider";
	($error== -9005) and return	"No messages to read";
	if ($error){
		warn "Unknown SMS error '$error' occured";
		return	"Unknown SMS error '$error' occured";
	}
}

sub parse_phone {
	## checks acceptable phone numbers
	## FIXME: accept Telsim when available (542 numbers)
	my $phone=shift;
	$phone=~s/^0//g;
	$phone=~s/ //g;
	my $length=length($phone);
	if ($length==10 || $length==12){
		my $code=substr($phone,0,3) if $length==10;
		   $code=substr($phone,0,5) if $length==12;
		if ($code=~/533/){
			return $phone;
		}
	}
	return 0;
}

sub parse_message {
	my $message = shift;
	$message =~ s/  / /g;
	my @parsed = split / /, $message;
	return (@parsed);
}

sub write_sms {
	my ($userid,$message,$phone)=@_;
	my $dbh=C4::Context->dbh;
	my $sth=$dbh->prepare("INSERT into sms_messages(userid,message,user_phone,date_received) values(?,?,?,now())");
	$sth->execute($userid,$message,$phone);
	$sth->finish;
	return $dbh->{'mysql_insertid'};	# FIXME: mysql specific
}

sub mod_sms {
	my ($smsid,$message)=@_;
	my $dbh=C4::Context->dbh;
	my $sth=$dbh->prepare("UPDATE sms_messages set reply=?, date_replied=now() where smsid=?");
	$sth->execute($message,$smsid);
}

sub kill_sms {
	#end a session
	my $ua = shift or return undef;
	my $session = shift;
	my $res = $ua->post($uri,[cmd=>'KILLSESSION',pSessionId=>$session]);
}
1;
__END__
