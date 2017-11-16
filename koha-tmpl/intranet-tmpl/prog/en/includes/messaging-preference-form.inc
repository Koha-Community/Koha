[% USE Koha %]
<!-- snippet for form to set borrower and patron category messaging preferences -->

<input type="hidden" name="modify" value="yes" />
<input type="hidden" name="borrowernumber" value="[% borrowernumber %]" />
  <table>
    <tr><th></th>
        <th>Days in advance</th>
        [% IF Koha.Preference('SMSSendDriver') %]<th>SMS</th>[% END %]
        [% IF Koha.Preference('TalkingTechItivaPhoneNotification') %]<th>Phone</th>[% END %]
        <th>Email</th>
        <th>Digests only <i id="info_digests" data-toggle="tooltip" title="You can ask for a digest to reduce the number of messages. Messages will be saved and sent as a single message." data-placement="right" class="fa fa-info-circle"></i></th>
        <!-- <th>RSS</th> -->
        [% UNLESS ( messaging_form_inactive ) %]<th>Do not notify</th>[% END %]
    </tr>
    [% FOREACH messaging_preference IN messaging_preferences %]
    <tr>
      <td>[% IF ( messaging_preference.Item_Due ) %]Item due
          [% ELSIF ( messaging_preference.Advance_Notice ) %]Advance notice
          [% ELSIF ( messaging_preference.Upcoming_Events ) %]Upcoming events
          [% ELSIF ( messaging_preference.Hold_Filled ) %]Hold filled
          [% ELSIF ( messaging_preference.Item_Check_in ) %]Item check-in
          [% ELSIF ( messaging_preference.Item_Checkout ) %]Item checkout
          [% ELSE %]Unknown [% END %]</td>
      [% IF ( messaging_preference.takes_days ) %]
      <td>
          [% IF ( messaging_form_inactive ) %]
            <select name="[% messaging_preference.message_attribute_id %]-DAYS" disabled="disabled">
          [% ELSE %]
            <select name="[% messaging_preference.message_attribute_id %]-DAYS">
          [% END %]
          [% FOREACH select_day IN messaging_preference.select_days %]
          [% IF ( select_day.selected ) %]<option value="[% select_day.day %]" selected="selected">[% select_day.day %]</option>[% ELSE %]
          <option value="[% select_day.day %]">[% select_day.day %]</option>
      [% END %]
          [% END %]
        </select>
      </td>
      [% ELSE %]
      <td>-</td>
      [% END %]

      [% IF Koha.Preference('SMSSendDriver') %]
        [% IF ( messaging_preference.transport_sms ) %]
          <td>
          [% IF ( messaging_form_inactive ) %]
              [% IF ( messaging_preference.transports_sms ) %]
                 <input type="checkbox"
                 id="sms[% messaging_preference.message_attribute_id %]"
                 name="[% messaging_preference.message_attribute_id %]"
                 value="sms" checked="checked" disabled="disabled" />
              [% ELSE %]
                 <input type="checkbox"
                 id="sms[% messaging_preference.message_attribute_id %]"
                 name="[% messaging_preference.message_attribute_id %]"
                 value="sms" disabled="disabled" />
              [% END %]
          [% ELSE %]
              [% IF ( messaging_preference.transports_sms ) %]
                 <input type="checkbox"
                 id="sms[% messaging_preference.message_attribute_id %]"
                 name="[% messaging_preference.message_attribute_id %]"
                 value="sms" checked="checked" class="active_notify" data-attr-id="[% messaging_preference.message_attribute_id %]" />
              [% ELSE %]
                 <input type="checkbox"
                 id="sms[% messaging_preference.message_attribute_id %]"
                 name="[% messaging_preference.message_attribute_id %]"
                 value="sms" class="active_notify" data-attr-id="[% messaging_preference.message_attribute_id %]" />
              [% END %]
          [% END %]
          </td>
        [% ELSE %]
          <td>-</td>
        [% END %]
      [% END %]

      [% IF Koha.Preference('TalkingTechItivaPhoneNotification') %]
        [% IF ( messaging_preference.transport_phone ) %]
          <td>
          [% IF ( messaging_form_inactive ) %]
              [% IF ( messaging_preference.transports_phone ) %]
                 <input type="checkbox"
                 id="phone[% messaging_preference.message_attribute_id %]"
                 name="[% messaging_preference.message_attribute_id %]"
                 value="phone" checked="checked" disabled="disabled" />
              [% ELSE %]
                 <input type="checkbox"
                 id="phone[% messaging_preference.message_attribute_id %]"
                 name="[% messaging_preference.message_attribute_id %]"
                 value="phone" disabled="disabled" />
              [% END %]
          [% ELSE %]
              [% IF ( messaging_preference.transports_phone ) %]
                 <input type="checkbox"
                 id="phone[% messaging_preference.message_attribute_id %]"
                 name="[% messaging_preference.message_attribute_id %]"
                 value="phone" checked="checked" class="active_notify" data-attr-id="[% messaging_preference.message_attribute_id %]" />
              [% ELSE %]
                 <input type="checkbox"
                 id="phone[% messaging_preference.message_attribute_id %]"
                 name="[% messaging_preference.message_attribute_id %]"
                 value="phone" class="active_notify" data-attr-id="[% messaging_preference.message_attribute_id %]" />
              [% END %]
          [% END %]
          </td>
        [% ELSE %]
          <td>-</td>
        [% END %]
      [% END %]

      [% IF ( messaging_preference.transport_email ) %]
      <td>
          [% IF ( messaging_form_inactive ) %]
              [% IF ( messaging_preference.transports_email ) %]
                <input type="checkbox"
                   id="email[% messaging_preference.message_attribute_id %]"
                   name="[% messaging_preference.message_attribute_id %]"
                   value="email" checked="checked" disabled="disabled" />
              [% ELSE %]
                <input type="checkbox"
                   id="email[% messaging_preference.message_attribute_id %]"
                   name="[% messaging_preference.message_attribute_id %]"
                   value="email" disabled="disabled" />
              [% END %]
          [% ELSE %]
              [% IF ( messaging_preference.transports_email ) %]
            <input type="checkbox"
                 id="email[% messaging_preference.message_attribute_id %]"
                 name="[% messaging_preference.message_attribute_id %]"
                 value="email" checked="checked" class="active_notify" data-attr-id="[% messaging_preference.message_attribute_id %]" />
              [% ELSE %]
            <input type="checkbox"
                 id="email[% messaging_preference.message_attribute_id %]"
                 name="[% messaging_preference.message_attribute_id %]"
                 value="email" class="active_notify" data-attr-id="[% messaging_preference.message_attribute_id %]" />
              [% END %]
          [% END %]
      </td>
      [% ELSE %]
      <td>-</td>
      [% END %]

      [% IF ( messaging_preference.has_digest ) %]
      <td>
          [% IF ( messaging_form_inactive ) %]
              [% IF ( messaging_preference.digest ) %]
                <input type="checkbox"
                     id="digest[% messaging_preference.message_attribute_id %]"
                     value="[% messaging_preference.message_attribute_id %]"
                     name="digest" checked="checked" disabled="disabled" />
              [% ELSE %]
                <input type="checkbox"
                     id="digest[% messaging_preference.message_attribute_id %]"
                     value="[% messaging_preference.message_attribute_id %]"
                     name="digest" disabled="disabled" />
              [% END %]
          [% ELSE %]
              [% IF ( messaging_preference.digest ) %]
                <input type="checkbox"
                     id="digest[% messaging_preference.message_attribute_id %]"
                     value="[% messaging_preference.message_attribute_id %]"
                     name="digest" checked="checked" class="active_notify" data-attr-id="[% messaging_preference.message_attribute_id %]" />
              [% ELSE %]
                <input type="checkbox"
                     id="digest[% messaging_preference.message_attribute_id %]"
                     value="[% messaging_preference.message_attribute_id %]"
                     name="digest" class="active_notify" data-attr-id="[% messaging_preference.message_attribute_id %]" />
              [% END %]
          [% END %]
      </td>
      [% ELSE %]
      <td>-</td>
      [% END %]

<!--       [% IF ( messaging_preference.transport_rss ) %]
      <td>
          [% IF ( messaging_form_inactive ) %]
            <input type="checkbox"
                 id="rss[% messaging_preference.message_attribute_id %]"
                 name="[% messaging_preference.message_attribute_id %]"
                 value="rss"   [% messaging_preference.transport_rss %] disabled="disabled" />
          [% ELSE %]
            <input type="checkbox"
                 id="rss[% messaging_preference.message_attribute_id %]"
                 name="[% messaging_preference.message_attribute_id %]"
                 value="rss"   [% messaging_preference.transport_rss %] class="active_notify" data-attr-id="[% messaging_preference.message_attribute_id %]" />
          [% END %]
      </td>
      [% ELSE %]
      <td>-</td>
      [% END %] -->

      [% UNLESS ( messaging_form_inactive ) %]
      <td><input type="checkbox" class="none" id="none[% messaging_preference.message_attribute_id %]" /></td>
      [% END %]
    </tr>
    [% END %]
  </table>
