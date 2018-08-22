<!--------------------------------------->
<!--- Programmer: Andy Leontovich     --->
<!--- File: admin/libconfimation.cfm  --->
<!--- Company: Maxim Group/ALC        --->
<!--- Date: May                       --->
<!--------------------------------------->

<cfinclude template="/intranet/header.cfm">

<cfif url.function is 1>
	<cfif url.Libselectiontype is 1>
		<cfset action = "addlibrarycategories.cfm">
	<cfelseif url.Libselectiontype is 2>
		<cfset action = "addlibrarytopics.cfm">
	</cfif>
	
<cfelseif url.function is 2>
	<cfif url.Libselectiontype is 1>
		<cfset action = "editlibrarycategories.cfm">
	<cfelseif url.Libselectiontype is 2>
		<cfset action = "editlibrarytopics.cfm">
	</cfif>
	
<cfelseif url.function is 3>
	<cfif url.Libselectiontype is 1>
		<cfset action = "deletelibrarycategories.cfm">
	<cfelseif url.Libselectiontype is 2>
		<cfset action = "deletelibrarytopics.cfm">
	</cfif>
</cfif>

<cfif url.function is 1>
<cfoutput><form action="#action#" method="post"></cfoutput>
<ul><table width="400" cellspacing="2" cellpadding="2" border="0">
<tr bgcolor="#006666">
    <td><font color="White" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: medium;">Confirmed</font></td>
</tr>
<tr bgcolor="#eaeaea">
    <td><br><ul><font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Your information was added to the system.</font></ul></td>
</tr>
<tr bgcolor="#f7f7f7">
    <td><input type="submit" name="submit" value="Add another"></td>
</tr>
</table></ul>
</form>

	
<cfelseif url.function is 2>
	<cfoutput><form action="#action#" method="post"></cfoutput>
<ul><table width="400" cellspacing="2" cellpadding="2" border="0">
<tr bgcolor="#006699">
    <td><font color="White" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: medium;">Confirmed</font></td>
</tr>
<tr bgcolor="#eaeaea">
    <td><br><ul><font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Your information was changed.</font></ul></td>
</tr>
<tr bgcolor="#f7f7f7">
    <td><input type="submit" name="submit" value="Edit another"></td>
</tr>
</table></ul>
</form>
	
<cfelseif url.function is 3>
	<cfoutput><form action="#action#" method="post"></cfoutput>
<ul><table width="400" cellspacing="2" cellpadding="2" border="0">
<tr bgcolor="#993300">
    <td><font color="White" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: medium; font-weight: bold;">Confirmed</font></td>
</tr>
<tr bgcolor="#eaeaea">
    <td><br><ul><font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Your information was deleted from the system.</font></ul></td>
</tr>
<tr bgcolor="#f7f7f7">
    <td><input type="submit" name="submit" value="Delete another"></td>
</tr>
</table></ul>
</form>
</cfif>

<cfinclude template="/intranet/Footer.cfm">

