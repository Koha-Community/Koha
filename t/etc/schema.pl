use Modern::Perl;

return {
    schema_class => 'Koha::Schema',

    #  This is the default option when nothing is defined
    #  connect_info => ['dbi:SQLite:dbname=:memory:','',''],
    connect_opts  => { name_sep => '.', quote_char => '`', sqlite_unicode => 1 },
    fixture_class => '::Populate',
};
