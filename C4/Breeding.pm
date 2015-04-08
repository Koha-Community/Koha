package C4::Breeding;

# Copyright 2000-2002 Katipo Communications
# Parts Copyright 2013 Prosentient Systems
#
# This file is part of Koha.
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
use C4::Koha;
use C4::Charset;
use MARC::File::USMARC;
use C4::ImportBatch;
use C4::AuthoritiesMarc; #GuessAuthTypeCode, FindDuplicateAuthority
use C4::Languages;
use Koha::Database;
use Koha::XSLT_Handler;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

BEGIN {
	# set the version for version checking
    $VERSION = 3.07.00.049;
	require Exporter;
	@ISA = qw(Exporter);
    @EXPORT = qw(&BreedingSearch &Z3950Search &Z3950SearchAuth);
}

=head1 NAME

C4::Breeding : module to add biblios to import_records via
               the breeding/reservoir API.

=head1 SYNOPSIS

    Z3950Search($pars, $template);
    ($count, @results) = &BreedingSearch($title,$isbn,$random);

=head1 DESCRIPTION

This module contains routines related to Koha's Z39.50 search into
cataloguing reservoir features.

=head2 BreedingSearch

($count, @results) = &BreedingSearch($title,$isbn,$random);
C<$title> contains the title,
C<$isbn> contains isbn or issn,
C<$random> contains the random seed from a z3950 search.

C<$count> is the number of items in C<@results>. C<@results> is an
array of references-to-hash; the keys are the items from the C<import_records> and
C<import_biblios> tables of the Koha database.

=cut

sub BreedingSearch {
    my ($search,$isbn,$z3950random) = @_;
    my $dbh   = C4::Context->dbh;
    my $count = 0;
    my ($query,@bind);
    my $sth;
    my @results;

    # normalise ISBN like at import
    $isbn = C4::Koha::GetNormalizedISBN($isbn);

    $query = "SELECT import_record_id, file_name, isbn, title, author
              FROM  import_biblios 
              JOIN import_records USING (import_record_id)
              JOIN import_batches USING (import_batch_id)
              WHERE ";
    if ($z3950random) {
        $query .= "z3950random = ?";
        @bind=($z3950random);
    } else {
        @bind=();
        if (defined($search) && length($search)>0) {
            $search =~ s/(\s+)/\%/g;
            $query .= "title like ? OR author like ?";
            push(@bind,"%$search%", "%$search%");
        }
        if ($#bind!=-1 && defined($isbn) && length($isbn)>0) {
            $query .= " and ";
        }
        if (defined($isbn) && length($isbn)>0) {
            $query .= "isbn like ?";
            push(@bind,"$isbn%");
        }
    }
    $sth   = $dbh->prepare($query);
    $sth->execute(@bind);
    while (my $data = $sth->fetchrow_hashref) {
            $results[$count] = $data;
            # FIXME - hack to reflect difference in name 
            # of columns in old marc_breeding and import_records
            # There needs to be more separation between column names and 
            # field names used in the templates </soapbox>
            $data->{'file'} = $data->{'file_name'};
            $data->{'id'} = $data->{'import_record_id'};
            $count++;
    } # while

    $sth->finish;
    return($count, @results);
} # sub breedingsearch


=head2 Z3950Search

Z3950Search($pars, $template);

Parameters for Z3950 search are all passed via the $pars hash. It may contain isbn, title, author, dewey, subject, lccall, controlnumber, stdid, srchany.
Also it should contain an arrayref id that points to a list of id's of the z3950 targets to be queried (see z3950servers table).
This code is used in acqui/z3950_search and cataloging/z3950_search.
The second parameter $template is a Template object. The routine uses this parameter to store the found values into the template.

=cut

