use Modern::Perl;

return {
    bug_number  => "33260",
    description => "Add the notice used to convert a notice to a print notice",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

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

        say $out "Added the notice 'CONVERTED_TO_PRINT'";
    },
};
