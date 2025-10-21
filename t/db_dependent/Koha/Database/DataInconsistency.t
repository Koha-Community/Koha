use Modern::Perl;

use Test::NoWarnings;
use Test::More tests => 7;
use Test::Warn;

use Koha::Items;
use Koha::Database::DataInconsistency;

use t::lib::TestBuilder;
use t::lib::Mocks;

my $builder = t::lib::TestBuilder->new;

my $schema = Koha::Database->new()->schema();

subtest 'invalid_item_library' => sub {

    plan tests => 4;

    $schema->storage->txn_begin();

    my $biblio_ok = $builder->build_sample_biblio;
    my $item_ok   = $builder->build_sample_item( { biblionumber => $biblio_ok->biblionumber } );
    my $biblio_ko = $builder->build_sample_biblio;
    my $item_ko   = $builder->build_sample_item( { biblionumber => $biblio_ko->biblionumber } );

    my $items = Koha::Items->search( { biblionumber => [ $biblio_ok->biblionumber, $biblio_ko->biblionumber ] } );

    subtest 'ok' => sub {
        plan tests => 1;

        my @errors = Koha::Database::DataInconsistency->invalid_item_library($items);
        is_deeply( \@errors, [] );

    };
    subtest 'no homebranch, no holdingbranch' => sub {
        plan tests => 1;
        $item_ko->set( { homebranch => undef, holdingbranch => undef } )->store;

        my @errors = Koha::Database::DataInconsistency->invalid_item_library($items);
        is_deeply(
            \@errors,
            [ sprintf "Item with itemnumber=%s does not have home and holding library defined", $item_ko->itemnumber ]
        );
    };

    subtest 'no homebranch' => sub {
        plan tests => 1;
        $item_ko->set( { homebranch => undef, holdingbranch => $item_ok->holdingbranch } )->store;

        my @errors = Koha::Database::DataInconsistency->invalid_item_library($items);
        is_deeply(
            \@errors,
            [ sprintf "Item with itemnumber=%s does not have a home library defined", $item_ko->itemnumber ]
        );
    };

    subtest 'no holdingbranch' => sub {
        plan tests => 1;
        $item_ko->set( { homebranch => $item_ok->homebranch, holdingbranch => undef } )->store;

        my @errors = Koha::Database::DataInconsistency->invalid_item_library($items);
        is_deeply(
            \@errors,
            [ sprintf "Item with itemnumber=%s does not have a holding library defined", $item_ko->itemnumber ]
        );
    };

    $schema->storage->txn_rollback();
};

