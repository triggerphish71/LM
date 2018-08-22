<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Untitled Document</title>
</head>

<body>
<cfoutput>
    <cfset local.baseWebPath = ExpandPath( "\\fs01\ALC_IT\Invoices\" ) />
    <cfset custID = session.userid />
    <cfset filters = "*.pdf">
</cfoutput>

<cfdirectory action="list" 
directory="\\fs01\ALC_IT\Invoices\#trim(session.qSelectedHouse.cName)#" 
name="Invoices"  > 
<table>
<cfoutput>
		<TR>
			<TD colspan="2"><h2>Invoice List for #trim(session.qSelectedHouse.cName)#</h2></TD>
		</TR>
		<tr>
			<td style="text-align:center">File Name</td>
			<td style="text-align:center">Creation Date</td>
		</tr>
</cfoutput>
<cfoutput query="Invoices">
     <!---get the file name--->
     <cfset fname = ListFirst(Invoices.name, "." )>
     <!---get the file extenstion--->
     <cfset exten = ListLast(Invoices.name, ".")>
           <tr>
               <td style="text-align:left"><a href="\\fs01\ALC_IT\Invoices\#trim(session.qSelectedHouse.cName)#\#Invoices.name#"  target="_blank">#Invoices.name#</a></td>
 
               <td style="text-align:center">#Invoices.dateLastModified#</td>

          </tr> 
 
</cfoutput> 

 </table>
 <br />
 <div><a href="Menu.cfm">Return to Reports Menu</a></div>
</body>
</html>
