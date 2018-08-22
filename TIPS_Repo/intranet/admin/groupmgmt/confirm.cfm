<!--------------------------------------->
<!--- Programmer: Andy Leontovich     --->
<!--- File: confirm.cfm          --->
<!--- Company: Maxim Group/ALC        --->
<!--- Date: july                       --->
<!--------------------------------------->

<cfinclude template="/intranet/header.cfm">
<ul>
<form action="../index2.cfm" method="post">
<table width="420" cellspacing="2" cellpadding="2" border="0">

<cfif url.confirm is 1>
	
	<tr bgcolor="#336666">
    <td><font color="White" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: small; font-weight: bold;">Confirm</font></td>
</tr>
<tr bgcolor="#f7f7f7">
    <td><BR><ul><font color="DimGray" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">The Group has been added.</font></ul></td>
</tr>
	
<cfelseif url.confirm is 2>
	
	<tr bgcolor="#336699">
    <td><font color="White" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: small; font-weight: bold;">Confirm</font></td>
</tr>
<tr bgcolor="#f7f7f7">
    <td><BR><ul><font color="DimGray" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">The Group has been updated.</font></ul></td>
</tr>
	
<cfelseif url.confirm is 3>
	
	
	<tr bgcolor="#663300">
    <td><font color="White" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: small; font-weight: bold;">Confirm</font></td>
</tr>
<tr bgcolor="#f7f7f7">
    <td><BR><ul><font color="DimGray" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">The Group has been deleted.</font></ul></td>
</tr>
</cfif>

<tr bgcolor="#eaeaea">
    <td><font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: xx-small; font-weight: bold;">Select from the Navigation menu above to go to another part of the site.</font></td>
</tr>
</table>
</form></ul>



<cfinclude template="/intranet/Footer.cfm">

