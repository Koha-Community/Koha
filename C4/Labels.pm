package C4::Labels;

BEGIN {
    use version; our $VERSION = qv('3.08.01.002');

    use C4::Labels::Batch 1.000000;
    use C4::Labels::Label 1.000000;
    use C4::Labels::Layout 1.000000;
    use C4::Labels::Profile 1.000000;
    use C4::Labels::Template 1.000000;
}

1;