subtest 'no_item_type' => sub {

    plan tests => 2;

    $schema->storage->txn_begin();

    my $biblio_ok = $builder->build_sample_biblio;
    my $item_ok   = $builder->build_sample_item( { biblionumber => $biblio_ok->biblionumber } );
    my $biblio_ko = $builder->build_sample_biblio;
    my $item_ko   = $builder->build_sample_item( { biblionumber => $biblio_ko->biblionumber } );

    my $biblios = Koha::Biblios->search( { biblionumber => [ $biblio_ok->biblionumber, $biblio_ko->biblionumber ] } );

    subtest 'item-level_itypes = 1' => sub {
        plan tests => 3;
        t::lib::Mocks::mock_preference( 'item-level_itypes', 1 );
        subtest 'ok' => sub {
            plan tests => 1;
            my @errors = Koha::Database::DataInconsistency->no_item_type($biblios);
            is_deeply( \@errors, [] );
        };
        subtest 'itype => undef' => sub {
            plan tests => 2;
            $item_ko->set( { itype => undef } );
            Koha::Object::store($item_ko);    # Do not call Koha::Item->store, it will set itype
            $biblio_ko->biblioitem->set( { itemtype => $item_ok->itype } )->store;

            my @errors = Koha::Database::DataInconsistency->no_item_type($biblios);
            is_deeply(
                \@errors,
                [
                    sprintf
                        "Item with itemnumber=%s does not have an itype value, biblio's item type will be used (%s)",
                    $item_ko->itemnumber, $biblio_ko->itemtype
                ]
            );

            $biblio_ko->biblioitem->set( { itemtype => undef } )->store;
            @errors = Koha::Database::DataInconsistency->no_item_type($biblios);
            is_deeply(
                \@errors,
                [
                    sprintf
                        "Item with itemnumber=%s does not have an itype value, additionally no item type defined for biblionumber=%s",
                    $item_ko->itemnumber, $biblio_ko->biblionumber
                ]
            );
        };
        subtest 'itype => ""' => sub {
            plan tests => 2;
            $item_ko->set( { itype => "" } );
            Koha::Object::store($item_ko);    # Do not call Koha::Item->store, it will set itype
            $biblio_ko->biblioitem->set( { itemtype => $item_ok->itype } )->store;

            my @errors = Koha::Database::DataInconsistency->no_item_type($biblios);
            is_deeply(
                \@errors,
                [
                    sprintf
                        "Item with itemnumber=%s does not have an itype value, biblio's item type will be used (%s)",
                    $item_ko->itemnumber, $biblio_ko->itemtype
                ]
            );

            $biblio_ko->biblioitem->set( { itemtype => undef } )->store;
            @errors = Koha::Database::DataInconsistency->no_item_type($biblios);
            is_deeply(
                \@errors,
                [
                    sprintf
                        "Item with itemnumber=%s does not have an itype value, additionally no item type defined for biblionumber=%s",
                    $item_ko->itemnumber, $biblio_ko->biblionumber
                ]
            );
        };
    };

    subtest 'item-level_itypes = 0' => sub {
        plan tests => 3;
        t::lib::Mocks::mock_preference( 'item-level_itypes', 0 );
        subtest 'ok' => sub {
            plan tests => 1;
            $biblio_ko->biblioitem->set( { itemtype => $item_ok->itype } )->store;
            my @errors = Koha::Database::DataInconsistency->no_item_type($biblios);
            is_deeply( \@errors, [] );
        };
        subtest 'itemtype => undef' => sub {
            plan tests => 1;
            $biblio_ko->biblioitem->set( { itemtype => undef } )->store;

            my @errors = Koha::Database::DataInconsistency->no_item_type($biblios);
            is_deeply(
                \@errors,
                [
                    sprintf "Biblioitem with biblioitemnumber=%s does not have an itemtype value",
                    $biblio_ko->biblioitem->biblioitemnumber
                ]
            );
        };
        subtest 'itemtype => ""' => sub {
            plan tests => 1;
            $biblio_ko->biblioitem->set( { itemtype => '' } )->store;

            my @errors = Koha::Database::DataInconsistency->no_item_type($biblios);
            is_deeply(
                \@errors,
                [
                    sprintf "Biblioitem with biblioitemnumber=%s does not have an itemtype value",
                    $biblio_ko->biblioitem->biblioitemnumber
                ]
            );
        };
    };
    $schema->storage->txn_rollback();
};

subtest 'invalid_item_type' => sub {

    plan tests => 2;

    $schema->storage->txn_begin();

    my $biblio_ok = $builder->build_sample_biblio;
    my $item_ok   = $builder->build_sample_item( { biblionumber => $biblio_ok->biblionumber } );
    my $biblio_ko = $builder->build_sample_biblio;
    my $item_ko   = $builder->build_sample_item( { biblionumber => $biblio_ko->biblionumber } );

    my $biblios = Koha::Biblios->search( { biblionumber => [ $biblio_ok->biblionumber, $biblio_ko->biblionumber ] } );

    my $itemtype         = $builder->build_object( { class => 'Koha::ItemTypes' } );
    my $deleted_itemtype = $itemtype->itemtype;
    $itemtype->delete;

    subtest 'item-level_itypes = 1' => sub {
        plan tests => 2;
        t::lib::Mocks::mock_preference( 'item-level_itypes', 1 );
        subtest 'ok' => sub {
            plan tests => 1;
            my @errors = Koha::Database::DataInconsistency->invalid_item_type($biblios);
            is_deeply( \@errors, [] );
        };
        subtest 'itype is invalid' => sub {
            plan tests => 2;
            $item_ko->set( { itype => $deleted_itemtype } );
            Koha::Object::store($item_ko);    # Do not call Koha::Item->store, it will set itype

            my @errors = Koha::Database::DataInconsistency->invalid_item_type($biblios);
            is_deeply(
                \@errors,
                [
                    sprintf "Item with itemnumber=%s, biblionumber=%s does not have a valid itype value (%s)",
                    $item_ko->itemnumber, $item_ko->biblionumber, $item_ko->itype
                ]
            );

            $item_ko->set( { itype => '' } );
            Koha::Object::store($item_ko);    # Do not call Koha::Item->store, it will set itype
            @errors = Koha::Database::DataInconsistency->invalid_item_type($biblios);

            # Does not alert here, it's caught already in no_item_type
            is_deeply( \@errors, [] );
        };
    };

    subtest 'item-level_itypes = 0' => sub {
        plan tests => 2;
        t::lib::Mocks::mock_preference( 'item-level_itypes', 0 );
        subtest 'ok' => sub {
            plan tests => 1;
            my @errors = Koha::Database::DataInconsistency->invalid_item_type($biblios);
            is_deeply( \@errors, [] );
        };
        subtest 'itemtype is invalid' => sub {
            plan tests => 2;
            $biblio_ko->biblioitem->set( { itemtype => $deleted_itemtype } )->store;

            my @errors = Koha::Database::DataInconsistency->invalid_item_type($biblios);
            is_deeply(
                \@errors,
                [
                    sprintf "Biblioitem with biblioitemnumber=%s does not have a valid itemtype value (%s)",
                    $biblio_ko->biblioitem->biblioitemnumber, $biblio_ko->biblioitem->itemtype
                ]
            );

            $biblio_ko->biblioitem->set( { itemtype => ' ' } )->store;
            @errors = Koha::Database::DataInconsistency->invalid_item_type($biblios);

            # Does not alert here, it's caught already in no_item_type
            is_deeply( \@errors, [] );
        };
    };

    $schema->storage->txn_rollback();
};

