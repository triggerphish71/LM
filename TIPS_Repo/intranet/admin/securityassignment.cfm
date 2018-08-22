<cfset datasource = "DMS">

<!--- This page accomodates employee to Groups and codeblocks to groups --->
<cfparam name="formfunction" default="0">
<cfparam name="form.function" default="#formfunction#">
<cfparam name="employee_ndx" default="0">
<cfparam name="assignmentedit" default="0">
<cfparam name="featureid" default="0">

<cfif IsDefined("url.function")>
	<cfset form.function = url.function>
</cfif> 

<cfif IsDefined("url.userid")>
	<cfset form.employee_ndx = url.userid>
</cfif>

<cfif form.function is 1>
	
	<cfquery name="getusers" datasource="#datasource#" dbtype="ODBC">
	Select username,employeeid
	From users
	Order by username
	</cfquery>
	

	<cfquery name="getassignments" datasource="#datasource#" dbtype="ODBC">
	Select groupassignments.groupid,groupname
	From groupassignments,groups
	Where 0=0 and <cfif isDefined("form.employee_ndx")>userid = #form.employee_ndx# AND</cfif> groupassignments.groupid = groups.groupid
	ORDER BY Groupname
	</cfquery>


	<cfif getassignments.recordcount is not 0>
		<cfset right = Valuelist(getassignments.groupname)>
		<cfset right_values = Valuelist(getassignments.groupid)>
		<cfset assignmentedit = 1>
	<cfelse> 
		<cfset right = "">
		<cfset right_values =  "">
	</cfif> 
	
<cfelse>
	<cfquery name="getsection" datasource="#datasource#" dbtype="ODBC">
	Select distinct uniqueid,sectionname
	From codeblocks
	Order by sectionname
	</cfquery>
	
	<cfquery name="getassignments" datasource="#datasource#" dbtype="ODBC">
	Select groupassignments.groupid,groupname
	From groupassignments,groups
	Where uniquecodeblockid = #featureid# AND groupassignments.groupid = groups.groupid
	</cfquery>
	
	<cfif getsection.recordcount is not 0>
		<cfset right = Valuelist(getassignments.groupname)>
		<cfset right_values = Valuelist(getassignments.groupid)>
		<cfset assignmentedit = 2>
	<cfelse> 
		<cfset right = "">
		<cfset right_values =  "">
	</cfif> 
</cfif>

