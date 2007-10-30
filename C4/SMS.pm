package C4::SMS;
#Written by tgarip@neu.edu.tr for SMS message sending and other SMS related services

use strict;
require Exporter;
use LWP::UserAgent;
use C4::Context;
use vars qw($VERSION @ISA @EXPORT);
$VERSION = 0.01;
my $user=C4::Context->config('smsuser');
my $pwd=C4::Context->config('smspass');
my $uri ="https://spgw.kktcell.com/smshttpproxy/SmsHttpProxyServlet";



@ISA = qw(Exporter);

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

sub get_sms_auth {
    my $ua      = LWP::UserAgent->new;
my $commands;
 my $res=$ua->post($uri,[cmd=>'REGISTER',pUser=>$user,pPwd=>$pwd]);
	if ($res->is_success){	
	$commands=parse_content($res->content);
	}
return($commands,$ua);
}

sub send_sms{
my $ua=shift;
my $phone=shift;
my $message=shift;
my $session=shift;
 my $res=$ua->post($uri,[cmd=>'SENDSMS',pUser=>$user,pPwd=>$pwd,pSessionId=>$session,pService_Code=>4130,pMsisdn=>$phone,
		pContent=>$message]);
return parse_content($res->content);
}
sub read_sms{
my $ua=shift;
my $session=shift;
 my $res=$ua->post($uri,[cmd=>'GETSMS',pUser=>$user,pPwd=>$pwd,pSessionId=>$session,pService_Code=>4130]);
return parse_content($res->content);
}
sub parse_content{
my $content=shift;
my %commands;
my @attributes=split /&/,$content;
	foreach my $params(@attributes){
	my (@param)=split /=/,$params;
	$commands{$param[0]}=$param[1];
	}
return(\%commands);
}

sub error_codes{
my $error=shift;
if ($error==-1){
return	 "Closed session - Retry ";
}elsif($error==-2){
return	 "Invalid session - Retry ";
}elsif($error==-3){
return	 "Invalid password"	;
}elsif($error==-103){
return		 "Invalid user";
}elsif($error==-422){
return		 "Invalid Parameter";
}elsif($error==-426){
return	"User doesn’t have permission to send message";
}elsif($error==-700){
return	"No permission";
}elsif($error==-801){
return	" Msdisn count differs-warn administartor";
}elsif($error==-803){
return	"Content count differs from XSER count";
}elsif($error==-1101){
return	" Insufficient Credit	Do not retry" ;
}elsif($error==-1104){
return	"Invalid Phone number";
}elsif($error==-10001){
return	" Internal system error- Tell Turkcell/Telsim";
}elsif($error==-9005){
return	" No messages to read";
}elsif ($error){
return	"Unknow error no $error occured - tell Turkcell/Telsim";
}
}

sub parse_phone{
## checks acceptable phone numbers
## Fix to accept Telsim when available (542 numbers)
my $phone=shift;
$phone=~s/^0//g;
$phone=~s/ //g;
my $length=length($phone);
if ($length==10 || $length==12){
my $code=substr($phone,0,3) if $length==10;
 $code=substr($phone,0,5) if $length==12;
	if ($code=~/533/){
	return $phone;
	}else{
	return 0;
	}
}else{
return 0;
}
}

sub parse_message{
my $message=shift;
$message=~s/  / /g;
my @parsed=split / /,$message;
return (@parsed);
}

sub write_sms{
my ($userid,$message,$phone)=@_;
my $dbh=C4::Context->dbh;
my $sth=$dbh->prepare("INSERT into sms_messages(userid,message,user_phone,date_received) values(?,?,?,now())");
$sth->execute($userid,$message,$phone);
$sth->finish;
return $dbh->{'mysql_insertid'};
}

sub mod_sms{
my ($smsid,$message)=@_;
my $dbh=C4::Context->dbh;
my $sth=$dbh->prepare("UPDATE sms_messages set reply=? ,date_replied=now() where smsid=?");
$sth->execute($message,$smsid);
$sth->finish;
}
sub kill_sms{
#end a session
my $ua=shift;
my $session=shift;
 my $res=$ua->post($uri,[cmd=>'KILLSESSION',pSessionId=>$session]);
}
1;
__END__