subtest 'errors_in_marc' => sub {

    plan tests => 4;

    $schema->storage->txn_begin();

    my $biblio_ok = $builder->build_sample_biblio;
    my $item_ok   = $builder->build_sample_item( { biblionumber => $biblio_ok->biblionumber } );
    my $biblio_ko = $builder->build_sample_biblio;
    my $item_ko   = $builder->build_sample_item( { biblionumber => $biblio_ko->biblionumber } );

    my $biblios = Koha::Biblios->search( { biblionumber => [ $biblio_ok->biblionumber, $biblio_ko->biblionumber ] } );

    my $itemtype         = $builder->build_object( { class => 'Koha::ItemTypes' } );
    my $deleted_itemtype = $itemtype->itemtype;
    $itemtype->delete;

    subtest 'ok' => sub {
        plan tests => 3;
        my $errors = Koha::Database::DataInconsistency->errors_in_marc($biblios);
        ok( !exists $errors->{decoding_errors} );
        ok( !exists $errors->{ids_not_in_marc} );
        ok( !exists $errors->{item_fields_in_marc} );
    };

    subtest 'ids_not_in_marc' => sub {
        plan tests => 2;
        $schema->storage->txn_begin();
        my ( $biblio_tag,     $biblio_subfield )     = C4::Biblio::GetMarcFromKohaField("biblio.biblionumber");
        my ( $biblioitem_tag, $biblioitem_subfield ) = C4::Biblio::GetMarcFromKohaField("biblioitems.biblioitemnumber");
        my $record = $biblio_ko->metadata->record;
        if ( my $field = $record->field($biblio_tag) ) {
            $field->update( $biblio_subfield => '-42' );
        }
        $biblio_ko->metadata->metadata( $record->as_xml )->store;

        my $errors = Koha::Database::DataInconsistency->errors_in_marc($biblios);
        is_deeply(
            $errors->{ids_not_in_marc},
            [
                sprintf q{Biblionumber %s has '%s' in %s$%s}, $biblio_ko->biblionumber, '-42', $biblio_tag,
                $biblio_subfield
            ]
        );

        $record = $biblio_ko->metadata->record;
        if ( my $field = $record->field($biblioitem_tag) ) {
            $field->update( $biblioitem_subfield => '-42' );
        }
        $biblio_ko->metadata->metadata( $record->as_xml )->store;

        $errors = Koha::Database::DataInconsistency->errors_in_marc($biblios);
        is_deeply(
            $errors->{ids_not_in_marc},
            [
                sprintf(
                    q{Biblionumber %s has '%s' in %s$%s}, $biblio_ko->biblionumber, '-42', $biblio_tag,
                    $biblio_subfield
                ),
                sprintf(
                    q{Biblionumber %s has biblioitemnumber '%s' but should be '%s' in %s$%s}, $biblio_ko->biblionumber,
                    '-42', $biblio_ko->biblioitem->biblioitemnumber, $biblioitem_tag, $biblioitem_subfield
                )
            ]
        );

        $schema->storage->txn_rollback();
    };

    subtest 'item_fields_in_marc' => sub {
        plan tests => 1;
        $schema->storage->txn_begin();
        my ( $item_tag, $item_subfield ) = C4::Biblio::GetMarcFromKohaField("items.itemnumber");
        my $record = $biblio_ko->metadata->record;
        $record->append_fields( MARC::Field->new( $item_tag, '', '', $item_subfield => 'booh' ) );
        $biblio_ko->metadata->metadata( $record->as_xml )->store;

        my $errors = Koha::Database::DataInconsistency->errors_in_marc($biblios);
        is_deeply(
            $errors->{item_fields_in_marc},
            [ sprintf q{Biblionumber %s has item fields (%s) in the marc record}, $biblio_ko->biblionumber, $item_tag ]
        );

        $schema->storage->txn_rollback();
    };

    subtest 'decoding_errors' => sub {
        plan tests => 2;
        $schema->storage->txn_begin();
        my $biblio_metadata = $biblio_ko->metadata;
        $biblio_metadata->metadata('oops');
        Koha::Object::store($biblio_metadata);
        my $errors;
        warning_like {
            $errors = Koha::Database::DataInconsistency->errors_in_marc($biblios);
        }
        qr{parser error};
        like( $errors->{decoding_errors}->[0], qr{Invalid data, cannot decode metadata object} );
        $schema->storage->txn_rollback();
    };

    $schema->storage->txn_rollback();
};

