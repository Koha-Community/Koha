use Modern::Perl;

return {
    bug_number  => "10762",
    description => "Add 2 columns in 'creator_layouts' which define the width and height of barcodes",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};
        unless ( column_exists( 'creator_layouts', 'scale_width' ) ) {
            $dbh->do(
                q {
                ALTER TABLE creator_layouts
                    ADD COLUMN scale_width FLOAT default 0.8 NOT NULL AFTER font_size
            }
            );
        }
        unless ( column_exists( 'creator_layouts', 'scale_height' ) ) {
            $dbh->do(
                q {
                ALTER TABLE creator_layouts
                    ADD COLUMN scale_height FLOAT default 0.01 NOT NULL AFTER scale_width
            }
            );
        }
        say $out "Table creator_layouts updated with 2 new columns";
    },
    }
