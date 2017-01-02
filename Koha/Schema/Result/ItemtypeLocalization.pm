package Koha::Schema::Result::ItemtypeLocalization;

use base 'DBIx::Class::Core';

use Modern::Perl;

__PACKAGE__->table_class('DBIx::Class::ResultSource::View');

__PACKAGE__->table('itemtype_localizations');
__PACKAGE__->result_source_instance->is_virtual(1);
__PACKAGE__->result_source_instance->view_definition(
    "SELECT localization_id, code, lang, translation FROM localization WHERE entity='itemtypes'"
);

__PACKAGE__->add_columns(
  "localization_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "code",
  { data_type => "varchar", is_nullable => 0, size => 64 },
  "lang",
  { data_type => "varchar", is_nullable => 0, size => 25 },
  "translation",
  { data_type => "text", is_nullable => 1 },
);

__PACKAGE__->belongs_to(
    "itemtype",
    "Koha::Schema::Result::Itemtype",
    { code => 'itemtype' }
);

1;
