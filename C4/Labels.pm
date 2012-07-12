package C4::Labels;

BEGIN {
    use version; our $VERSION = qv('1.0.0_1');

    use C4::Labels::Batch;
    use C4::Labels::Label;
    use C4::Labels::Layout;
    use C4::Labels::Profile;
    use C4::Labels::Template;
}

1;
