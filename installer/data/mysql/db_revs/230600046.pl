use Modern::Perl;

return {
    bug_number  => "33547",
    description => "Add a new notice template 'PRES_TRAIN_ITEM'",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        unless ( column_exists( 'preservation_processings', 'letter_code' ) ) {
            $dbh->do(
                q{
                ALTER TABLE preservation_processings
                ADD COLUMN `letter_code` varchar(20) DEFAULT NULL COMMENT 'Foreign key to the letters table' AFTER `name`
            }
            );
        }

        my $notice_template = q{[%~ USE AuthorisedValues ~%]
[%~ SET train = train_item.train ~%]
[%~ SET item = train_item.catalogue_item ~%]
Train name: [% train.name %]
Sent on: [% train.sent_on | $KohaDates %]

[% train.default_processing.name %]

Item number #[% train_item.user_train_item_id %]

[% FOREACH item_attribute IN train_item.attributes %]
    [%~ SET value = item_attribute.value ~%]
    [%~ IF item_attribute.processing_attribute.type == 'authorised_value' ~%]
        [%~ SET value = AuthorisedValues.GetByCode(item_attribute.processing_attribute.option_source, item_attribute.value) ~%]
    [%~ END ~%]
    [% item_attribute.processing_attribute.name %]: [% value %]
[% END %]};

        $dbh->do(
            q{
            INSERT IGNORE INTO letter
            (module,code,branchcode,name,is_html,title,content,message_transport_type,lang)
            VALUES
            ('preservation','PRES_TRAIN_ITEM','','Train item slip',0,'Train item slip',?, 'print','default')}, undef,
            $notice_template
        );
        say $out "Added new letter 'PRES_TRAIN_ITEM' (print)";
    },
};
