<!--------------------------------------->
<!--- Programmer: Andy Leontovich     --->
<!--- File: confirm.cfm          --->
<!--- Company: Maxim Group/ALC        --->
<!--- Date: july                       --->
<!--------------------------------------->

<cfinclude template="/intranet/header.cfm">
<ul>
<cfif url.confirm is 1>
<form action="../securityassignment.cfm" method="post">
<cfelse>
<form action="../index2.cfm" method="post">
</cfif>
<table width="420" cellspacing="2" cellpadding="2" border="0">

<cfif url.confirm is 1>
	
	<tr bgcolor="#336666">
    <td><font color="White" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: small; font-weight: bold;">Confirm</font></td>
</tr>
<tr bgcolor="#f7f7f7">
    <td><BR><ul><font color="DimGray" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">The Employee has been added.</font></ul></td>
</tr>
	
<cfelseif url.confirm is 2>
	
	<tr bgcolor="#336699">
    <td><font color="White" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: small; font-weight: bold;">Confirm</font></td>
</tr>
<tr bgcolor="#f7f7f7">
    <td><BR><ul><font color="DimGray" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">The Employee has been updated.</font></ul></td>
</tr>
	
<cfelseif url.confirm is 3>
	
	
	<tr bgcolor="#663300">
    <td><font color="White" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: small; font-weight: bold;">Confirm</font></td>
</tr>
<tr bgcolor="#f7f7f7">
    <td><BR><ul><font color="DimGray" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">The Employee has been deleted.</font></ul></td>
</tr>
</cfif>

<tr bgcolor="#eaeaea">
<td>
<cfif url.confirm is 1>
	<input type="submit" name="groups" value="Assign to Group">
	<input type="hidden" name="function" value="1">
	<cfoutput><input type="hidden" name="employee_ndx" value="#url.employeendx#"></cfoutput>
<cfelse>
	<font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: xx-small; font-weight: bold;">Select from the Navigation menu above to go to another part of the site.</font>
</cfif>
 
</td>
</tr>
</table>
</form></ul>



<cfinclude template="/intranet/Footer.cfm">

