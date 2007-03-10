    <div id="action">
            
            <div class="edit">
                <a href="/cgi-bin/koha/cataloguing/addbiblio.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->&frameworkcode=<!--TMPL_VAR Name="current_framework" -->&op=">
                    Edit biblio
                </a>
                <a href="/cgi-bin/koha/cataloguing/addbiblio.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->&frameworkcode=<!--TMPL_VAR Name="current_framework" -->&op=duplicate">
                    Duplicate
                </a>
                <a href="/cgi-bin/koha/cataloguing/additem.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->">
                    Edit item
                </a>
                <a href="javascript:confirm_deletion()">
                    Delete
                </a>
            </div>
            
            <div class="view">
                <a href="/cgi-bin/koha/catalogue/MARCdetail.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->">
                Complete
                </a>
                <a href="/cgi-bin/koha/catalogue/detail.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->">
                    Normal
                </a>
                <a href="/cgi-bin/koha/catalogue/ISBDdetail.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->">
                    ISBD
                </a>
            </div>
            
            <div class="others">
                <a href="#" onclick="JavaScript:window.open('/cgi-bin/koha/bookshelves/addbookbybiblionumber.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->','Add_to_bookshelf','width=500,height=400,toolbar=false,scrollbars=yes'); return false;">
                    Add to shelf
                </a>
                <a href="/cgi-bin/koha/catalogue/detailprint.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->">
                    Print
                </a>
                <!-- TMPL_IF name="subscriptionsnumber" -->
                <a href="/cgi-bin/koha/serials/serials-home.pl?searched=1&title_filter=<!-- TMPL_VAR NAME="subscriptiontitle" -->">
                    Subscription(s)
                </a>
                <!-- /TMPL_IF -->
                <!-- TMPL_IF NAME="norequests" -->
                <!-- TMPL_ELSE -->
                    <a href="/cgi-bin/koha/reserve/request.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->">
                        Request
                    </a>
                <!-- /TMPL_IF -->
                
                <a href="/cgi-bin/koha/catalogue/issuehistory.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->&title=<!-- TMPL_VAR NAME="title"-->&author=<!-- TMPL_VAR NAME="author"-->" >
                    Issue history
                </a>
  
                <!-- TMPL_IF NAME="CAN_user_parameters"-->
               <a href="/cgi-bin/koha/tools/viewlog.pl?do_it=1&module=CATALOGUING&action=MODIFY&object=<!-- TMPL_VAR NAME="biblionumber"-->">Modification log</a>
                <!-- /TMPL_IF --> 
            </div>
    </div>
