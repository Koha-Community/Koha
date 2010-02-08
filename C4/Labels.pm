package C4::Labels;

BEGIN {
    use version; our $VERSION = qv('1.0.0_1');

    use C4::Labels::Batch 1.000000;
    use C4::Labels::Label 1.000000;
    use C4::Labels::Layout 1.000000;
    use C4::Labels::Profile 1.000000;
    use C4::Labels::Template 1.000000;
}

1;