subtest 'nonexistent_AV' => sub {

    plan tests => 2;

    $schema->storage->txn_begin();

    my $biblio_ok = $builder->build_sample_biblio;
    my $item_ok   = $builder->build_sample_item( { biblionumber => $biblio_ok->biblionumber } );
    my $biblio_ko = $builder->build_sample_biblio;
    my $item_ko   = $builder->build_sample_item( { biblionumber => $biblio_ko->biblionumber } );

    my $biblios = Koha::Biblios->search( { biblionumber => [ $biblio_ok->biblionumber, $biblio_ko->biblionumber ] } );

    subtest 'ok' => sub {
        plan tests => 1;
        my @errors = Koha::Database::DataInconsistency->nonexistent_AV($biblios);
        is_deeply( \@errors, [] );
    };

    subtest 'ccode not an AV' => sub {
        plan tests => 1;
        $item_ko->set( { withdrawn => -1 } )->store;
        my @errors = Koha::Database::DataInconsistency->nonexistent_AV($biblios);
        is( scalar(@errors), 1 );
    };
};

subtest 'empty_title' => sub {

    plan tests => 3;

    $schema->storage->txn_begin();

    my $biblio_ok = $builder->build_sample_biblio;
    my $item_ok   = $builder->build_sample_item( { biblionumber => $biblio_ok->biblionumber } );
    my $biblio_ko = $builder->build_sample_biblio;
    my $item_ko   = $builder->build_sample_item( { biblionumber => $biblio_ko->biblionumber } );

    my $biblios = Koha::Biblios->search( { biblionumber => [ $biblio_ok->biblionumber, $biblio_ko->biblionumber ] } );

    subtest 'ok' => sub {
        plan tests => 1;
        my @errors = Koha::Database::DataInconsistency->empty_title($biblios);
        is_deeply( \@errors, [] );
    };

    subtest 'title => undef' => sub {
        plan tests => 1;
        $biblio_ko->set( { title => undef } )->store;
        my @errors = Koha::Database::DataInconsistency->empty_title($biblios);
        is_deeply(
            \@errors,
            [ sprintf 'Biblio with biblionumber=%s does not have title defined', $biblio_ko->biblionumber ]
        );
    };

    subtest 'title => ""' => sub {
        plan tests => 1;
        $biblio_ko->set( { title => q{} } )->store;
        my @errors = Koha::Database::DataInconsistency->empty_title($biblios);
        is_deeply(
            \@errors,
            [ sprintf 'Biblio with biblionumber=%s does not have title defined', $biblio_ko->biblionumber ]
        );
    };
};
