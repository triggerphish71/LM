<!--------------------------------------->
<!--- Programmer: Andy Leontovich     --->
<!--- File: admin/confirm.cfm          --->
<!--- Company: Maxim Group/ALC        --->
<!--- Date: May                       --->
<!--------------------------------------->
<cfparam name="url.previewcode" default="0">
<cfparam name="url.HRID" default="0">
<cfset datasource = "DMS">
<cfinclude template="/intranet/header.cfm">

<!--- revised and added by Paul Buendia 2.25.2005---->
<style>
.fstyle {
font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; 
font-size: small; 
font-weight: bold;
}
</style>

<ul>

<cfif url.previewcode is 1>
<form action="">
	<table width="420" cellspacing="2" cellpadding="2" border="0">
	<tr bgcolor="#006666">
	    <td>&nbsp;<font color="White" class="fstyle">Confirmed</font></td>
	</tr>
	<tr bgcolor="#f7f7f7">
	    <td><br><ul type="square">&nbsp;<font face="Arial" size="2" style="font-weight: bold;">The content has been submitted.</font></ul></td>
	</tr>
	<tr bgcolor="#eaeaea">
	    <td><input type="button" name="back" value="Add another assignment" onClick="history.go(-3);"></td>
	</tr>
	</table>
	
	</form>
	
<cfelseif url.previewcode is 2>
<form action="">
	<table width="420" cellspacing="2" cellpadding="2" border="0">
	<tr bgcolor="#004080">
	    <td>&nbsp;<font color="White" class="fstyle">Confirmed</font></td>
	</tr>
	<tr bgcolor="#f7f7f7">
	    <td><br><ul type="square">&nbsp;<font face="Arial" size="2" style="font-weight: bold;">The content change has been submitted.</font></ul></td>
	</tr>
	<tr bgcolor="#eaeaea">
	    <td>&nbsp;<input type="button" name="back" value="Edit again" onClick="history.go(-2);"></td>
	</tr>
	</table>
	</form>

<cfelseif url.previewcode is 3>
<form action="">
	<table width="420" cellspacing="2" cellpadding="2" border="0">
	<tr bgcolor="#804040">
	    <td>&nbsp;<font color="White" class="fstyle">Confirmed</font></td>
	</tr>
	<tr bgcolor="#f7f7f7">
	    <td><br><ul>&nbsp;<font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">The content has been deleted.</font></ul></td>
	</tr>
	<tr bgcolor="#eaeaea">
	    <td><input type="button" name="back" value="Back to Admin" onClick="location.href='index2.cfm?id=1';"><!--- comment: takes you back to Copy admin---></td>
	</tr>
	</table>
	</form>
	
	<cfelseif url.previewcode is 4>
<form action="">
	<table width="420" cellspacing="2" cellpadding="2" border="0">
	<tr bgcolor="Dimgray">
	    <td>&nbsp;<font color="White" class="fstyle">Confirmed</font></td>
	</tr>
<tr bgcolor="#f7f7f7">
	    <td>
		<cfif URL.HRID is 1> 
		<br>
		<ul>
		&nbsp;
		<font face="Verdana" size="2"  style="font-weight: bold;">The content visibility has been changed.
			The job posting is now viewable.
		<cfelseif URL.HRID is 2>
		<br>
		<ul>
		&nbsp;
		<font face="Verdana" size="2"  style="font-weight: bold;">The content visibility has been changed.
			The job posting has been removed.
		<cfelseif URL.HRID is 3>
			<cfquery name="getsubmitter" datasource="#datasource#" dbtype="ODBC">
			Select email,fname,lname
			From vw_employees
			Where employee_ndx = #submitter#
			</cfquery>
			<BR>
				<ul><font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">You have denied the request for the job posting. Would you like to offer an explanation to the requestor? <BR><br>
				<A HREF="mailto:<cfoutput>#getsubmitter.email#</cfoutput>&subject=Your request for your job announcement was not approved.&body=Dear <cfoutput>#getsubmitter.fname#</cfoutput>," target="_blank">[Yes]</A>&nbsp;&nbsp;<A HREF="index2.cfm?ID=20">[No]</A></ul></font>
		</cfif>
		</font>
		</ul>
		</td>
	</tr>
	<tr bgcolor="#eaeaea">
	    <td>&nbsp;<input type="button" name="back" value="View another request" onClick="location.href='index2.cfm?id=20';"></td>
	</tr>
	</table>
	</form>
	<cfelseif url.previewcode is 5>
	<!--- comment: from security assignments--->
		<form action="">
		<table width="420" cellspacing="2" cellpadding="2" border="0">
		<tr bgcolor="#408080">
		    <td>&nbsp;<font color="White" class="fstyle">Confirmed</font></td>
		</tr>
		<tr bgcolor="#f7f7f7">
		    <td><br><ul>&nbsp;<font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">The assignment is complete.</font></ul></td>
		</tr>
		<tr bgcolor="#eaeaea">
		    <td><input type="button" name="back" value="Back to Admin" onClick="history.go(-3);"></td>
		</tr>
		</table>
		</form>
	
	<cfelseif url.previewcode is 6>
	<!--- comment: from security assignments--->
		<form action="">
		<table width="420" cellspacing="2" cellpadding="2" border="0">
		<tr bgcolor="#006666">
		    <td>&nbsp;<font color="White" class="fstyle">Confirmed</font></td>
		</tr>
		<tr bgcolor="#f7f7f7">
		    <td><br><ul>&nbsp;<font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">The assignment is complete.</font></ul></td>
		</tr>
		<tr bgcolor="#eaeaea">
		    <td><input type="button" name="back" value="Back to Admin" onClick="history.go(-3);"></td>
		</tr>
		</table>
		</form>
		
	</cfif>
</ul>

<cfinclude template="/intranet/Footer.cfm">
