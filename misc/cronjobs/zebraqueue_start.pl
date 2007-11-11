#!/usr/bin/perl
# script that starts the zebraquee
#  Written by TG on 01/08/2006
use strict;


use C4::Context;
use C4::Biblio;
use C4::Search;
use C4::AuthoritiesMarc;
use XML::Simple;
use utf8;
### ZEBRA SERVER UPDATER
##Uses its own database handle
my $dbh=C4::Context->dbh;
my $readsth=$dbh->prepare("SELECT id,biblio_auth_number,operation,server FROM zebraqueue WHERE done=0 
                           ORDER BY id DESC"); # NOTE - going in reverse order to catch deletes that
                                               # occur after a string of updates (e.g., user deletes
                                               # the items attached to a bib, then the items.
                                               # Having a specialUpdate occur after a recordDelete
                                               # should not occur.
#my $delsth=$dbh->prepare("delete from zebraqueue where id =?");


#AGAIN:

#my $wait=C4::Context->preference('zebrawait') || 120;
my $verbose = 1;
print "starting with verbose=$verbose\n" if $verbose;

my ($id,$biblionumber,$operation,$server,$marcxml);

$readsth->execute;
while (($id,$biblionumber,$operation,$server)=$readsth->fetchrow){
    print "read in queue : $id : biblio $biblionumber for $operation on $server\n" if $verbose;
    my $ok;
    eval{
        # if the operation is a deletion, zebra requires that we give it the xml.
        # as it is no more in the SQL db, retrieve it from zebra itself.
        # may sound silly, but that's the way zebra works ;-)
	    if ($operation =~ /delete/i) { # NOTE depending on version, delete operation
                                       #      was coded 'delete_record' or 'recordDelete'.
                                       #      'recordDelete' is the preferred one, as that's
                                       #      what the ZOOM API wants.
	       # 1st read the record in zebra
            my $Zconn=C4::Context->Zconn($server, 0, 1,'','xml');
            my $query = $Zconn->search_pqf( '@attr 1=Local-Number '.$biblionumber);
            # then, delete the record
	        $ok=zebrado($query->record(0)->render(),$operation,$server,$biblionumber);
        # if it's an add or a modif
        } else {
            # get the XML
            if ($server eq "biblioserver") {
                my $marc = GetMarcBiblio($biblionumber);
                $marcxml = $marc->as_xml_record() if $marc;
            } elsif ($server eq "authorityserver") {
                $marcxml =C4::AuthoritiesMarc::GetAuthorityXML($biblionumber);
            }
            if ($verbose) {
                if ($marcxml) {
                    print "XML read : $marcxml\n" if $verbose >1;
                } else {
                # workaround for zebra bug needing a XML even for deletion
                $marcxml= "<dummy/>";
                    print "unable to read MARCxml\n" if $verbose;
                }
            }
            # check it's XML, just in case
            eval {
                my $hashed=XMLin($marcxml);
            }; ### is it a proper xml? broken xml may crash ZEBRA- slow but safe
            ## it's Broken XML-- Should not reach here-- but if it does -lets protect ZEBRA
            if ($@){
                warn $@;
                my $delsth=$dbh->prepare("UPDATE zebraqueue SET done=1 WHERE id =?");
                $delsth->execute($id);
                next;
            }
            # ok, we have everything, do the operation in zebra !
            $ok=zebrado($marcxml,$operation,$server);
        }
    };
    print "ZEBRAopserver returned : $ok \n" if $verbose;
    if ($ok ==1) {
        $dbh=C4::Context->dbh;
        my $delsth;
        # if it's a deletion, we can delete every request on this biblio : in case the user
        # did a modif (or item deletion) just before biblio deletion, there are some specialUpdage
        # that are pending and can't succeed, as we don't have the XML anymore
        # so, delete everything for this biblionumber
        my $reset_readsth = 0;
        if ($operation eq 'recordDelete') {
            print "deleting biblio deletion $biblionumber\n" if $verbose;
            $delsth =$dbh->prepare("UPDATE zebraqueue SET done=1 WHERE biblio_auth_number =?");
            $delsth->execute($biblionumber);
            $reset_readsth = 1 if $delsth->rows() > 0;
        # if it's not a deletion, delete every pending specialUpdate for this biblionumber
        # in case the user add biblio, then X items, before this script runs
        # this avoid indexing X+1 times where just 1 is enough.
        } else {
            print "deleting special date for $biblionumber\n" if $verbose;
            $delsth =$dbh->prepare("UPDATE zebraqueue SET done=1 WHERE biblio_auth_number =? and operation='specialUpdate'");
            $delsth->execute($biblionumber);
            $reset_readsth = 1 if $delsth->rows() > 0;
        }
        if ($reset_readsth) {
            # if we can ignore rows in zebraqueue because we've already
            # touched a record, reset the query. 
            $readsth->finish();
            $readsth->execute();
        }
    }
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
        print "updating $op on $biblionumber for server $server\n $record\n" if $verbose;
        my $Zpackage = $Zconn->package();
        $Zpackage->option(action => $op);
        $Zpackage->option(record => $record);
# 	    $Zpackage->option(recordIdOpaque => $biblionumber) if $biblionumber;
retry:
        $Zpackage->send("update");
        my($error, $errmsg, $addinfo, $diagset) = $Zconn->error_x();
        if ($error==10007 && $tried<3) {## timeout --another 30 looonng seconds for this update
            print "error 10007\n" if $verbose;
            sleep 1;	##  wait a sec!
            $tried=$tried+1;
            goto "retry";
        }elsif ($error==2 && $tried<2) {## timeout --temporary zebra error !whatever that means
            print "error 2\n" if $verbose;
            sleep 2;	##  wait two seconds!
            $tried=$tried+1;
            goto "retry";
        }elsif($error==10004 && $recon==0){##Lost connection -reconnect
            print "error 10004\n" if $verbose;
            sleep 1;	##  wait a sec!
            $recon=1;
            $Zpackage->destroy();
            $Zconn->destroy();
            goto "reconnect";
        }elsif ($error){
        #	warn "Error-$server   $op  /errcode:, $error, /MSG:,$errmsg,$addinfo \n";	
            print "error $error\n" if $verbose;
            $Zpackage->destroy();
            $Zconn->destroy();
            return 0;
        }
        $Zpackage->send('commit');
#     $Zpackage->destroy();
#     $Zconn->destroy();
    return 1;
    }
    return 0;
}
