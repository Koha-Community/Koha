use Modern::Perl;

return {
    bug_number  => "10762",
    description => "Make it possible to adjust the barcode height and width on labels",
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

            say $out "Added column 'creator_layouts.scale_width'";
        }
        unless ( column_exists( 'creator_layouts', 'scale_height' ) ) {
            $dbh->do(
                q {
                ALTER TABLE creator_layouts
                    ADD COLUMN scale_height FLOAT default 0.01 NOT NULL AFTER scale_width
            }
            );

            say $out "Added column 'creator_layouts.scale_height'";
        }
    },
    }
