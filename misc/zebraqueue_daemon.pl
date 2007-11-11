#!/usr/bin/perl

# daemon to watch the zebraqueue and update zebra as needed

use strict;
use POE qw(Wheel::SocketFactory Wheel::ReadWrite Filter::Stream Driver::SysRW);
use Unix::Syslog qw(:macros);

use C4::Context;
use C4::Biblio;
use C4::Search;
use C4::AuthoritiesMarc;
use XML::Simple;
use utf8;


my $dbh=C4::Context->dbh;
my $ident = "Koha Zebraqueue ";

my $debug = 1;
Unix::Syslog::openlog $ident, LOG_PID, LOG_LOCAL0;

Unix::Syslog::syslog LOG_INFO, "Starting Zebraqueue log at " . scalar localtime(time) . "\n";

sub handler_start {

    # Starts session. Only ever called once only really used to set an alias
    # for the POE kernel
    my ( $kernel, $heap, $session ) = @_[ KERNEL, HEAP, SESSION ];

    my $time = localtime(time);
    Unix::Syslog::syslog LOG_INFO, "$time POE Session ", $session->ID, " has started.\n";

    # check status
#    $kernel->yield('status_check');
    $kernel->yield('sleep');
}

sub handler_sleep {

    # can be used to slow down loop execution if needed
    my ( $kernel, $heap, $session ) = @_[ KERNEL, HEAP, SESSION ];

    sleep 1;
    $kernel->yield('status_check');
}

sub handler_check {
	# check if we need to do anything, at the moment just checks the zebraqueue, it could check other things too
	my ( $kernel, $heap, $session ) = @_[ KERNEL, HEAP, SESSION ];
 	my $dbh=C4::Context->dbh;
	my $sth = $dbh->prepare("SELECT count(*) AS opcount FROM zebraqueue WHERE done = 0");
    $sth->execute;
	if (my $data = $sth->fetchrow_hashref()){
		Unix::Syslog::syslog LOG_INFO, "$data->{'opcount'} operations waiting to be run\n";
		$sth->finish();
		$kernel->yield('do_ops');
	}
	else {
		$sth->finish();
		$kernel->yield('sleep');
	}
}

sub zebraop {
	# execute operations waiting in the zebraqueue
	my ( $kernel, $heap, $session ) = @_[ KERNEL, HEAP, SESSION ];
	my $dbh=C4::Context->dbh;
	my $readsth=$dbh->prepare("SELECT id,biblio_auth_number,operation,server FROM zebraqueue WHERE done=0");
	$readsth->execute();
	Unix::Syslog::syslog LOG_INFO, "Executing zebra operations\n";
	while (my $data = $readsth->fetchrow_hashref()){
		eval {
		my $ok = 0;
		if ($data->{'operation'} =~ /delete/ ){
			# 1st read the record in zebra, we have to get it from zebra as its no longer in the db
			my $Zconn=C4::Context->Zconn($data->{'server'}, 0, 1,'','xml');
			my $query = $Zconn->search_pqf( '@attr 1=Local-Number '.$data->{'biblio_auth_number'});
			# then, delete the record
			$ok=zebrado($query->record(0)->render(),$data->{'operation'},$data->{'server'},$data->{'biblio_auth_number'});
		}
		else {
			# it is an update			
			# get the XML
			my $marcxml;
			if ($data->{'server'} eq "biblioserver") {
				my $marc = GetMarcBiblio($data->{'biblio_auth_number'});
				$marcxml = $marc->as_xml_record() if $marc;
			} 
			elsif ($data->{'server'} eq "authorityserver") {                                                                                                       
				$marcxml =C4::AuthoritiesMarc::GetAuthorityXML($data->{'biblio_auth_number'});
			}
			# check it's XML, just in case
			eval {
				my $hashed=XMLin($marcxml);
			}; ### is it a proper xml? broken xml may crash ZEBRA- slow but safe
			## it's Broken XML-- Should not reach here-- but if it does -lets protect ZEBRA
			if ($@){
			     Unix::Syslog::syslog LOG_ERR, "$@";
				my $delsth=$dbh->prepare("UPDATE zebraqueue SET done=1 WHERE id =?");
				$delsth->execute($data->{'id'});
				next;
			}
			# ok, we have everything, do the operation in zebra !
			$ok=zebrado($marcxml,$data->{'operation'},$data->{'server'},$data->{'biblio_auth_number'});
		}
		if ($ok == 1){
			$dbh=C4::Context->dbh;
			my $delsth;
			# if it's a deletion, we can delete every request on this biblio : in case the user
			# did a modif (or item deletion) just before biblio deletion, there are some specialUpdate
			# that are pending and can't succeed, as we don't have the XML anymore
			# so, delete everything for this biblionumber
			if ($data->{'operation'} eq 'delete_record') {
				$delsth =$dbh->prepare("UPDATE zebraqueue SET done=1 WHERE biblio_auth_number =?");
				$delsth->execute($data->{'biblio_auth_number'});
				# if it's not a deletion, delete every pending specialUpdate for this biblionumber
				# in case the user add biblio, then X items, before this script runs
				# this avoid indexing X+1 times where just 1 is enough.
			} else {
				$delsth =$dbh->prepare("UPDATE zebraqueue SET done=1 WHERE biblio_auth_number =? and operation='specialUpdate'");
				$delsth->execute($data->{'biblionumber'});
			}
		}                            
			};
		if ($@){
			Unix::Syslog::syslog LOG_ERR, "$@";
		}
	}
	$readsth->finish();
	$kernel->yield('status_check');
}

