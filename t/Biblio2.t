#!/usr/bin/perl

use Modern::Perl;
use Test::More;
use Test::MockModule;

use MARC::Record;

use C4::Biblio;

subtest "_koha_marc_update_bib_ids basic Field", \&_koha_marc_update_bib_ids_simple;
sub _koha_marc_update_bib_ids_simple {
    my $module = Test::MockModule->new('C4::Biblio');
    $module->mock('GetMarcFromKohaField', sub {
            my ($source) = @_;
            return ('999','c') if $source eq 'biblio.biblionumber';
            return ('999','d') if $source eq 'biblioitems.biblioitemnumber';
        }
    );

    my $r = MARC::Record->new();
    C4::Biblio::_koha_marc_update_bib_ids($r, undef, 10, 20);
    is($r->subfield('999', 'c'), 10, 'Biblionumber');
    is($r->subfield('999', 'd'), 20, 'Biblioitemnumber');

    C4::Biblio::_koha_marc_update_bib_ids($r, undef, 10, 20);
    my @f = $r->field('999');
    is(scalar(@f), 1, 'Field not duplicated');
    is($r->subfield('999', 'c'), 10, 'Biblionumber');
    is($r->subfield('999', 'd'), 20, 'Biblioitemnumber');
}

subtest "_koha_marc_update_bib_ids ControlField", \&_koha_marc_update_bib_ids_control;
sub _koha_marc_update_bib_ids_control {
    my $module = Test::MockModule->new('C4::Biblio');
    $module->mock('GetMarcFromKohaField', sub {
            my ($source) = @_;
            return ('001',undef) if $source eq 'biblio.biblionumber';
            return ('004',undef) if $source eq 'biblioitems.biblioitemnumber';
        }
    );

    my $r = MARC::Record->new();
    C4::Biblio::_koha_marc_update_bib_ids($r, undef, 10, 20);
    is($r->field('001')->data(), 10, 'Biblionumber to control field');
    is($r->field('004')->data(), 20, 'Biblioitemnumber to control field');

    C4::Biblio::_koha_marc_update_bib_ids($r, undef, 10, 20);
    my @f = $r->field('001');
    is(scalar(@f), 1, 'Control field not duplicated');
    is($r->field('001')->data(), 10, 'Biblionumber to control field');
    is($r->field('004')->data(), 20, 'Biblioitemnumber to control field');
}

done_testing();
