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

use C4::Biblio qw(TransformMarcToKoha);
use C4::Koha qw( GetVariationsOfISBN );
use C4::Charset qw( MarcToUTF8Record SetUTF8Flag );
use MARC::File::USMARC;
use MARC::Field;
use C4::ImportBatch qw( GetZ3950BatchId AddBiblioToBatch AddAuthToBatch );
use C4::AuthoritiesMarc qw( GuessAuthTypeCode GetAuthorizedHeading );
use C4::Languages;
use Koha::Database;
use Koha::XSLT::Base;

our (@ISA, @EXPORT_OK);
BEGIN {
    require Exporter;
    @ISA       = qw(Exporter);
    @EXPORT_OK = qw(BreedingSearch ImportBreedingAuth Z3950Search Z3950SearchAuth);
}

=head1 NAME

C4::Breeding : module to add biblios to import_records via
               the breeding/reservoir API.

=head1 SYNOPSIS

    Z3950Search($pars, $template);
    ($count, @results) = &BreedingSearch($title,$isbn);

=head1 DESCRIPTION

This module contains routines related to Koha's Z39.50 search into
cataloguing reservoir features.

=head2 BreedingSearch

($count, @results) = &BreedingSearch($term);
C<$term> contains the term to search, it will be searched as title,author, or isbn

C<$count> is the number of items in C<@results>. C<@results> is an
array of references-to-hash; the keys are the items from the C<import_records> and
C<import_biblios> tables of the Koha database.

=cut

sub BreedingSearch {
    my ($term) = @_;
    my $dbh   = C4::Context->dbh;
    my $count = 0;
    my ($query,@bind);
    my $sth;
    my @results;

    my $authortitle = $term;
    $authortitle =~ s/(\s+)/\%/g; #Replace spaces with wildcard
    $authortitle = "%" . $authortitle . "%"; #Add wildcard to start and end of string
    # normalise ISBN like at import
    my @isbns = C4::Koha::GetVariationsOfISBN($term);

    $query = "SELECT import_biblios.import_record_id,
                import_batches.file_name,
                import_biblios.isbn,
                import_biblios.title,
                import_biblios.author,
                import_batches.upload_timestamp
              FROM  import_biblios
              JOIN import_records USING (import_record_id)
              JOIN import_batches USING (import_batch_id)
              WHERE title LIKE ? OR author LIKE ? OR isbn IN (" . join(',',('?') x @isbns) . ")";
    @bind=( $authortitle, $authortitle, @isbns );
    $sth = $dbh->prepare($query);
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

    my ( $zquery, $squery ) = _bib_build_query( $pars );

    my $schema = Koha::Database->new()->schema();
    my $rs = $schema->resultset('Z3950server')->search(
        { id => [ @id ] },
        { result_class => 'DBIx::Class::ResultClass::HashRefInflator' },
    );
    my @servers = $rs->all;
    foreach my $server ( @servers ) {
        my $server_zquery = $zquery;
        if(my $attributes = $server->{attributes}){
            $server_zquery = "$attributes $zquery";
        }
        $oConnection[$s] = _create_connection( $server );
        $oResult[$s] =
            $server->{servertype} eq 'zed'?
                $oConnection[$s]->search_pqf( $server_zquery ):
                $oConnection[$s]->search(ZOOM::Query::CQL->new(
                    _translate_query( $server, $squery )));
        $s++;
    }
    my $xslh = Koha::XSLT::Base->new;

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

sub _auth_build_query {
    my ( $pars ) = @_;

    my $qry_build = {
        nameany           => '@attr 1=1002 "#term" ',
        authorany         => '@attr 1=1003 "#term" ',
        authorcorp        => '@attr 1=2 "#term" ',
        authorpersonal    => '@attr 1=1 "#term" ',
        authormeetingcon  => '@attr 1=3 "#term" ',
        subject           => '@attr 1=21 "#term" ',
        subjectsubdiv     => '@attr 1=47 "#term" ',
        title             => '@attr 1=4 "#term" ',
        uniformtitle      => '@attr 1=6 "#term" ',
        srchany           => '@attr 1=1016 "#term" ',
        controlnumber     => '@attr 1=12 "#term" ',
    };

    return _build_query( $pars, $qry_build );
}

sub _bib_build_query {

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
        publicationyear => '@attr 1=31 "#term" '
    };

    return _build_query( $pars, $qry_build );
}

