          <select name="overlay_action" id="overlay_action">
            <!-- TMPL_IF NAME="overlay_action_replace" -->
                <option value="replace"  selected="selected">
            <!-- TMPL_ELSE -->
                <option value="replace">
            <!-- /TMPL_IF -->
                Replace existing record with incoming record</option>
            <!-- TMPL_IF NAME="overlay_action_create_new" -->
                <option value="create_new" selected="selected">
            <!-- TMPL_ELSE -->
                <option value="create_new">
            <!-- /TMPL_IF -->
                Add incoming record</option>
            <!-- TMPL_IF NAME="overlay_action_ignore" -->
                <option value="ignore" selected="selected">
            <!-- TMPL_ELSE -->
                <option value="ignore">
            <!-- /TMPL_IF -->
                Ignore incoming record (its items may still be processed)</option>
        </select>
