use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_failure say_success say_info);

return {
    bug_number  => "33260",
    description => "Show message queue on staff interface and make notices printable",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type) VALUES ('NoticesManagement', '0', NULL, 'Enable the interface to view and print generated notices', 'YesNo') }
        );

        say_success( $out, "Added system preference 'NoticesManagement'" );

        $dbh->do(
            q{ INSERT IGNORE INTO permissions (module_bit, code, description) VALUES (13, 'view_generated_notices', 'View and print generated notices') }
        );

        say_success( $out, "Added user permission view_generated_notices" );

        my ($column_type) = $dbh->selectrow_array(
            q{SELECT COLUMN_TYPE FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'message_queue' AND COLUMN_NAME = 'status'}
        );

        if ( $column_type =~ /'printed'/ ) {
            say_info( $out, "Status 'printed' already exists in message_queue.status, skipping" );
        } else {

            # Add it to the statuses there are, whichever other statuses have been added
            $column_type =~ s/\)$/,'printed')/;
            $dbh->do(qq{ALTER TABLE message_queue MODIFY COLUMN `status` $column_type NOT NULL DEFAULT 'pending'});

            say_success( $out, "Added status 'printed' to message_queue.status" );
        }

        ($column_type) = $dbh->selectrow_array(
            q{SELECT COLUMN_TYPE FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'message_queue' AND COLUMN_NAME = 'status'}
        );

        if ( $column_type =~ /'converted'/ ) {
            say_info( $out, "Status 'converted' already exists in message_queue.status, skipping" );
        } else {

            # Add it to the statuses there are, whichever other statuses have been added
            $column_type =~ s/\)$/,'converted')/;
            $dbh->do(qq{ALTER TABLE message_queue MODIFY COLUMN `status` $column_type NOT NULL DEFAULT 'pending'});

            say_success( $out, "Added status 'converted' to message_queue.status" );
        }

        $dbh->do(
            q{
            INSERT IGNORE INTO letter (module, code, branchcode, name, is_html, title, content, message_transport_type, lang)
            VALUES ('members', 'CONVERTED_TO_PRINT', '', 'Notice converted to print', 1, '[% original_message.subject %]', ?, 'print', 'default')
            },
            undef,
            q{[% USE Koha %]
[% USE KohaDates %]
<div class="container mt-5">
  <div class="row">
    <div class="col-6">
      <p>
        <strong>[% borrower.firstname %] [% borrower.surname %]</strong><br>
        [% borrower.address %]<br>
        [% borrower.city %] [% borrower.zipcode %]<br>
        [% borrower.country %]<br>
      </p>
    </div>
    <div class="col-6 text-end">
      <p>
        <strong>[% branch.branchname %]</strong><br>
        [% branch.branchaddress1 %]<br>
        [% branch.branchaddress2 %]<br>
      </p>
    </div>
  </div>
  <div class="row mb-4">
    <div class="col-12">
      <p><em>
        [% IF original_message.status == 'failed' %]This notice could not be sent by [% original_message.message_transport_type %] on [% original_message.time_queued | $KohaDates with_hours => 1 %], so it is sent to you by post.
        [% ELSE %]This notice was sent by [% original_message.message_transport_type %] on [% original_message.time_queued | $KohaDates with_hours => 1 %], and is sent to you by post as well.[% END %]
      </em></p>
      <hr>
    </div>
  </div>
  <div class="row">
    <div class="col-12">
      [% original_message.content_as_html %]
    </div>
  </div>
</div>}
        );

        say_success( $out, "Added the notice 'CONVERTED_TO_PRINT'" );
    },
};