sub _build_query {

    my ( $pars, $qry_build ) = @_;

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
        $marcrecord->encoding('UTF-8');
    } else {
        ($marcrecord) = MarcToUTF8Record($raw, C4::Context->preference('marcflavour'), $servhref->{encoding} // "iso-5426" ); #ignores charset return values
    }
    SetUTF8Flag($marcrecord);
    my $error;
    ( $marcrecord, $error ) = _do_xslt_proc($marcrecord, $servhref, $xslh);

    my $batch_id = GetZ3950BatchId($servhref->{servername});
    my $breedingid = AddBiblioToBatch($batch_id, $seq, $marcrecord, 'UTF-8', 0);
        #Last zero indicates: no update for batch record counts

    my $row;
    if( $breedingid ){
        my @kohafields = ('biblio.title','biblio.author','biblioitems.isbn','biblioitems.lccn','biblioitems.editionstatement');
        my $date_label = C4::Context->preference('marcflavour') eq "MARC21" ? 'biblio.copyrightdate' : 'biblioitems.publicationyear';
        push @kohafields, $date_label;
        $row = C4::Biblio::TransformMarcToKoha({ record => $marcrecord, kohafields => \@kohafields, limit_table => 'no_items' });
        $row->{date} = $row->{ substr( $date_label, index( $date_label, '.' ) + 1 ) };
        $row->{biblionumber} = $bib;
        $row->{server}       = $servhref->{servername};
        $row->{breedingid}   = $breedingid;
        $row->{isbn}=_isbn_replace($row->{isbn});
        $row = _add_custom_field_rowdata($row, $marcrecord);
    }
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
        return ( $marc, $xslh->err ); #original record in case of errors
    }
}

