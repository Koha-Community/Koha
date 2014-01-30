package Koha::REST::V1::Labels::Sheets;

use Modern::Perl;
use Try::Tiny;
use Scalar::Util qw(blessed);

use Mojo::Base 'Mojolicious::Controller';

use C4::Labels::SheetManager;
use C4::Labels::Sheet;

use Koha::Exception::UnknownObject;

sub list {
    my $c = shift->openapi->valid_input or return;

    try {
        my $sheetRows = C4::Labels::SheetManager::getSheetsFromDB();

        if (@$sheetRows > 0) {
            my @sheets;
            foreach my $sheetRow (@$sheetRows) {
                push @sheets, $sheetRow->{sheet};
            }
            return $c->render(status => 200, openapi => \@sheets);
        }
        else {
            return $c->render( status  => 404,
                           openapi => { error => "Sheets not found" } );
        }
    } catch {
        Koha::Exceptions::rethrow_exception($_);
    };
}

sub create {
    my $c = shift->openapi->valid_input or return;

    try {
        my $s = $c->validation->param('sheet');
        my $sheetHash = JSON::XS->new()->decode($s);
        my $sheet = C4::Labels::Sheet->new($sheetHash);
        C4::Labels::SheetManager::putNewSheetToDB($sheet);
        return $c->render(status => 201, openapi => $sheet->toJSON());
    } catch {
        if (blessed($_) && $_->isa('Koha::Exception::BadParameter')) {
            return $c->render(status => 400, json => { error => $_->error });
        }
        if (blessed($_) && $_->isa('Koha::Exception::DB')) {
            return $c->render(status => 500, json => { error => $_->error });
        }
        Koha::Exceptions::rethrow_exception($_);

    };
}

sub update {
    my $c = shift->openapi->valid_input or return;

    try {
        my $s = $c->validation->param('sheet');
        my $sheetHash = JSON::XS->new()->decode($s);
        my $sheet = C4::Labels::Sheet->new($sheetHash);
        C4::Labels::SheetManager::putNewVersionToDB($sheet);
        return $c->render(status => 201, openapi => $sheet->toJSON());
    } catch {
        if (blessed($_) && $_->isa('Koha::Exception::BadParameter')) {
            return $c->render(status => 400, json => { error => $_->error });
        }
        if (blessed($_) && $_->isa('Koha::Exception::UnknownObject')) {
            return $c->render(status => 404, json => { error => $_->error });
        }
        if (blessed($_) && $_->isa('Koha::Exception::DB')) {
            return $c->render(status => 500, json => { error => $_->error });
        }
        Koha::Exceptions::rethrow_exception($_);
    };
}

sub delete {
    my $c = shift->openapi->valid_input or return;

    try {
        my $id = $c->validation->param('sheet_identifier');
        my $version = $c->validation->param('sheet_version');
        C4::Labels::SheetManager::deleteSheet($id, $version);
        return $c->render( status => 204, openapi => {});
    } catch {
        if (blessed($_) && $_->isa('Koha::Exception::UnknownObject')) {
            return $c->render(status => 404, json => { error => $_->error });
        }
        if (blessed($_) && $_->isa('Koha::Exception::DB')) {
            return $c->render(status => 500, json => { error => $_->error });
        }
        Koha::Exceptions::rethrow_exception($_);
    };
}

sub get {
    my $c = shift->openapi->valid_input or return;

    try {
        my $id = $c->validation->param('sheet_identifier');
        my $version = $c->validation->param('sheet_version');
        my $sheetRow = C4::Labels::SheetManager::getSheetFromDB( $id, $version );

        if ($sheetRow) {
            return $c->render( status => 200, openapi => $sheetRow->{sheet});
        }
        else {
            return $c->render( status  => 404,
                           openapi => { error => "Sheet not found" } );
        }
    } catch {
        if (blessed($_) && $_->isa('Koha::Exception::UnknownObject')) {
            return $c->render(status => 404, json => { error => $_->error });
        }
        if (blessed($_) && $_->isa('Koha::Exception::DB')) {
            return $c->render(status => 500, json => { error => $_->error });
        }
        Koha::Exceptions::rethrow_exception($_);
    };
}

sub list_sheet_versions {
    my $c = shift->openapi->valid_input or return;

    try {
        my $sheetMetaData = C4::Labels::SheetManager::listSheetVersions();
        my @sheetMetaData = map {C4::Labels::SheetManager::swaggerizeSheetVersion($_)} @$sheetMetaData if ($sheetMetaData && ref($sheetMetaData) eq 'ARRAY');

        if (scalar(@sheetMetaData)) {
            return $c->render(status => 200, openapi => \@sheetMetaData);
        }
        else {
            Koha::Exception::UnknownObject->throw(error => "No sheets found");
        }
    } catch {
        if (blessed($_) && $_->isa('Koha::Exception::UnknownObject')) {
            return $c->render(status => 404, json => { error => $_->error });
        }
        if (blessed($_) && $_->isa('Koha::Exception::DB')) {
            return $c->render(status => 500, json => { error => $_->error });
        }
        Koha::Exceptions::rethrow_exception($_);
    };
}

1;
