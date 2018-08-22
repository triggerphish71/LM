<!--------------------------------------->
<!--- Programmer: Andy Leontovich     --->
<!--- File: admin/deleteconfirm.cfm   --->
<!--- Company: Maxim Group/ALC        --->
<!--- Date: May                       --->
<!--------------------------------------->

<cfset datasource = "DMS">

<cfinclude template="/intranet/header.cfm">

<cfquery name="getreleasetodelete" datasource="#datasource#" dbtype="ODBC">
Select *
From releases
Where ndx = #ndx#
</cfquery>

<form action="actionadmin.cfm">
<ul>
<cfoutput query="getreleasetodelete">
<table width="600" cellspacing="2" cellpadding="2" border="0">
<tr bgcolor="##804040">
    <td>&nbsp;<font color="White" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: medium;">Delete Confirm</font></td>
</tr>
<tr>
    <td><font style="font-family: Verdana, sans-serif; font-size: x-small; font-style: normal; font-weight: bold;"><font color="##000000">Are you sure you want to delete the following content from the intranet?</font><BR><br></td>
</tr>
<tr>
    <td>
	<font style="font-family: Verdana, sans-serif; font-size: x-small; font-style: normal; font-weight: bold;"><font color="##5a5a5a">Heading:</font> #cheading#<BR>
	<font style="font-family: Verdana, sans-serif; font-size: x-small; font-style: normal; font-weight: bold;"><font color="##5a5a5a">Sub Heading:</font> #csubheading#<BR>
	<font style="font-family: Verdana, sans-serif; font-size: x-small; font-style: normal; font-weight: bold;"><font color="##5a5a5a">Edited By:</font> #ceditedby#<BR>
	<font style="font-family: Verdana, sans-serif; font-size: x-small; font-style: normal; font-weight: bold;"><font color="##5a5a5a">Content:</font>
	#content#<BR>

	</td>
</tr>
<tr>
    <td bgcolor="##eaeaea"><input type="submit" name="Submit" value="Delete Entry">&nbsp;&nbsp;<input type='button' name='back' value='Back' onClick='history.back();'></td>
</tr>
</table>
</cfoutput>
</ul>
<cfoutput><input type="hidden" name="ndx2" value="#getreleasetodelete.ndx#">
<input type="hidden" name="region" value="#region#">
</cfoutput><input type="hidden" name="previewcode" value="3">
</form>
<cfinclude template="/intranet/Footer.cfm">
