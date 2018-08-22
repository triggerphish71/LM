<!--------------------------------------->
<!--- Programmer: Andy Leontovich     --->
<!--- File: admin/confirmation.cfm          --->
<!--- Company: Maxim Group/ALC        --->
<!--- Date: May                       --->
<!--------------------------------------->
<cfparam name="url.taskid" default="0">
<cfinclude template="/intranet/header.cfm">
<ul><form action="index2.cfm" method="post">
<table width="420" cellspacing="2" cellpadding="2" border="0">
<cfif url.function is 1>
	<tr bgcolor="#006666">
<cfelseif url.function is 2>
	<tr bgcolor="#336699">
<cfelse>
	<tr bgcolor="#663300">
</cfif>
    <td><font color="White" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: small; font-weight: bold;">Confirmed</font></td>
</tr>
<tr bgcolor="#f7f7f7">
<cfif url.function is 1>
	<cfif url.taskid is 1>
		<td>
		<br>
		<ul>
		<font color="dimGray" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">The entry was entered into the HR add queue.</font>
		</ul>
		</td>
	<cfelse>
		<td>
		<br>
		<ul>
		<font color="dimGray" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">The category was added.</font>
		</ul>
		</td>
	</cfif>
	
</tr>
	<tr bgcolor="#eaeaea">
    <td>
		<input type="button" name="Back" value="Back to Admin" onClick="location.href='/intranet/admin/index2.cfm?id=15';">
	</td>
</tr>
<cfelseif url.function is 2>
	<cfif url.taskid is 1>
		<td>
		<br>
		<ul>
		<font color="dimGray" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">The entry was entered into the HR update queue.</font>
		</ul>
		</td>
	<cfelse>
		<td>
		<br>
		<ul>
		<font color="dimGray" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">The category was updated.</font>
		</ul>
		</td>
	</cfif>
</tr>
	<tr bgcolor="#eaeaea">
    <td>
		<input type="button" name="Back" value="Back to Admin" onClick="location.href='/intranet/admin/index2.cfm?id=15';">
	</td>
</tr>
<cfelse>
	<cfif url.taskid is 2>
	<td><br><ul><font color="dimGray" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">The entry was entered into the HR delete queue.</font></ul></td>
	</tr>
	<tr bgcolor="#eaeaea">
    <td>
		<input type="button" name="Back" value="Back to Admin" onClick="location.href='/intranet/admin/index2.cfm?id=15';">
	</td>
</tr>
	<cfelse>
	<td><br><ul><font color="dimGray" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">The entry was deleted.</font></ul></td>
	</tr>
	<tr bgcolor="#eaeaea">
    <td>
		<input type="button" name="Back" value="Back to Admin" onClick="location.href='/intranet/admin/index2.cfm?id=15';">
	</td>
</tr>
	</cfif>
</cfif>


</table></form></ul>




<cfinclude template="/intranet/Footer.cfm">
