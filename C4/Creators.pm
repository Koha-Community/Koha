package C4::Creators;

BEGIN {
    use version; our $VERSION = qv('1.0.0_1');
    use vars qw(@EXPORT, @ISA);
    @ISA = qw(Exporter);
    our @EXPORT = qw(get_all_templates
                     get_all_layouts
                     get_all_profiles
                     get_all_image_names
                     get_batch_summary
                     get_label_summary
                     get_card_summary
                     get_barcode_types
                     get_label_types
                     get_font_types
                     get_text_justification_types
                     get_output_formats
                     get_column_names
                     get_table_names
                     get_unit_values
                     html_table
    );
    use C4::Creators::Lib 1.000000;
    use C4::Creators::PDF 1.000000;
}

1;
