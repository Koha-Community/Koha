<!doctype html public "-//w3c//dtd html 4.0 transitional//en">
<!--Authored by rachel@katipo.co.nz 104:38 1/11/99-->
<!--updated by rachel@katipo.co.nz 01:02 5/11/99-->

<html>
<head>
<title>KOHA: INTRANET: Pr&eacute;stamos & Devoluciones</title>

</head>
<body text="black" bgcolor="white" link="#0000ff" vlink="#0000ff" "3366cc" Alink="#cc3300"
marginheight=0 marginwidth=0 leftmargin=0 topmargin=0 >



<!--HDL Colours

	Yellow = ffcc00
	light blue = ccccff
	bright blue links = 0000ff
	aubergine = 663266
	light green/grey = cccc99


-->

<!------------------------MENUS-------------------------------->

<table cellpadding=0 cellspacing=0 width="100%" border=0>
	<tr valign=top bgcolor=ffcc00  >
		<td COLSPAN=3>
			<table cellpadding=0 cellspacing=0  border=0 height=29>
				<tr valign=top bgcolor=ffcc00>
					<td background="<TMPL_VAR name="themelang">/images/issues-spot-1.gif" width="224" height="29">
						<font size=1 face="arial">
						<img src="<TMPL_VAR name="themelang">/images/holder.gif" width=210 height=4 alt=" " hspace=0 vspace=0>
						<br>
						<img src="<TMPL_VAR name="themelang">/images/holder.gif" width=35 height=21 align=left alt=" " hspace=0 vspace=0>
						KOHA: <A HREF="/cgi-bin/koha/mainpage.pl">INTRANET HDL</A>
						<br>
						<img src="<TMPL_VAR name="themelang">/images/holder.gif" width=210 height=1 alt=" " hspace=0 vspace=0>
						</FONT>
					</td>
				</TR>
			</TABLE>
		</TD>
		<TD COLSPAN=3 align=right>
			<font size=1 face="arial" color="white">I 1 &nbsp; &nbsp; </font>
		</TD>
	</tr>
	<TR VALIGN=TOP BGCOLOR="ffcc00">
		<TD  COLSPAN=6>
			<img src="<TMPL_VAR name="themelang">/images/holder.gif"  WIDTH=1  HEIGHT=12  HSPACE=0 vspace=0>
		</TD>
	</TR>
	<tr valign=top bgcolor=ffcc00>
		<TD>
			<img src="<TMPL_VAR name="themelang">/images/holder.gif" width=35 height=21 align=left alt=" " hspace=0 vspace=0>
		</TD>
		<td>
			<font size=2>
			<form action=/cgi-bin/simple-redirect.pl method=post>
			<select>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=57">PRESTAMOS 
          &amp; DEVOLUCIONES </option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">-) Pr&eacute;stamos 
          </option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - Informes </option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - - Pr&eacute;stamos Hoy </option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - - Pr&eacute;stamos Esta Semana </option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - - Pr&eacute;stamos Este Mes </option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">----------------------------------- 
          </option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">-&gt; 
          Devoluciones </option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - Informes </option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - - Devoluciones Hoy </option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - - Devoluciones Esta Semana </option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - - Devoluciones Este Mes </option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">----------------------------------- 
          </option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">-&gt; 
          Renovaciones </option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - Informes </option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - - Renovaciones Hoy </option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - - Renovaciones Esta Semana </option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - - Renovaciones Este Mes </option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">----------------------------------- 
          </option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">-&gt; 
          Libros Retrasados </option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - Retrasados Hoy </option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - Dinero Recibido</option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - - Hoy </option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - - Esta Semana </option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - - Este Mes</option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - - Este A&ntilde;o</option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">----------------------------------- 
          </option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">-&gt; 
          Libros Perdidos </option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - Informes </option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - - Perdidos Este Mes </option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - - Perdidos Este A&ntilde;o </option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">----------------------------------- 
          </option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">-&gt; 
          Informes Avanzados </option>
        </select>
			</form>
		</font></TD>
		<TD>
			<font size=2>

			<form name=choose2>
			<select name=dest size=1 onChange="leapto(this.form)">
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=57">CATALOGO</option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">-&gt; 
          B&uacute;squeda </option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">----------------------------------- 
          </option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">-&gt; 
          Agregar nuevo completo </option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">----------------------------------- 
          </option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">-&gt; 
          Bibliograf&iacute;a </option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - Agregar </option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - Modificar</option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - Borrar</option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - Informes </option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - - Cambios esta Semana </option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - - Cambios este Mes </option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - - Cambios este A&ntilde;o </option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">----------------------------------- 
          </option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">-&gt; 
          Items </option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - Agregar </option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - Modificar</option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - Borrar</option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - Informes</option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - - Cambios esta Semana</option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - - Cambios este Mes</option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - - Cambios este A&ntilde;o</option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">----------------------------------- 
          </option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">-&gt; 
          Informes de Inventario</option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - Levin </option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - - Libros</option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - - Libros Parlantes</option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - - Videos </option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; </option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - Shanon </option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - - Libros</option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - - Libros Parlantes</option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - - Videos </option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; </option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - Foxton </option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - - Libros</option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - - Libros Parlantes</option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - - Videos </option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">----------------------------------- 
          </option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">-&gt; 
          Informes Avanzados</option>
        </select>
			</form>
		</font></TD>
		<TD>
			<font size=2>

			<form name=choose2>
			<select name=dest size=1 onChange="leapto(this.form)">
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=57">ADQUISICIONES</option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">-&gt; 
          Ordenes</option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - Ordenar Libros</option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - Ordenar Series</option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - Ordenar Otros</option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - Cancelar Orden</option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - Informes</option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - - Ordenados esta Semana</option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - - Ordenados este Mes</option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - - Ordenados este A&ntilde;o</option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">----------------------------------- 
          </option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">-&gt; 
          Proveedores</option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - Detalles del Proveedor</option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - - Ordenes con este proveedor</option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - Fuentes del Proveedor</option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - - Amazon.com </option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - - Whitcoulls CD </option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - - Whitcoulls Website </option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">----------------------------------- 
          </option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">-&gt; 
          Entregas</option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - Aceptar Entrega</option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - Informes</option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - - Entregados este Mes</option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - - Entregados este A&ntilde;o</option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">----------------------------------- 
          </option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">-&gt; 
          Presupuesto</option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - Presupuesto para Libros 1</option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - - Este Mes</option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - - A&ntilde;o a la fecha</option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; </option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - Presupuesto para Libros 2</option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - - Este Mes</option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - - A&ntilde;o a la fecha</option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; </option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - Presupuesto para Libros 4</option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - - Este Mes</option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - - A&ntilde;o a la fecha</option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; </option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - Presupuesto para Libros 5 </option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - - Este Mes</option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - - A&ntilde;o a la fecha</option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; </option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - Presupuesto Total</option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - - Este Mes</option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - - A&ntilde;o a la fecha</option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; </option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - Informes de Fin de A&ntilde;o </option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; </option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - Compromisos para el A&ntilde;o Entrante</option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">----------------------------------- 
          </option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">-&gt; 
          Informes Avanzados</option>
        </select>
			</form>
		</font></TD>
		<TD>
			<font size=2>

			<form name=choose2>
			<select name=dest size=1 onChange="leapto(this.form)">
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=57">Usuarios</option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">-&gt; 
          Nuevo usuario</option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - Configurar</option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - Revisar si est&aacute; vencido</option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - Pol&iacute;tica</option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - Informes</option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - - Total de Usuarios</option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - - Nuevos esta Semana</option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - - Nuevos este Mes</option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - - Nuevos este A&ntilde;o</option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">----------------------------------- 
          </option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">-&gt; 
          Consulta de usuario</option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - Todos los libros prestados</option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - Retrasos</option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - Hist&oacute;rico</option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - Mensajes</option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - Informes</option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - - Promedio de Pr&eacute;stamos</option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - - Total de Pr&eacute;stamos</option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">----------------------------------- 
          </option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">-&gt; 
          Informes Avanzados</option>
        </select>
			</form>
		</font></TD>
		<TD>
			<font size=2>
			<form name=choose2>
			<select name=dest size=1 onChange="leapto(this.form)">
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=57">Otros</option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">-&gt; 
          OPAC </option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - B&uacute;squeda en Cat&aacute;logo</option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - Renovar Libros</option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - Informaci&oacute;n del Socio</option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - - Actualizar informaci&oacute;n</option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">----------------------------------- 
          </option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">-&gt; 
          Resources </option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - Fundview CD </option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">----------------------------------- 
          </option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">-&gt; 
          Library Website </option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">----------------------------------- 
          </option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">-&gt; 
          End of Year </option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - Stocktake </option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - Set New Budgets </option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - Audit Reports </option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">----------------------------------- 
          </option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">-&gt; 
          Help </option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - Telnet Help </option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - Intranet Help </option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">&nbsp; 
          &nbsp; - Searching Help </option>
          <option value="/cgi-bin/tododisplay.pl?user=Rachel&amp;todo=43">-&gt; 
          Advanced Reports </option>
        </select>
			</form>
		</font></td>
	</tr>
	<tr valign=top bgcolor=ffcc00 >
		<TD COLSPAN=4>&nbsp;</TD>
		<td  ALIGN=RIGHT COLSPAN=2 >
			<table cellpadding=0 cellspacing=0  border=0 height=29>
				<tr valign=top bgcolor=ffcc00 >
					<td background="<TMPL_VAR name="themelang">/images/issues-spot-2.gif" width="235" height="29"  ALIGN=RIGHT >
						<font size=1 face="arial">
						<img src="<TMPL_VAR name="themelang">/images/holder.gif" width=223 height=12 alt=" " hspace=0 vspace=0>
						<br>
            <img src="<TMPL_VAR name="themelang">/images/holder.gif" width=26 
            height=17 align=right alt=" " hspace=0 vspace=0>you are in <A HREF="index.html">PRESTAMOS 
            & DEVOLUCIONES</a><br>
						<img src="<TMPL_VAR name="themelang">/images/holder.gif" width=223 height=1 alt=" " hspace=0 vspace=0></FONT>
					</td>
				</TR>
			</TABLE>
		</TD>
	</tr>
	<TR VALIGN=TOP BGCOLOR="000000">
		<TD  COLSPAN=6>
			<img src="<TMPL_VAR name="themelang">/images/blackdot.gif"  WIDTH=1  HEIGHT=2  HSPACE=0 vspace=0>
		</TD>
	</TR>
</table>
<BLOCKQUOTE>
<TMPL_IF NAME="loggedinuser">
    <p align=left>Registrado como: <TMPL_VAR NAME="loggedinuser"> [<a href=/cgi-bin/koha/mainpage.pl?logout.x=1>Salir</a>]</p>
<TMPL_ELSE>
    <p align=left><a href=/cgi-bin/koha/opac-user.pl>Ingresar</a> a Koha</p>
</TMPL_IF>
</blockquote>