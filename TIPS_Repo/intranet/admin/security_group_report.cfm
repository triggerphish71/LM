<!--------------------------------------->
<!--- Programmer: Andy Leontovich     --->
<!--- File: admin/security_group_report.cfm  --->
<!--- Company: Maxim Group/ALC        --->
<!--- Date: Oct                       --->
<!--------------------------------------->
<a name=TOP> 
<cfinclude template="/intranet/header.cfm">
<cfparam name="report" default="0">
<cfset datasource = "DMS">
<ul>

<cfif report is 1>
		To be done later... 
 </cfif> 
 
<cfif report is 3><!--- comment: groups by house --->
			<font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;"><A HREF="index2.cfm?id=19">BACK</A></font>
			
			<cfquery name="getusersgroups" datasource="#datasource#" dbtype="ODBC">
			SELECT distinct nhouse,users.username,groups.groupname,housename
			FROM users,groupassignments,groups,vw_houses
			WHERE users.employeeid = groupassignments.userid
				AND groupassignments.groupid = groups.groupid
				AND users.employeeid = vw_houses.nhouse
			Order By housename
			</cfquery>
			<br>
			<!--- comment: create the alph-link menu ---------------->
			<cfset firstchar = "">
			<cfset lastchar = "">
			<cfset firstchar2 = "">
			<cfset lastchar2 = "">
			<BR>
			<cfoutput query="getusersgroups">
				<cfset firstchar = Left(housename,1)>
				
				<cfif firstchar is not lastchar>
				<A HREF="/intranet/admin/security_group_report.cfm###UCase(firstchar)#">#UCase(firstchar)#</A>,
					<cfset lastchar = firstchar>
				</cfif>
			</cfoutput>
			<!--- comment: end alpha link menu ----------------------->
			<br>
			<table width="500">
			<cfoutput query="getusersgroups" group="nhouse">
			
			<tr BGCOLOR="##EAEAEA">
				<td width="100">
				<cfset firstchar2 = Left(housename,1)>
				
				<cfif firstchar2 is not lastchar2>
				 <a name=#UCase(firstchar2)#>
					<cfset lastchar2 = firstchar2>
				</cfif>
				
						<font color="Navy" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: xx-small; font-weight: bold;">#housename#<!--- #fname# #lname# ---></font>
				</td>
				<td>
					<font color="Purple" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: xx-small; font-weight: bold;">#username#</font>
				</td>
				<td align="center">
					<cfif firstchar2 is lastchar2>
						<font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: xx-small; font-weight: bold;"><A HREF="/intranet/admin/security_group_report.cfm##TOP"><img src="\intranet\pix\uparrow.gif" width="22" height="22" alt="" border="0" align="bottom"></A></font>
					</cfif>
				</td>
			</tr>
			<tr>
				<td height="7" colspan="3">
				
				</td>
			</tr>
			
			<cfoutput>	
			<tr>
				<td width="100">
					&nbsp;	
				</td>
				<td BGCOLOR="##F7F7F7" colspan="2">
				<font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: xx-small; font-weight: bold;">#groupname#</font>
				</td>
			</tr>
			</cfoutput>
			<tr>
				<td colspan="3">
					<br>
				</td>
			</tr>
			</cfoutput>
			
			</table>
		</cfif>
	
<cfif report is 2><!--- comment: groups to users--->
			<font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;"><A HREF="index2.cfm?id=19">BACK</A></font>
			
			<cfquery name="getusersgroups" datasource="#datasource#" dbtype="ODBC">
			SELECT distinct vw_employees.employee_ndx,vw_employees.fname,vw_employees.lname,users.username,groups.groupname
			FROM vw_employees,users,codeblocks,groupassignments,groups
			WHERE vw_employees.employee_ndx = users.employeeid 
				AND users.employeeid = groupassignments.userid
				AND groupassignments.groupid = groups.groupid 
				Order BY vw_employees.fname
			</cfquery>
			<br>
			<!--- comment: create the alph-link menu ---------------->
			<cfset firstchar = "">
			<cfset lastchar = "">
			<cfset firstchar2 = "">
			<cfset lastchar2 = "">
			<BR>
			<cfoutput query="getusersgroups">
				<cfset firstchar = Left(fname,1)>
				
				<cfif firstchar is not lastchar>
				<A HREF="/intranet/admin/security_group_report.cfm###UCase(firstchar)#">#UCase(firstchar)#</A>,
					<cfset lastchar = firstchar>
				</cfif>
			</cfoutput>
			<!--- comment: end alpha link menu ----------------------->
			
			<BR>
			<table width="500">
			<cfoutput query="getusersgroups" group="fname">
			
			<tr BGCOLOR="##EAEAEA">
				<td width="100">
			
				<cfset firstchar2 = Left(fname,1)>
				
				<cfif firstchar2 is not lastchar2>
				 <a name=#UCase(firstchar2)#>
					<cfset lastchar2 = firstchar2>
				</cfif>
			
				
						<font color="Navy" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: xx-small; font-weight: bold;">#fname# #lname#</font>
				</td>
				<td>
					<font color="Purple" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: xx-small; font-weight: bold;">#username#</font>
				</td>
				<td align="center">
					<cfif firstchar2 is lastchar2>
						<font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: xx-small; font-weight: bold;"><A HREF="/intranet/admin/security_group_report.cfm##TOP"><img src="\intranet\pix\uparrow.gif" width="22" height="22" alt="" border="0" align="bottom"></A></font>
					</cfif>
				</td>
			</tr>
			<tr>
				<td height="7" colspan="3">
				
				</td>
			</tr>
			
			<cfoutput>	
				<tr>
					<td width="100">
						&nbsp;	
					</td>
					<td BGCOLOR="##F7F7F7" colspan="2">
					<font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: xx-small; font-weight: bold;">#groupname#</font>
					</td>
				</tr>
			</cfoutput>
			<tr>
				<td colspan="3">
					<br>
				</td>
			</tr>
			</cfoutput>
		</table>
	</cfif>
	

</ul>
 <cfinclude template="/intranet/Footer.cfm"> 

