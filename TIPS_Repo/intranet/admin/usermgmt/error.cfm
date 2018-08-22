<!--------------------------------------->
<!--- Programmer: Andy Leontovich     --->
<!--- File: admin/error.cfm          --->
<!--- Company: Maxim Group/ALC        --->
<!--- Date: june                       --->
<!--------------------------------------->
<cfparam name="url.id" default="0">
<cfinclude template="/intranet/header.cfm">
<form action="">
	<ul><table width="400" cellspacing="2" cellpadding="2" border="0">
	<tr bgcolor="#804040">
	    <td>&nbsp;<font color="White" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: medium;">Error</font></td>
	</tr>
	<tr bgcolor="#eaeaea">
	    <td><br><ul>&nbsp;<font color="#0000A0" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">
		
		<cfif url.id is 1>
		An employee by that name is already in the system and you cannot have duplicate employees. Press the Back button to return to the entry screen. 
		<cfelseif url.id is 2>
			That user name is already in the system. Click the back button to return to the entry screen and change the username.
		</cfif>
		
		
		</font></ul></td>
	</tr>
	<tr bgcolor="#eaeaea">
	    <td><input type="button" name="submit" value="Back" onClick="history.back();"></td>
	</tr>
	</table></ul>
	</form>
	<cfinclude template="/intranet/footer.cfm">
	
	
	
