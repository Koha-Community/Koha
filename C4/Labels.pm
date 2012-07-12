package C4::Labels;

BEGIN {
    use version; our $VERSION = qv('3.08.01.002');

    use C4::Labels::Batch;
    use C4::Labels::Label;
    use C4::Labels::Layout;
    use C4::Labels::Profile;
    use C4::Labels::Template;
}

1;