sub Z3950Search {
    my ($pars, $template)= @_;

    my @id= @{$pars->{id}};
    my $page= $pars->{page};
    my $biblionumber= $pars->{biblionumber};

    my $show_next       = 0;
    my $total_pages     = 0;
    my @results;
    my @breeding_loop = ();
    my @oConnection;
    my @oResult;
    my @errconn;
    my $s = 0;
    my $imported=0;

    my ( $zquery, $squery ) = _build_query( $pars );

    my $schema = Koha::Database->new()->schema();
    my $rs = $schema->resultset('Z3950server')->search(
        { id => [ @id ] },
        { result_class => 'DBIx::Class::ResultClass::HashRefInflator' },
    );
    my @servers = $rs->all;
    foreach my $server ( @servers ) {
        $oConnection[$s] = _create_connection( $server );
        $oResult[$s] =
            $server->{servertype} eq 'zed'?
                $oConnection[$s]->search_pqf( $zquery ):
                $oConnection[$s]->search(new ZOOM::Query::CQL(
                    _translate_query( $server, $squery )));
        $s++;
    }
    my $xslh = Koha::XSLT_Handler->new;

    my $nremaining = $s;
    while ( $nremaining-- ) {
        my $k;
        my $event;
        while ( ( $k = ZOOM::event( \@oConnection ) ) != 0 ) {
            $event = $oConnection[ $k - 1 ]->last_event();
            last if $event == ZOOM::Event::ZEND;
        }

        if ( $k != 0 ) {
            $k--;
            my ($error)= $oConnection[$k]->error_x(); #ignores errmsg, addinfo, diagset
            if ($error) {
                if ($error =~ m/^(10000|10007)$/ ) {
                    push(@errconn, { server => $servers[$k]->{host}, error => $error } );
                }
            }
            else {
                my $numresults = $oResult[$k]->size();
                my $i;
                my $res;
                if ( $numresults > 0  and $numresults >= (($page-1)*20)) {
                    $show_next = 1 if $numresults >= ($page*20);
                    $total_pages = int($numresults/20)+1 if $total_pages < ($numresults/20);
                    for ($i = ($page-1)*20; $i < (($numresults < ($page*20)) ? $numresults : ($page*20)); $i++) {
                        if ( $oResult[$k]->record($i) ) {
                            undef $error;
                            ( $res, $error ) = _handle_one_result( $oResult[$k]->record($i), $servers[$k], ++$imported, $biblionumber, $xslh ); #ignores error in sequence numbering
                            push @breeding_loop, $res if $res;
                            push @errconn, { server => $servers[$k]->{servername}, error => $error, seq => $i+1 } if $error;
                        }
                        else {
                            push @errconn, { 'server' => $servers[$k]->{servername}, error => ( ( $oConnection[$k]->error_x() )[0] ), seq => $i+1 };
                        }
                    }
                }    #if $numresults
            }
        }    # if $k !=0

        $template->param(
            numberpending => $nremaining,
            current_page => $page,
            total_pages => $total_pages,
            show_nextbutton => $show_next?1:0,
            show_prevbutton => $page!=1,
        );
    } # while nremaining

    #close result sets and connections
    foreach(0..$s-1) {
        $oResult[$_]->destroy();
        $oConnection[$_]->destroy();
    }

    $template->param(
        breeding_loop => \@breeding_loop,
        servers => \@servers,
        errconn       => \@errconn
    );
}

sub _build_query {
    my ( $pars ) = @_;

    my $qry_build = {
        isbn    => '@attr 1=7 @attr 5=1 "#term" ',
        issn    => '@attr 1=8 @attr 5=1 "#term" ',
        title   => '@attr 1=4 "#term" ',
        author  => '@attr 1=1003 "#term" ',
        dewey   => '@attr 1=16 "#term" ',
        subject => '@attr 1=21 "#term" ',
        lccall  => '@attr 1=16 @attr 2=3 @attr 3=1 @attr 4=1 @attr 5=1 '.
                   '@attr 6=1 "#term" ',
        controlnumber => '@attr 1=12 "#term" ',
        srchany => '@attr 1=1016 "#term" ',
        stdid   => '@attr 1=1007 "#term" ',
    };

    my $zquery='';
    my $squery='';
    my $nterms=0;
    foreach my $k ( sort keys %$pars ) {
    #note that the sort keys forces an identical result under Perl 5.18
    #one of the unit tests is based on that assumption
        if( ( my $val=$pars->{$k} ) && $qry_build->{$k} ) {
            $qry_build->{$k} =~ s/#term/$val/g;
            $zquery .= $qry_build->{$k};
            $squery .= "[$k]=\"$val\" and ";
            $nterms++;
        }
    }
    $zquery = "\@and " . $zquery for 2..$nterms;
    $squery =~ s/ and $//;
    return ( $zquery, $squery );
}

