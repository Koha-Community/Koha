function ValidateCode()
{
 // Validating the patron id by Oscar R. Paredes
 // Please do not remove this line and the line above.
  var patron_id = document.forms['auth'].userid.value;
  var snumber = "Pp 0123456789";
  var len = patron_id.length;
  var new_patron_id = "";
  var bOK = true
  if (patron_id.length != 0)
  {
   for (i=0;(i<len)&&(bOK);i++)
    { pos = snumber.indexOf(patron_id.substring(i,i+1));
      if (pos <0 || pos > 12)
        { alert("Your card number is invalid, please verify it.");
          bOK = false;
        }
      else
        { if (pos > 2)
            car = patron_id.substring(i,i+1);
          else
            car = "";
          new_patron_id = new_patron_id + car;
        }
    } // end for i
   while (bOK && (new_patron_id.length < 7))
     new_patron_id = "0" + new_patron_id;
   if (new_patron_id.length > 7)
     { alert("Your library card number is too long.");
       bOK = false;
     }
   if (bOK)
     document.forms['auth'].userid.value = new_patron_id;
   else
     {
       document.forms['auth'].userid.value = "";
       document.forms['auth'].userid.focus();
     }
  }
}

function CheckAll()
{
count = document.mainform.elements.length;
    for (i=0; i < count; i++) 
	{
	    if(document.mainform.elements[i].checked == 1){
			document.mainform.elements[i].checked = 0;
		} else {
			document.mainform.elements[i].checked = 1;
		}
	}
}

function confirmDelete(message) {
	var agree = confirm(message);
	if(agree) {
		return true;
	} else {
		return false;
	}
}

function Dopop(link) {
	newin=window.open(link,'popup','width=500,height=400,toolbar=false,scrollbars=yes');
	}