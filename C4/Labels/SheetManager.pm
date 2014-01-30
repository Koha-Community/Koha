package C4::Labels::SheetManager;
# Copyright 2015 KohaSuomi
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use Modern::Perl;

use DateTime;
use DateTime::Format::HTTP;
use DateTime::Format::RFC3339;

use C4::Labels::Sheet;
use C4::Context;

use Koha::Exception::DB;
use Koha::Exception::UnknownObject;


sub getSheet {
    my ($sheetId, $version) = @_;
    return _instantiateSheet( getSheetFromDB($sheetId, undef, $version) );
}

=head getSheetByName

    my $sheet = C4::Labels::SheetManager::getSheetByName($name, $version);

Fetches the newest sheet with the given name, or a specific version.
Keep in mind that the sheet name can change and might not always be
the most accurate representation of the sheet.
@PARAM1 String MANDATORY, the sheet name.
@PARAM2 Double OPTIONAL, the version number, eg. 0.9
@RETURNS C4::Labels::Sheet
=cut

sub getSheetByName {
    my ($name, $version) = @_;
    return _instantiateSheet( getSheetFromDB(undef, $name, $version) );
}

sub _instantiateSheet {
    my ($sheetRow) = @_;
    return undef unless $sheetRow;
    my $sheetHash = JSON::XS->new()->decode($sheetRow->{sheet});
    my $sheet = C4::Labels::Sheet->new($sheetHash);
    return $sheet;
}

=head listSheetVersions

@RETURNS ARRAYRef of HASHRefs, All the metadata from label_sheets except the big sheet-object.

=cut

sub listSheetVersions {
    my $dbh = C4::Context->dbh();
    my $sth = $dbh->prepare("SELECT id, name, version, author, timestamp FROM label_sheets ORDER BY id ASC, version DESC");
    eval {
        $sth->execute();
    };
    if ($@ || $sth->err) {
        my @cal = caller(0);
        Koha::Exception::DB->throw(error => $cal[3].'():>'.($@ || $sth->errstr));
    }
    return $sth->fetchall_arrayref({});
}

sub swaggerizeSheetVersion {
    my ($sv) = @_;

    unless (ref($sv) eq 'HASH') {
        my @cc = caller(1);
        Koha::Exception::BadParameter->throw(error => "Subroutine ".$cc[3]." tries to swaggerizeSheetVersion($sv) a non-HASH value?");
    }

    $sv->{id}      += 0   if $sv->{id};
    $sv->{version} += 0.0 if $sv->{id};
    $sv->{author}  += 0   if $sv->{author};

    if ($sv->{timestamp}) {
        my $dt = DateTime::Format::MySQL->parse_datetime( $sv->{timestamp} );
        $dt->set_time_zone( C4::Context->tz() );
        $sv->{timestamp}  = DateTime::Format::RFC3339->new()->format_datetime($dt);
    }
    return $sv;
}

=head getSheetsFromDB

@RETURNS ARRAYRef of HASHRefs

=cut

sub getSheetsFromDB {
    my $dbh = C4::Context->dbh();
    my $sth = $dbh->prepare("SELECT * FROM label_sheets lsa WHERE version = (SELECT MAX(version) as version FROM label_sheets lsd WHERE lsa.id = lsd.id);");
    eval {
        $sth->execute();
    };
    if ($@ || $sth->err) {
        my @cal = caller(0);
        Koha::Exception::DB->throw(error => $cal[3].'():>'.($@ || $sth->errstr));
    }
    return $sth->fetchall_arrayref({});
}

=head getSheetFromDB

@RETURNS HASHRef

=cut

