<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Error Template</title>
</head>

<body>
<!--- <cfinclude template="../../header.cfm"> --->
<table width="60%" border="5" bordercolordark="##333333"   bordercolorlight="##808080" cellspacing="5" cellpadding="5">
<cfoutput>
	<tr bordercolor="##FFFFFF">
		<td colspan="4"  style="text-align:center; color:##FF0000 " bordercolor="##FFFFFF"> Missing information has caused the #processname# to stop. 
		<br/><b> This process did not complete</b> <br />
		Correct the missing information and restart the process
		</td>
	</tr>
 
	<tr>
		<td colspan="2" bordercolor="##FFFFFF"></td>
	</tr>
	<tr bordercolor="##000000"  >
		<td >From: #Formname#</td>
		<td>Community: #session.housename#</td>
		<td>User: #session.fullname# - ID: #session.userid#</td>
		<td>Date: #dateformat(now(),'yyyy-mm-dd')# #timeformat(now(), 'hh:mm:SS')#	</td>
	</tr>
	<tr>
 
		<cfif Isdefined('Residentname')>
				<td colspan="2">Resident: #residentname#</td>
				<cfelse>
				<td colspan="2">&nbsp;</td>
			</cfif>
 
		<cfif IsDefined('residentID')>
			<td colspan="2">Tenant ID: #residentID#</td>
		<cfelse>
			<td colspan="2">&nbsp;</td>
		</cfif>
	</tr>
	<tr>
		<td colspan="4">Error Message: <br />#msg1#</td>
	</tr>
	<tr>
		<td colspan="2"  bordercolor="##FFFFFF">&nbsp;</td>
		<td colspan="2">Call Support at:&nbsp; 888-342-4252 </td>
	</tr>
	
<cfif url.wherefrom is 'MoveIn'>	
	<tr bordercolor="##FFFFFF">
		<td colspan="4"><a href="../Registration/Registration.cfm">Return to Move In Process</a></td>
	</tr>
</cfif>	
	<tr>
		<td colspan="2" bordercolor="##FFFFFF"></td>
	</tr>
	<tr bordercolor="##FFFFFF">
		<td colspan="4"><a href href="../MainMenu.cfm?SelectedHouse_ID=#session.qselectedhouse.ihouse_id#">Return to Home Page</a></td>
	</tr>
	</tr>		
</table>

</cfoutput>
</body>
<cfinclude template="../../Footer.cfm">
