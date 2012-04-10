package C4::Patroncards;

BEGIN {
    use version; our $VERSION = qv('3.07.00.049');
    use vars qw(@EXPORT @ISA);
    @ISA = qw(Exporter);
    our @EXPORT = qw(unpack_UTF8
                     text_alignment
                     leading
                     box
                     get_borrower_attributes
                     put_image
                     get_image
                     rm_image
    );
    use C4::Patroncards::Batch 1.000000;
    use C4::Patroncards::Layout 1.000000;
    use C4::Patroncards::Lib 1.000000;
    use C4::Patroncards::Patroncard 1.000000;
    use C4::Patroncards::Profile 1.000000;
    use C4::Patroncards::Template 1.000000;
}

1;
