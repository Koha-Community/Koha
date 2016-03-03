package C4::Patroncards;

BEGIN {
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
    use C4::Patroncards::Batch;
    use C4::Patroncards::Layout;
    use C4::Patroncards::Lib;
    use C4::Patroncards::Patroncard;
    use C4::Patroncards::Profile;
    use C4::Patroncards::Template;
}

1;
