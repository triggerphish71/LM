<!--------------------------------------->
<!--- Programmer: Andy Leontovich     --->
<!--- File: admin/error.cfm          --->
<!--- Company: Maxim Group/ALC        --->
<!--- Date: june                       --->
<!--------------------------------------->
<cfparam name="url.errorid" default="0">
<cfinclude template="/intranet/header.cfm">
<form action="">
	<ul><table width="400" cellspacing="2" cellpadding="2" border="0">
	<tr bgcolor="#804040">
	    <td>&nbsp;<font color="White" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: medium;">Error</font></td>
	</tr>
	<tr bgcolor="#eaeaea">
	    <td>
		<br>
		<ul>
		&nbsp;<font face="Arial" size="2" style="font-weight: bold;">
		
			<cfif url.errorid is 0>
				Please select a category.
			<cfelseif url.errorid is 1>
				Please select a topic.
			<cfelseif url.errorid is 2>
				The group name you have selected is not unique. Please select another group name.
			<cfelseif url.errorid is 3>
				The category name you have selected is not unique. Please select another category name.
		</cfif>
		</font>
		</ul>
		</td>
	</tr>
	<tr bgcolor="#eaeaea">
	    <td><input type="button" name="submit" value="back" onClick="history.back();"></td>
	</tr>
	</table></ul>
	</form>
	<cfinclude template="/intranet/footer.cfm">
	
	
	
