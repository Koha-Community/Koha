use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "30144",
    description => "Add servicing_instruction support for EDIFACT orders",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Add servicing_instruction column to aqorders table
        if ( !column_exists( 'aqorders', 'servicing_instruction' ) ) {
            $dbh->do(
                q{
                ALTER TABLE aqorders
                ADD COLUMN servicing_instruction TEXT DEFAULT NULL
                COMMENT 'Servicing instructions from vendor (EDIFACT LVT/LVC) stored as JSON array'
                AFTER suppliers_report
            }
            );
            say_success( $out, "Added column 'aqorders.servicing_instruction'" );
        }

        # Add EDIFACT_SI category for servicing instruction codes
        $dbh->do(
            q{
            INSERT IGNORE INTO authorised_value_categories (category_name, is_system)
            VALUES ('EDIFACT_SI', 0)
        }
        );
        say_success( $out, "Added authorized value category 'EDIFACT_SI'" );

        # Add EDItEUR List 3B servicing instruction codes
        $dbh->do(
            q{
            INSERT IGNORE INTO authorised_values (category, authorised_value, lib, lib_opac)
            VALUES
                ('EDIFACT_SI', 'BB', 'Barcode labelling', 'Barcode labelling'),
                ('EDIFACT_SI', 'BBN', 'Do not apply barcode labels', 'Do not apply barcode labels'),
                ('EDIFACT_SI', 'BC', 'Classification', 'Classification'),
                ('EDIFACT_SI', 'BCN', 'Do not classify', 'Do not classify'),
                ('EDIFACT_SI', 'BI', 'Binding: binding, reinforcing, laminating', 'Binding: binding, reinforcing, laminating'),
                ('EDIFACT_SI', 'BIN', 'Do not apply normal binding', 'Do not apply normal binding'),
                ('EDIFACT_SI', 'BJ', 'Sleeving: jackets, sleeves, wallets', 'Sleeving: jackets, sleeves, wallets'),
                ('EDIFACT_SI', 'BJN', 'Do not supply normal sleeving', 'Do not supply normal sleeving'),
                ('EDIFACT_SI', 'BP', 'Audio/CD-ROM packaging: special pouches', 'Audio/CD-ROM packaging: special pouches'),
                ('EDIFACT_SI', 'BPN', 'Do not supply normal audio/CD-ROM packaging', 'Do not supply normal audio/CD-ROM packaging'),
                ('EDIFACT_SI', 'BS', 'Security fitting: triggers, Knogo labels', 'Security fitting: triggers, Knogo labels'),
                ('EDIFACT_SI', 'BSN', 'Do not apply usual security fitting', 'Do not apply usual security fitting'),
                ('EDIFACT_SI', 'CA', 'Cataloguing: catalogue record supply', 'Cataloguing: catalogue record supply'),
                ('EDIFACT_SI', 'CAN', 'Do not supply catalogue record', 'Do not supply catalogue record'),
                ('EDIFACT_SI', 'JK', 'Plastic wallet on paperback', 'Plastic wallet on paperback'),
                ('EDIFACT_SI', 'JKN', 'Do not supply plastic wallet', 'Do not supply plastic wallet'),
                ('EDIFACT_SI', 'KA', 'Kapco: thick laminate film on paperback', 'Kapco: thick laminate film on paperback'),
                ('EDIFACT_SI', 'KAN', 'Do not apply Kapco', 'Do not apply Kapco'),
                ('EDIFACT_SI', 'LA', 'Thin laminate film on paperback', 'Thin laminate film on paperback'),
                ('EDIFACT_SI', 'LAN', 'Do not laminate', 'Do not laminate'),
                ('EDIFACT_SI', 'RE', 'Reinforcement of hardback', 'Reinforcement of hardback'),
                ('EDIFACT_SI', 'REN', 'Do not reinforce hardback', 'Do not reinforce hardback'),
                ('EDIFACT_SI', 'RP', 'Reinforcement of paperback', 'Reinforcement of paperback'),
                ('EDIFACT_SI', 'RPN', 'Do not reinforce paperback', 'Do not reinforce paperback'),
                ('EDIFACT_SI', 'SF', 'Sewn flexi', 'Sewn flexi'),
                ('EDIFACT_SI', 'SFN', 'Do not sew', 'Do not sew'),
                ('EDIFACT_SI', 'SL', 'Plastic sleeve on hardback', 'Plastic sleeve on hardback'),
                ('EDIFACT_SI', 'SLN', 'Do not sleeve plastic on hardback', 'Do not sleeve plastic on hardback'),
                ('EDIFACT_SI', 'TR', 'Traditional case binding of paperback', 'Traditional case binding of paperback'),
                ('EDIFACT_SI', 'TRN', 'Do not case bind paperback', 'Do not case bind paperback'),
                ('EDIFACT_SI', 'NF', 'Non-standard servicing: see free text', 'Non-standard servicing: see free text'),
                ('EDIFACT_SI', 'NS', 'No servicing', 'No servicing'),
                ('EDIFACT_SI', 'NX', 'Non-standard servicing: see instructions sent outside EDI', 'Non-standard servicing: see instructions sent outside EDI'),
                ('EDIFACT_SI', 'PF', 'Binding as supplied by publisher', 'Binding as supplied by publisher')
        }
        );
        say_success( $out, "Added EDItEUR List 3B servicing instruction codes to 'EDIFACT_SI' category" );
    },
};