sub _add_custom_field_rowdata
{
    my ( $row, $record ) = @_;
    my $pref_newtags = C4::Context->preference('AdditionalFieldsInZ3950ResultSearch');
    my $pref_flavour = C4::Context->preference('MarcFlavour');

    $pref_newtags =~ s/^\s+|\s+$//g;
    $pref_newtags =~ s/\h+/ /g;

    my @addnumberfields;

    foreach my $field (split /\,/, $pref_newtags) {
        $field =~ s/^\s+|\s+$//g ;  # trim whitespace
        my ($tag, $subtags) = split(/\$/, $field);

        if ( $record->field($tag) ) {
            my @content = ();

            for my $marcfield ($record->field($tag)) {
                if ( $subtags ) {
                    my $str = '';
                    for my $code (split //, $subtags) {
                        if ( $marcfield->subfield($code) ) {
                            $str .= $marcfield->subfield($code) . ' ';
                        }
                    }
                    if ( not $str eq '') {
                        push @content, $str;
                    }
                } elsif ( $tag == 10 ) {
                    push @content, ( $pref_flavour eq "MARC21" ? $marcfield->data : $marcfield->as_string );
                } elsif ( $tag < 10 ) {
                    push @content, $marcfield->data();
                } else {
                    push @content, $marcfield->as_string();
                }
            }

            if ( @content ) {
                $row->{$field} = \@content;
                push( @addnumberfields, $field );
            }
        }
    }

    $row->{'addnumberfields'} = \@addnumberfields;

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
    my $option1= ZOOM::Options->new();
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

ImportBreedingAuth( $marcrecord, $filename, $encoding, $heading );

    ImportBreedingAuth imports MARC records in the reservoir (import_records table) or returns their id if they already exist.

=cut

sub ImportBreedingAuth {
    my ( $marcrecord, $filename, $encoding, $heading ) = @_;
    my $dbh = C4::Context->dbh;

    my $batch_id = GetZ3950BatchId($filename);
    my $searchbreeding = $dbh->prepare("select import_record_id from import_auths where control_number=? and authorized_heading=?");

    my $controlnumber = $marcrecord->field('001')->data;

    # Normalize the record so it doesn't have separated diacritics
    SetUTF8Flag($marcrecord);

    $searchbreeding->execute($controlnumber,$heading);
    my ($breedingid) = $searchbreeding->fetchrow;

    return $breedingid if $breedingid;
    $breedingid = AddAuthToBatch($batch_id, 0, $marcrecord, $encoding);
    return $breedingid;
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
    my $page= $pars->{page};


    my $show_next       = 0;
    my $total_pages     = 0;
    my @encoding;
    my @results;
    my @serverhost;
    my @breeding_loop = ();
    my @oConnection;
    my @oResult;
    my @errconn;
    my @servers;
    my $s = 0;
    my $query;
    my $nterms=0;

    my $marcflavour = C4::Context->preference('marcflavour');
    my $marc_type = $marcflavour eq 'UNIMARC' ? 'UNIMARCAUTH' : $marcflavour;
    my $authid= $pars->{authid};
    my ( $zquery, $squery ) = _auth_build_query( $pars );
    foreach my $servid (@id) {
        my $sth = $dbh->prepare("select * from z3950servers where id=?");
        $sth->execute($servid);
        while ( my $server = $sth->fetchrow_hashref ) {
            $oConnection[$s] = _create_connection( $server );

            if ( $server->{servertype} eq 'zed' ) {
                my $server_zquery = $zquery;
                if ( my $attributes = $server->{attributes} ) {
                    $server_zquery = "$attributes $zquery";
                }
                $oResult[$s] = $oConnection[$s]->search_pqf( $server_zquery );
            }
            else {
                $oResult[$s] = $oConnection[$s]->search(
                    ZOOM::Query::CQL->new(_translate_query( $server, $squery ))
                );
            }
            $encoding[$s]   = ($server->{encoding}?$server->{encoding}:"iso-5426");
            $servers[$s] = $server;
            $s++;
        }   ## while fetch
    }    # foreach
    my $nremaining  = $s;

    while ( $nremaining-- ) {
        my $k;
        my $event;
        while ( ( $k = ZOOM::event( \@oConnection ) ) != 0 ) {
            $event = $oConnection[ $k - 1 ]->last_event();
            last if $event == ZOOM::Event::ZEND;
        }

        if ( $k != 0 ) {
            $k--;
            my ($error )= $oConnection[$k]->error_x(); #ignores errmsg, addinfo, diagset
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
                            if( $servers[$k]->{servertype} eq 'sru' ) {
                                $marcrecord = MARC::Record->new_from_xml( $marcdata, 'UTF-8', $servers[$k]->{syntax} );
                                $marcrecord->encoding('UTF-8');
                            } else {
                                ( $marcrecord, $charset_result, $charset_errors ) = MarcToUTF8Record( $marcdata, $marc_type, $encoding[$k] );
                            }
                            my $heading;
                            my $heading_authtype_code;
                            $heading_authtype_code = GuessAuthTypeCode($marcrecord);
                            next if ( not defined $heading_authtype_code ) ;

                            $heading = GetAuthorizedHeading({ record => $marcrecord });

                            my $breedingid = ImportBreedingAuth( $marcrecord, $serverhost[$k], $encoding[$k], $heading );
                            my %row_data;
                            $row_data{server}       = $servers[$k]->{'servername'};
                            $row_data{breedingid}   = $breedingid;
                            $row_data{heading}      = $heading;
                            $row_data{authid}       = $authid;
                            $row_data{heading_code}      = $heading_authtype_code;
                            push( @breeding_loop, \%row_data );
                        }
                        else {
                            push(@breeding_loop,{'server'=>$servers[$k]->{'servername'},'title'=>join(': ',$oConnection[$k]->error_x()),'breedingid'=>-1,'authid'=>-1});
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

    @servers = ();
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