sub _handle_one_result {
    my ( $zoomrec, $servhref, $seq, $bib, $xslh )= @_;

    my $raw= $zoomrec->raw();
    my $marcrecord;
    if( $servhref->{servertype} eq 'sru' ) {
        $marcrecord= MARC::Record->new_from_xml( $raw, 'UTF-8',
            $servhref->{syntax} );
    } else {
        ($marcrecord) = MarcToUTF8Record($raw, C4::Context->preference('marcflavour'), $servhref->{encoding} // "iso-5426" ); #ignores charset return values
    }
    SetUTF8Flag($marcrecord);
    my $error;
    ( $marcrecord, $error ) = _do_xslt_proc($marcrecord, $servhref, $xslh);

    my $batch_id = GetZ3950BatchId($servhref->{servername});
    my $breedingid = AddBiblioToBatch($batch_id, $seq, $marcrecord, 'UTF-8', 0, 0);
        #FIXME passing 0 for z3950random
        #Will eliminate this unused field in a followup report
        #Last zero indicates: no update for batch record counts


    #call to TransformMarcToKoha replaced by next call
    #we only need six fields from the marc record
    my $row;
    $row = _add_rowdata(
        {
            biblionumber => $bib,
            server       => $servhref->{servername},
            breedingid   => $breedingid,
        }, $marcrecord) if $breedingid;
    return ( $row, $error );
}

sub _do_xslt_proc {
    my ( $marc, $server, $xslh ) = @_;
    return $marc if !$server->{add_xslt};

    my $htdocs = C4::Context->config('intrahtdocs');
    my $theme = C4::Context->preference("template"); #staff
    my $lang = C4::Languages::getlanguage() || 'en';

    my @files= split ',', $server->{add_xslt};
    my $xml = $marc->as_xml;
    foreach my $f ( @files ) {
        $f =~ s/^\s+//; $f =~ s/\s+$//; next if !$f;
        $f = C4::XSLT::_get_best_default_xslt_filename(
            $htdocs, $theme, $lang, $f ) unless $f =~ /^\//;
        $xml = $xslh->transform( $xml, $f );
        last if $xslh->err; #skip other files
    }
    if( !$xslh->err ) {
        return MARC::Record->new_from_xml($xml, 'UTF-8');
    } else {
        return ( $marc, 'xslt_err' ); #original record in case of errors
    }
}

sub _add_rowdata {
    my ($row, $record)=@_;
    my %fetch= (
        title => 'biblio.title',
        author => 'biblio.author',
        isbn =>'biblioitems.isbn',
        lccn =>'biblioitems.lccn', #LC control number (not call number)
        edition =>'biblioitems.editionstatement',
        date => 'biblio.copyrightdate', #MARC21
        date2 => 'biblioitems.publicationyear', #UNIMARC
    );
    foreach my $k (keys %fetch) {
        my ($t, $f)= split '\.', $fetch{$k};
        $row= C4::Biblio::TransformMarcToKohaOneField($t, $f, $record, $row);
        $row->{$k}= $row->{$f} if $k ne $f;
    }
    $row->{date}//= $row->{date2};
    $row->{isbn}=_isbn_replace($row->{isbn});
    return $row;
}

sub _isbn_replace {
    my ($isbn) = @_;
    return unless defined $isbn;
    $isbn =~ s/ |-|\.//g;
    $isbn =~ s/\|/ \| /g;
    $isbn =~ s/\(/ \(/g;
    return $isbn;
}

sub _create_connection {
    my ( $server ) = @_;
    my $option1= new ZOOM::Options();
    $option1->option( 'async' => 1 );
    $option1->option( 'elementSetName', 'F' );
    $option1->option( 'preferredRecordSyntax', $server->{syntax} );
    $option1->option( 'timeout', $server->{timeout} ) if $server->{timeout};

    if( $server->{servertype} eq 'sru' ) {
        foreach( split ',', $server->{sru_options}//'' ) {
            #first remove surrounding spaces at comma and equals-sign
            s/^\s+|\s+$//g;
            my @temp= split '=', $_, 2;
            @temp= map { my $c=$_; $c=~s/^\s+|\s+$//g; $c; } @temp;
            $option1->option( $temp[0] => $temp[1] ) if @temp;
        }
    } elsif( $server->{servertype} eq 'zed' ) {
        $option1->option( 'databaseName',   $server->{db} );
        $option1->option( 'user', $server->{userid} ) if $server->{userid};
        $option1->option( 'password', $server->{password} ) if $server->{password};
    }

    my $obj= ZOOM::Connection->create($option1);
    if( $server->{servertype} eq 'sru' ) {
        my $host= $server->{host};
        if( $host !~ /^https?:\/\// ) {
            #Normally, host will not be prefixed by protocol.
            #In that case we can (safely) assume http.
            #In case someone prefixed with https, give it a try..
            $host = 'http://' . $host;
        }
        $obj->connect( $host.':'.$server->{port}.'/'.$server->{db} );
    } else {
        $obj->connect( $server->{host}, $server->{port} );
    }
    return $obj;
}

sub _translate_query { #SRU query adjusted per server cf. srufields column
    my ($server, $query) = @_;

    #sru_fields is in format title=field,isbn=field,...
    #if a field doesn't exist, try anywhere or remove [field]=
    my @parts= split(',', $server->{sru_fields} );
    my %trans= map { if( /=/ ) { ( $`,$' ) } else { () } } @parts;
    my $any= $trans{srchany}?$trans{srchany}.'=':'';

    my $q=$query;
    foreach my $key (keys %trans) {
        my $f=$trans{$key};
        if( $f ) {
            $q=~s/\[$key\]/$f/g;
        } else {
            $q=~s/\[$key\]=/$any/g;
        }
    }
    $q=~s/\[\w+\]=/$any/g; # remove remaining fields (not found in field list)
    return $q;
}

=head2 ImportBreedingAuth

ImportBreedingAuth($marcrecords,$overwrite_auth,$filename,$encoding,$z3950random,$batch_type);

    ImportBreedingAuth imports MARC records in the reservoir (import_records table).
    ImportBreedingAuth is based on the ImportBreeding subroutine.

=cut

sub ImportBreedingAuth {
    my ($marcrecords,$overwrite_auth,$filename,$encoding,$z3950random,$batch_type) = @_;
    my @marcarray = split /\x1D/, $marcrecords;

    my $dbh = C4::Context->dbh;

    my $batch_id = GetZ3950BatchId($filename);
    my $searchbreeding = $dbh->prepare("select import_record_id from import_auths where control_number=? and authorized_heading=?");

    my $marcflavour = C4::Context->preference('marcflavour');
    my $marc_type = $marcflavour eq 'UNIMARC' ? 'UNIMARCAUTH' : $marcflavour;

    # fields used for import results
    my $imported=0;
    my $alreadyindb = 0;
    my $alreadyinfarm = 0;
    my $notmarcrecord = 0;
    my $breedingid;
    for (my $i=0;$i<=$#marcarray;$i++) {
        my ($marcrecord, $charset_result, $charset_errors);
        ($marcrecord, $charset_result, $charset_errors) =
            MarcToUTF8Record($marcarray[$i]."\x1D", $marc_type, $encoding);

        # Normalize the record so it doesn't have separated diacritics
        SetUTF8Flag($marcrecord);

        if (scalar($marcrecord->fields()) == 0) {
            $notmarcrecord++;
        } else {
            my $heading;
            $heading = C4::AuthoritiesMarc::GetAuthorizedHeading({ record => $marcrecord });

            my $heading_authtype_code;
            $heading_authtype_code = GuessAuthTypeCode($marcrecord);

            my $controlnumber;
            $controlnumber = $marcrecord->field('001')->data;

            #Check if the authority record already exists in the database...
            my ($duplicateauthid,$duplicateauthvalue);
            if ($marcrecord && $heading_authtype_code) {
                ($duplicateauthid,$duplicateauthvalue) = FindDuplicateAuthority( $marcrecord, $heading_authtype_code);
            }

            if ($duplicateauthid && $overwrite_auth ne 2) {
                #If the authority record exists and $overwrite_auth doesn't equal 2, then mark it as already in the DB
                $alreadyindb++;
            } else {
                if ($controlnumber && $heading) {
                    $searchbreeding->execute($controlnumber,$heading);
                    ($breedingid) = $searchbreeding->fetchrow;
                }
                if ($breedingid && $overwrite_auth eq '0') {
                    $alreadyinfarm++;
                } else {
                    if ($breedingid && $overwrite_auth eq '1') {
                        ModAuthorityInBatch($breedingid, $marcrecord);
                    } else {
                        my $import_id = AddAuthToBatch($batch_id, $imported, $marcrecord, $encoding, $z3950random);
                        $breedingid = $import_id;
                    }
                    $imported++;
                }
            }
        }
    }
    return ($notmarcrecord,$alreadyindb,$alreadyinfarm,$imported,$breedingid);
}

=head2 Z3950SearchAuth

Z3950SearchAuth($pars, $template);

Parameters for Z3950 search are all passed via the $pars hash. It may contain nameany, namepersonal, namecorp, namemeetingcon,
title, uniform title, subject, subjectsubdiv, srchany.
Also it should contain an arrayref id that points to a list of IDs of the z3950 targets to be queried (see z3950servers table).
This code is used in cataloging/z3950_auth_search.
The second parameter $template is a Template object. The routine uses this parameter to store the found values into the template.

=cut

sub Z3950SearchAuth {
    my ($pars, $template)= @_;

    my $dbh   = C4::Context->dbh;
    my @id= @{$pars->{id}};
    my $random= $pars->{random};
    my $page= $pars->{page};

    my $nameany= $pars->{nameany};
    my $authorany= $pars->{authorany};
    my $authorpersonal= $pars->{authorpersonal};
    my $authorcorp= $pars->{authorcorp};
    my $authormeetingcon= $pars->{authormeetingcon};
    my $title= $pars->{title};
    my $uniformtitle= $pars->{uniformtitle};
    my $subject= $pars->{subject};
    my $subjectsubdiv= $pars->{subjectsubdiv};
    my $srchany= $pars->{srchany};

    my $show_next       = 0;
    my $total_pages     = 0;
    my $attr = '';
    my $host;
    my $server;
    my $database;
    my $port;
    my $marcdata;
    my @encoding;
    my @results;
    my $count;
    my $record;
    my @serverhost;
    my @servername;
    my @breeding_loop = ();

    my @oConnection;
    my @oResult;
    my @errconn;
    my $s = 0;
    my $query;
    my $nterms=0;

    my $marcflavour = C4::Context->preference('marcflavour');
    my $marc_type = $marcflavour eq 'UNIMARC' ? 'UNIMARCAUTH' : $marcflavour;

    if ($nameany) {
        $query .= " \@attr 1=1002 \"$nameany\" "; #Any name (this includes personal, corporate, meeting/conference authors, and author names in subject headings)
        #This attribute is supported by both the Library of Congress and Libraries Australia 08/05/2013
        $nterms++;
    }

    if ($authorany) {
        $query .= " \@attr 1=1003 \"$authorany\" "; #Author-name (this includes personal, corporate, meeting/conference authors, but not author names in subject headings)
        #This attribute is not supported by the Library of Congress, but is supported by Libraries Australia 08/05/2013
        $nterms++;
    }

    if ($authorcorp) {
        $query .= " \@attr 1=2 \"$authorcorp\" "; #1005 is another valid corporate author attribute...
        $nterms++;
    }

    if ($authorpersonal) {
        $query .= " \@attr 1=1 \"$authorpersonal\" "; #1004 is another valid personal name attribute...
        $nterms++;
    }

    if ($authormeetingcon) {
        $query .= " \@attr 1=3 \"$authormeetingcon\" "; #1006 is another valid meeting/conference name attribute...
        $nterms++;
    }

    if ($subject) {
        $query .= " \@attr 1=21 \"$subject\" ";
        $nterms++;
    }

    if ($subjectsubdiv) {
        $query .= " \@attr 1=47 \"$subjectsubdiv\" ";
        $nterms++;
    }

    if ($title) {
        $query .= " \@attr 1=4 \"$title\" "; #This is a regular title search. 1=6 will give just uniform titles
        $nterms++;
    }

     if ($uniformtitle) {
        $query .= " \@attr 1=6 \"$uniformtitle\" "; #This is the uniform title search
        $nterms++;
    }

    if($srchany) {
        $query .= " \@attr 1=1016 \"$srchany\" ";
        $nterms++;
    }

    for my $i (1..$nterms-1) {
        $query = "\@and " . $query;
    }

    foreach my $servid (@id) {
        my $sth = $dbh->prepare("select * from z3950servers where id=?");
        $sth->execute($servid);
        while ( $server = $sth->fetchrow_hashref ) {
            my $option1      = new ZOOM::Options();
            $option1->option( 'async' => 1 );
            $option1->option( 'elementSetName', 'F' );
            $option1->option( 'databaseName',   $server->{db} );
            $option1->option( 'user', $server->{userid} ) if $server->{userid};
            $option1->option( 'password', $server->{password} ) if $server->{password};
            $option1->option( 'preferredRecordSyntax', $server->{syntax} );
            $option1->option( 'timeout', $server->{timeout} ) if $server->{timeout};
            $oConnection[$s] = create ZOOM::Connection($option1);
            $oConnection[$s]->connect( $server->{host}, $server->{port} );
            $serverhost[$s] = $server->{host};
            $servername[$s] = $server->{name};
            $encoding[$s]   = ($server->{encoding}?$server->{encoding}:"iso-5426");
            $s++;
        }    ## while fetch
    }    # foreach
    my $nremaining  = $s;

    for ( my $z = 0 ; $z < $s ; $z++ ) {
        $oResult[$z] = $oConnection[$z]->search_pqf($query);
    }

    while ( $nremaining-- ) {
        my $k;
        my $event;
        while ( ( $k = ZOOM::event( \@oConnection ) ) != 0 ) {
            $event = $oConnection[ $k - 1 ]->last_event();
            last if $event == ZOOM::Event::ZEND;
        }

        if ( $k != 0 ) {
            $k--;
            my ($error, $errmsg, $addinfo, $diagset)= $oConnection[$k]->error_x();
            if ($error) {
                if ($error =~ m/^(10000|10007)$/ ) {
                    push(@errconn, {'server' => $serverhost[$k]});
                }
            }
            else {
                my $numresults = $oResult[$k]->size();
                my $i;
                my $result = '';
                if ( $numresults > 0  and $numresults >= (($page-1)*20)) {
                    $show_next = 1 if $numresults >= ($page*20);
                    $total_pages = int($numresults/20)+1 if $total_pages < ($numresults/20);
                    for ($i = ($page-1)*20; $i < (($numresults < ($page*20)) ? $numresults : ($page*20)); $i++) {
                        my $rec = $oResult[$k]->record($i);
                        if ($rec) {
                            my $marcrecord;
                            my $marcdata;
                            $marcdata   = $rec->raw();

                            my ($charset_result, $charset_errors);
                            ($marcrecord, $charset_result, $charset_errors)= MarcToUTF8Record($marcdata, $marc_type, $encoding[$k]);

                            my $heading;
                            my $heading_authtype_code;
                            $heading_authtype_code = GuessAuthTypeCode($marcrecord);
                            $heading = C4::AuthoritiesMarc::GetAuthorizedHeading({ record => $marcrecord });

                            my ($notmarcrecord, $alreadyindb, $alreadyinfarm, $imported, $breedingid)= ImportBreedingAuth( $marcdata, 2, $serverhost[$k], $encoding[$k], $random, 'z3950' );
                            my %row_data;
                            $row_data{server}       = $servername[$k];
                            $row_data{breedingid}   = $breedingid;
                            $row_data{heading}      = $heading;
                            $row_data{heading_code}      = $heading_authtype_code;
                            push( @breeding_loop, \%row_data );
                        }
                        else {
                            push(@breeding_loop,{'server'=>$servername[$k],'title'=>join(': ',$oConnection[$k]->error_x()),'breedingid'=>-1});
                        }
                    }
                }    #if $numresults
            }
        }    # if $k !=0

        $template->param(
            numberpending => $nremaining,
            current_page => $page,
            total_pages => $total_pages,
            show_nextbutton => $show_next?1:0,
            show_prevbutton => $page!=1,
        );
    } # while nremaining

    #close result sets and connections
    foreach(0..$s-1) {
        $oResult[$_]->destroy();
        $oConnection[$_]->destroy();
    }

    my @servers = ();
    foreach my $id (@id) {
        push @servers, {id => $id};
    }
    $template->param(
        breeding_loop => \@breeding_loop,
        servers => \@servers,
        errconn       => \@errconn
    );
}

1;
__END__

