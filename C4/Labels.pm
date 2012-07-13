package C4::Labels;

BEGIN {
    use version; our $VERSION = qv('3.07.00.049');

    use C4::Labels::Batch;
    use C4::Labels::Label;
    use C4::Labels::Layout;
    use C4::Labels::Profile;
    use C4::Labels::Template;
}

1;