sub getSheetFromDB {
    my ($id, $name, $version) = @_;
    my $dbh = C4::Context->dbh();

    my @params;
    my $sql = "SELECT * FROM label_sheets lsa WHERE ";

    if ($id) {
        $sql .= (scalar(@params)) ? " AND id = ? " : " id = ? ";
        push(@params, $id);
    }
    if ($name) {
        $sql .= (scalar(@params)) ? " AND name = ? " : " name = ? ";
        push(@params, $name);
    }
    #If $version is given, look with it, else find the biggest version and use that.
    if ($version) {
        $sql .= (scalar(@params)) ? " AND version = CAST(? as DECIMAL(2,1)) " : " version = CAST(? as DECIMAL(2,1)) ";
        push(@params, $version+0); #cast to double
    }
    else {
        $sql .= (scalar(@params)) ? " AND version = " : " version = ";
        $sql .= "(SELECT MAX(version) as version FROM label_sheets lsd WHERE lsa.id = lsd.id)";
    }

    my $sth = $dbh->prepare($sql);
    eval {
        $sth->execute( @params );
    };
    if ($@ || $sth->err) {
        my @cal = caller(0);
        Koha::Exception::DB->throw(error => $cal[3].'():>'.($@ || $sth->errstr));
    }
    return $sth->fetchrow_hashref();
}
sub putNewSheetToDB {
    my ($sheet) = @_;

    my $id = selectMaxIdFromDB()+1;
    $id = $sheet->getId() if $sheet->getId() > $id;
    $sheet->setId($id);
    $sheet = _putToDB($sheet);

    return $sheet;
}
sub putNewVersionToDB {
    my ($sheet) = @_;

    if (idInUseInDB($sheet->getId())) {
        $sheet = _putToDB($sheet);
    }
    else {
        my @cal = caller(0);
        Koha::Exception::UnknownObject->throw(error => $cal[3].'():>'."Cannot store a new version, because the initial sheet has not been saved. Use the subroutine putNewSheetToDB() or the REST endpoint POST /labels/sheets");
    }
    return $sheet;
}
sub deleteSheet {
    my ($id, $version) = @_;
    my $dbh = C4::Context->dbh();

    unless (my $oldSheet = getSheetFromDB($id, undef, $version)) {
        my @cal = caller(0);
        Koha::Exception::UnknownObject->throw(error => $cal[3].'():>'."Sheet not found");
    }
    my @params = ($id);
    my $sql = "DELETE FROM label_sheets WHERE id = ?";
    if ($version) {
        $sql .= " AND version = CAST(? as DECIMAL(2,1)) ";
        push @params, $version;
    }
    my $sth = $dbh->prepare($sql);
    eval {
        $sth->execute( @params );
    };
    if ($@ || $sth->err) {
        my @cal = caller(0);
        Koha::Exception::DB->throw(error => $cal[3].'():>'.($@ || $sth->errstr));
    }
    return 1;
}
sub _putToDB {
    my ($sheet) = @_;
    $sheet->setTimestamp(DateTime->now(time_zone => C4::Context->tz()));

    my $dbh = C4::Context->dbh();
    my $sth = $dbh->prepare("INSERT INTO label_sheets VALUES (?,?,?,?,?,?)");
    eval {
        $sth->execute( $sheet->getId(), $sheet->getName(), $sheet->getAuthor()->{borrowernumber},
                       $sheet->getVersion(), $sheet->getTimestamp()->iso8601(), $sheet->toJSON() );
    };
    if ($@ || $sth->err) {
        my @cal = caller(0);
        Koha::Exception::DB->throw(error => $cal[3].'():>'.($@ || $sth->errstr));
    }
    return $sheet;
}
sub selectMaxIdFromDB {
    my $dbh = C4::Context->dbh();
    my $sth = $dbh->prepare("SELECT max(id) as id FROM label_sheets");
    eval {
        $sth->execute( );
    };
    if ($@ || $sth->err) {
        my @cal = caller(0);
        Koha::Exception::DB->throw(error => $cal[3].'():>'.($@ || $sth->errstr));
    }
    my $rv = $sth->fetchrow_hashref();
    return (ref $rv eq 'HASH' && $rv->{id}) ? $rv->{id} : 0;
}
sub idInUseInDB {
    my ($id) = @_;
    my $dbh = C4::Context->dbh();
    my $sth = $dbh->prepare("SELECT id FROM label_sheets WHERE id = ?");
    eval {
        $sth->execute( $id );
    };
    if ($@ || $sth->err) {
        my @cal = caller(0);
        Koha::Exception::DB->throw(error => $cal[3].'():>'.($@ || $sth->errstr));
    }
    my $rv = $sth->fetchrow_hashref();
    return (ref $rv eq 'HASH') ? $rv->{id} : undef;
}


return 1;
