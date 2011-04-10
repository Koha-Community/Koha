[% IF ( error ) %]
<script type='text/javascript'>
// Gratuitiously copied from http://dhtmlpopups.webarticles.org/basics.php
// Determine how much the visitor had scrolled

var scrolledX, scrolledY;
if( self.pageYOffset ) {
  scrolledX = self.pageXOffset;
  scrolledY = self.pageYOffset;
} else if( document.documentElement && document.documentElement.scrollTop ) {
  scrolledX = document.documentElement.scrollLeft;
  scrolledY = document.documentElement.scrollTop;
} else if( document.body ) {
  scrolledX = document.body.scrollLeft;
  scrolledY = document.body.scrollTop;
}

// Determine the coordinates of the center of the page

var centerX, centerY;
if( self.innerHeight ) {
  centerX = self.innerWidth;
  centerY = self.innerHeight;
} else if( document.documentElement && document.documentElement.clientHeight ) {
  centerX = document.documentElement.clientWidth;
  centerY = document.documentElement.clientHeight;
} else if( document.body ) {
  centerX = document.body.clientWidth;
  centerY = document.body.clientHeight;
}

function myPopupRelocate() {
 var scrolledX, scrolledY;
 if( self.pageYOffset ) {
   scrolledX = self.pageXOffset;
   scrolledY = self.pageYOffset;
 } else if( document.documentElement && document.documentElement.scrollTop ) {
   scrolledX = document.documentElement.scrollLeft;
   scrolledY = document.documentElement.scrollTop;
 } else if( document.body ) {
   scrolledX = document.body.scrollLeft;
   scrolledY = document.body.scrollTop;
 }

 var centerX, centerY;
 if( self.innerHeight ) {
   centerX = self.innerWidth;
   centerY = self.innerHeight;
 } else if( document.documentElement && document.documentElement.clientHeight ) {
   centerX = document.documentElement.clientWidth;
   centerY = document.documentElement.clientHeight;
 } else if( document.body ) {
   centerX = document.body.clientWidth;
   centerY = document.body.clientHeight;
 }

 var leftOffset = scrolledX + (centerX - 250) / 2;
 var topOffset = scrolledY + (centerY - 200) / 2;

 document.getElementById("mypopup").style.top = topOffset + "px";
 document.getElementById("mypopup").style.left = leftOffset + "px";
}

window.onload=function(){
 myPopupRelocate();
 document.getElementById("mypopup").style.display = "block";
 document.body.onscroll = myPopupRelocate;
 window.onscroll = myPopupRelocate;
}
</script>
<div id='mypopup' name='mypopup' style='position: absolute; width: 400px; height: 131px; display: none; background: #FFC url(/intranet-tmpl/prog/img/alert-bg.gif) repeat-x left 0; border: 1px solid #bcbcbc; right: 0px; top: 500px'>
    <span id="message" style="position: absolute; top: 5px; left: 5px;">
    <strong style="color: #900;">WARNING:</strong>
        [% IF ( 101 ) %]
        The database returned an error while [% IF ( card_element ) %]saving [% card_element %] [% element_id %][% ELSE %]attempting a save operation[% END %]. Please have your system administrator check the error log for details.
        [% ELSIF ( 102 ) %]
        The database returned an error while [% IF ( card_element ) %]deleting [% card_element %] [% element_id %][% ELSIF ( image_ids ) %][% image_ids %][% ELSE %]attempting a delete operation[% END %]. Please have your system administrator check the error log for details.
        [% ELSIF ( 201 ) %]
        An unsupported operation was attempted[% IF ( element_id ) %] on [% card_element %] [% element_id %][% END %]. Please have your system administrator check the error log for details.
        [% ELSIF ( 202 ) %]
        An error has occurred. Please ask your system administrator to check the error log for more details.
        [% ELSIF ( 203 ) %]
        A non-existent or invalid branch code was supplied. Please <a href="/cgi-bin/koha/circ/selectbranchprinter.pl">verify</a> that you have a branch selected.
        [% ELSIF ( 301 ) %]
        An error has occurred while attempting to upload the image file. Please ask you system administrator to check the error log for more details.
        [% ELSIF ( 302 ) %]
        Image exceeds 500KB. Please resize and import again.
        [% ELSIF ( 303 ) %]
        The database image quota currently only allows a maximum of [% image_limit %] images to be stored at any one time. Please delete one or more images to free up quota space.
        [% ELSIF ( 401 ) %]
        An error has occurred and the item(s) was not added to batch [% batch_id %]. Please have your system administrator check the error log for details.
        [% ELSIF ( 402 ) %]
        The item(s) was not added because the branch is not set. Please set your branch before adding items to a batch.
        [% ELSIF ( 403 ) %]
        An error has occurred and the item(s) was not removed from batch [% batch_id %]. Please have your system administrator check the error log for details.
        [% ELSIF ( 404 ) %]
        An error has occurred and batch [% batch_id %] was not deleted.  Please have your system administrator check the error log for details.
        [% ELSIF ( 405 ) %]
        An error has occurred and batch [% batch_id %] not fully de-duplicated.
        [% ELSE %]
        [% END %]
    </span>
    <span id="close" style="position: absolute; top: 100px; left: 175px;">
        <input type='submit' value='Close' onClick='document.getElementById("mypopup").style.display = "none"'>
    </span>
</div>
[% END %]