<cfquery name="getgroups" datasource="#datasource#" dbtype="ODBC">
Select *
From Groups
Where 0=0 <cfif IsDefined("getassignments.groupid") AND getassignments.recordcount is not 0>and groupid NOT IN (#valuelist(getassignments.groupid)#)</cfif>
and groupid not in (4,223,235,222,200,201,202,203,204,205,209,210,211,212,213,214
,194,195,196,197,198,221
,219,218,220,224,207,208,229,188,189,190,191,233,231,227,234,226,225)
Order By systemgroup, case when len(groupname) > 2 then groupname else cast(len(groupname) as char(50)) end
</cfquery>

<cfset left = Valuelist(getgroups.groupname)>
<cfset left_values = Valuelist(getgroups.groupid)>

 <cfinclude template="/intranet/header.cfm"> 


<ul>
<table width="550" cellspacing="2">
<tr BGCOLOR="#336666">
<td>
	&nbsp;<font color="White" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: small; font-weight: bold;">Security Assignment for <cfif form.function is 1>Users<cfelse>Site Features</cfif></font>
</td>
</tr>

<form action="securityassignment.cfm" method="post" name="nameform" id="nameform">
<tr BGCOLOR="#f7f7f7">
	<td>&nbsp;<font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Select  <cfif form.function is 1>a User:<cfelse>a Site Feature:</cfif></font>
	<cfif form.function is 1>
		<cfif isDefined("form.employee_ndx")>
			<cfquery name="getemps2" datasource="#datasource#" dbtype="ODBC">
			Select employee_ndx,fname,lname
			From vw_employees
			Where employee_ndx = #form.employee_ndx#
			Order by lname
			</cfquery>
		</cfif>
		
		<input type="hidden" name="function" value="1">
		
		<select name="employee_ndx">
			<cfif isDefined("form.employee_ndx")>
				<cfoutput query="getemps2"><option value="#employee_ndx#" >#lname#, #fname#</option></cfoutput>
				<option value="" >______________________</option>
				<cfoutput query="getusers"><option value="#employeeid#" >#username#</option></cfoutput>
			<cfelse>
				<option value="" >Choose...</option>
				<cfoutput query="getusers"><option value="#employeeid#" >#username#</option></cfoutput>
			</cfif>

			</select>
			&nbsp;&nbsp;
			<input type="submit" name="submit" value="Select">
			<input type="hidden" name="selectfunction" value="1">
		<cfelse>
		
		<cfif isDefined("form.featureid")>
			<cfquery name="getsection2" datasource="#datasource#" dbtype="ODBC">
			Select distinct uniqueid,sectionname
			From codeblocks
			Where uniqueid = #form.featureid#
			</cfquery>
		</cfif>
		<select name="featureid">
			<cfif isDefined("form.featureid")>
				<cfoutput query="getsection2"><option value="#uniqueid#">#sectionname#</option></cfoutput>
				<option value="" >______________________</option>
				<cfset uniquesection = 0>
				<cfoutput query="getsection">
				<cfif uniquesection is not sectionname>
					<option value="#uniqueid#" >#sectionname#</option>
				</cfif>
				<cfset uniquesection = sectionname>
			</cfoutput>
			<cfelse>
				<option value="" >Choose...</option>
				<cfoutput query="getsection"><option value="#uniqueid#" >#sectionname#</option></cfoutput>
			</cfif>

		</select>
			&nbsp;&nbsp;
			<input type="submit" name="submit" value="Select">
		<input type="hidden" name="selectfunction" value="2">
		</cfif>
	</td>
</tr>
</form>

<cfif isDefined("form.employee_ndx") OR isDefined("form.featureid")>
	
	<form name="myForm" action="securityassignment.cfm" method="post">
	<cfoutput>
		<input type="hidden" name="formfunction" value="#form.function#">
		<cfif isDefined("form.employee_ndx")>
			<input type="hidden" name="employee_ndx" value="#form.employee_ndx#">
		<cfelse>
			<input type="hidden" name="featureid" value="#form.featureid#">
		</cfif>
	</cfoutput>
	<tr BGCOLOR="#f7f7f7">
		<td>
			<CF_CrossSelect
				left_name="left_select"
				right_name="right_select"
				textright="#right#"
				valuesright="#right_values#"
				textleft="#left#"
				valuesleft="#left_values#"
				width="250"
				sizeleft="10"
				sizeright="10"
				formname="myForm"
				headleft="Current Groups"
				headright="Assigned Groups"
				headfont="verdana,arial"
				headsize="2"
				headbold="yes"
				cross_buttonwidth="25"
				button_moveleft="<"
				button_moveleft_all="<<"
				button_moveright=">"
				button_moveright_all=">>"
				quotedlist="no"
				returntext="yes"
				onchange="GotChange();"
			>
		</td>
	</tr>
	<tr BGCOLOR="#eaeaea">
		<td align=center>
			<input type="submit" name="go" value="Submit Assignments" disabled>
		</td>
	</tr>
	<cfif isdefined("form.go")>
		<cfif formfunction is 1>
	<!--- wipe out what is there and insert the new set --->
			<cfquery name="deleteassign" datasource="#datasource#" dbtype="ODBC">
				Delete From groupassignments
				Where userid = #form.employee_ndx#
			</cfquery>
	
			<cfloop index="index1" list="#form.right_select#">
				<cfquery name="foo" datasource="#datasource#" dbtype="ODBC">
					INSERT INTO groupassignments(groupid,userid)
					VALUES(#index1#,#employee_ndx#)
				</cfquery>
			</cfloop>
			<cflocation url="confirm.cfm?previewcode=1" addtoken="No">
		
		<cfelse>
		
			<cfquery name="deleteassign" datasource="#datasource#" dbtype="ODBC">
				Delete From groupassignments
				Where uniquecodeblockid = #featureid#
			</cfquery>
			
			<cfloop index="index1" list="#form.right_select#">
				 <cfquery name="foo" datasource="#datasource#" dbtype="ODBC">
					INSERT INTO groupassignments(groupid,uniquecodeblockid)
					VALUES(#index1#,#featureid#)
				</cfquery>
			</cfloop>
			<cflocation url="confirm.cfm?previewcode=6" addtoken="No">
		</cfif>	
			
	</cfif>
	</form>
</cfif>
</table></ul>


<script language="javascript">
	function GotChange(j){
		document.forms[1].go.disabled = false;
	}
</script>

<cfinclude template="/intranet/footer.cfm">

