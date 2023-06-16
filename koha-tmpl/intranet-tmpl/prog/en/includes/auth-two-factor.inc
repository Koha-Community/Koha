[% BLOCK registration_form %]
    <div id="registration-form" style="display: none;">
        <div class="dialog message">
            <p>We recommend cloud-based mobile authenticator apps such as Authy, Duo Mobile, and LastPass. They can restore access if you lose your hardware device.</p>
            <p>Can't scan the code?</p>
            <p>To add the entry manually, provide the following details to the application on your phone.</p>
            <p>Account: "<span id="issuer">[% issuer | html %]</span>: <span id="key_id">[% key_id | html %]</span>"</p>
            <p>Key: "<span id="key_secret">[% secret32 | html %]</span>"</p>
            <p>Time based: Yes</p>
        </div>

        <div id="errors" class="dialog error" style="display: none;"></div>

        <fieldset class="rows">
            <input type="hidden" id="secret32" name="secret32" value="[% secret32 | html %]" />
            <ol>
                <li>
                    <label for="qr_code">QR code: </label>
                    <img id="qr_code" src="" />
                </li>
                <li>
                    <label for="pin_code">PIN code: </label>
                    <input type="text" id="pin_code" name="pin_code" value="" />
                </li>
            </ol>
        </fieldset>
        <fieldset class="action">
            <input id="register-2FA" type="submit" value="Register with two-factor app" />
            <a class="cancel" href="/cgi-bin/koha/members/two_factor_auth.pl">Cancel</a>
        </fieldset>
    </div>
[% END %]
