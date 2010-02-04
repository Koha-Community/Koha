<!-- TMPL_IF NAME="error" -->
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
        <!-- TMPL_IF NAME="101" -->
        The database returned an error while <!-- TMPL_IF NAME="card_element" -->saving <!-- TMPL_VAR NAME="card_element" --> <!-- TMPL_VAR NAME="element_id" --><!-- TMPL_ELSE -->attempting a save operation<!-- /TMPL_IF -->. Please have your system administrator check the error log for details.
        <!-- TMPL_ELSIF NAME="102" -->
        The database returned an error while <!-- TMPL_IF NAME="card_element" -->deleteing <!-- TMPL_VAR NAME="card_element" --> <!-- TMPL_VAR NAME="element_id" --><!-- TMPL_ELSIF NAME=image_ids --><!-- TMPL_VAR NAME="image_ids" --><!-- TMPL_ELSE -->attempting a delete operation<!-- /TMPL_IF -->. Please have your system administrator check the error log for details.
        <!-- TMPL_ELSIF NAME="201" -->
        An unsupported operation was attempted<!-- TMPL_IF NAME="element_id" --> on <!-- TMPL_VAR NAME="card_element" --> <!-- TMPL_VAR NAME="element_id" --><!-- /TMPL_IF -->. Please have your system administrator check the error log for details.
        <!-- TMPL_ELSIF NAME="202" -->
        An error has occurred. Please ask your system administrator to check the error log for more details.
        <!-- TMPL_ELSIF NAME="203" -->
        A non-existent or invalid branch code was supplied. Please <a href="/cgi-bin/koha/circ/selectbranchprinter.pl">verify</a> that you have a branch selected.
        <!-- TMPL_ELSIF NAME="301" -->
        An error has occurred while attempting to upload the image file. Please ask you system administrator to check the error log for more details.
        <!-- TMPL_ELSIF NAME="302" -->
        Image exceeds 500KB. Please resize and import again.
        <!-- TMPL_ELSIF NAME="303" -->
        The database image quota currently only allows a maximum of <!-- TMPL_VAR NAME="image_limit" --> images to be stored at any one time. Please delete one or more images to free up quota space.
        <!-- TMPL_ELSIF NAME="401" -->
        An error has occurred and the item(s) was not added to batch <!-- TMPL_VAR NAME="batch_id" -->. Please have your system administrator check the error log for details.
        <!-- TMPL_ELSIF NAME="402" -->
        The item(s) was not added because the branch is not set. Please set your branch before adding items to a batch.
        <!-- TMPL_ELSIF NAME="403" -->
        An error has occurred and the item(s) was not removed from batch <!-- TMPL_VAR NAME="batch_id" -->. Please have your system administrator check the error log for details.
        <!-- TMPL_ELSIF NAME="404" -->
        An error has occurred and batch <!-- TMPL_VAR NAME="batch_id" --> was not deleted.  Please have your system administrator check the error log for details.
        <!-- TMPL_ELSIF NAME="405" -->
        An error has occurred and batch <!-- TMPL_VAR NAME="batch_id" --> not fully de-duplicated.
        <!-- TMPL_ELSE -->
        <!-- /TMPL_IF -->
    </span>
    <span id="close" style="position: absolute; top: 100px; left: 175px;">
        <input type='submit' value='Close' onClick='document.getElementById("mypopup").style.display = "none"'>
    </span>
</div>
<!-- /TMPL_IF -->