sub zebrado {
    
    ###Accepts a $server variable thus we can use it to update  biblios, authorities or other zebra dbs
    my ($record,$op,$server,$biblionumber)=@_;
    
    my @port;
    
    my $tried=0;
    my $recon=0;
    my $reconnect=0;
#    $record=Encode::encode("UTF-8",$record);
    my $shadow=$server."shadow";
	
    $op = 'recordDelete' if $op eq 'delete_record';
reconnect:
    
    my $Zconn=C4::Context->Zconn($server, 0, 1);
    if ($record){
        my $Zpackage = $Zconn->package();
        $Zpackage->option(action => $op);
        $Zpackage->option(record => $record);
# 	    $Zpackage->option(recordIdOpaque => $biblionumber) if $biblionumber;
retry:
        $Zpackage->send("update");
        my($error, $errmsg, $addinfo, $diagset) = $Zconn->error_x();
        if ($error==10007 && $tried<3) {## timeout --another 30 looonng seconds for this update
            sleep 1;	##  wait a sec!
            $tried=$tried+1;
            goto "retry";
        }elsif ($error==2 && $tried<2) {## timeout --temporary zebra error !whatever that means
            sleep 2;	##  wait two seconds!
            $tried=$tried+1;
            goto "retry";
        }elsif($error==10004 && $recon==0){##Lost connection -reconnect
            sleep 1;	##  wait a sec!
            $recon=1;
            $Zpackage->destroy();
            $Zconn->destroy();
            goto "reconnect";
        }elsif ($error){
            $Zpackage->destroy();
            $Zconn->destroy();
            return 0;
        }
        $Zpackage->send('commit');
    return 1;
    }
    return 0;
}


sub handler_stop {
    my $heap = $_[HEAP];
    my $time = localtime(time);
    Unix::Syslog::syslog LOG_INFO, "$time Session ", $_[SESSION]->ID, " has stopped.\n";
    delete $heap->{session};
}

POE::Session->create(
    inline_states => {
        _start       => \&handler_start,
        sleep        => \&handler_sleep,
		status_check => \&handler_check,
		do_ops       => \&zebraop,
        _stop        => \&handler_stop,
    },
);

# start the kernel
$poe_kernel->run();

Unix::Syslog::closelog;

exit;
