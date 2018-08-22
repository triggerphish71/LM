<!----------------------------------------------------------------------------------------------
| DESCRIPTION - act_SubmitNOID.cfm                                                             |
|----------------------------------------------------------------------------------------------|
| Records all the Tenants			 	                                                       |
|----------------------------------------------------------------------------------------------|
| STORED PROCEDURES                                                                            |
|----------------------------------------------------------------------------------------------|
|  none                                                                                        |
|----------------------------------------------------------------------------------------------|
| INCLUDES                                                                                     |
|----------------------------------------------------------------------------------------------|
|   none                                                                                       |
|----------------------------------------------------------------------------------------------|
| HISTORY                                                                                      |
| Called by act_GetNOID.cfm														         	   |     
|----------------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                        |
|------------|------------|--------------------------------------------------------------------|
| mlaw       | 10/11/2007 | 																   | 
----------------------------------------------------------------------------------------------->

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<title>Submit Page</title>
<style type="text/css">
<!--
body,td,th {
	font-family: Arial, Helvetica, sans-serif;
	font-size: 12px;
}
-->
</style>

<style type="text/css">
<!--
.style1 {
	font-family: Arial, Helvetica, sans-serif;
	font-weight: bold;
}
-->
</style>

<style type="text/css">
<!--
.style2 {
	font-family: Arial, Helvetica, sans-serif;
	font-weight: bold;
}
-->
</style>
</head>
<body>

	<!--- Create an Array --->
	<cfset TenantArray = ArrayNew(1)>
	<!--- Create a loop --->
	<cfloop list="#csolomonkey#" index="loopvar">
		<!--- create the tenant structure --->
		<cfset TenantStruct = StructNew()>
		<!--- set the tenant structure members --->
		<cfset TenantStruct.cSolomonkey = "">
		<!---<cfset TenantStruct.Period = form["Period_#loopvar#"]>--->
		<cfset TenantStruct.FullName = "">
		<cfset TenantStruct.Total = "">
		<cfset TenantStruct.thirdletter = "">
		<cfset TenantStruct.checkedthirdletter = "">
		<cfset TenantStruct.issuedate = "">
		<cfset TenantStruct.exemptdate = "">
		<cfset TenantStruct.notes = "">
		<cfset TenantStruct.delete = "">
		<cfset TenantStruct.checkeddelete = "">
		<cfset TenantStruct.cSolomonkey = loopvar>
		
		<cfif structKeyExists(form,'issuedate_#loopvar#')>
			<cfset TenantStruct.issuedate = form["issuedate_#loopvar#"]>
		</cfif>
		<cfif structKeyExists(form,'thirdletter_#loopvar#')>
			<cfset TenantStruct.thirdletter = form["thirdletter_#loopvar#"]>
			<cfif val(TenantStruct.thirdletter)>
				<cfset TenantStruct.checkedthirdletter = 1>
			<cfelse>
				<cfset TenantStruct.checkedthirdletter = 0>
			</cfif>
		</cfif>
		<cfif structKeyExists(form,'notes_#loopvar#')>
			<cfset TenantStruct.notes = form["notes_#loopvar#"]>
		</cfif>
		<cfif structKeyExists(form,'delete_#loopvar#')>
			<cfset TenantStruct.delete = form["delete_#loopvar#"]>
			<cfif val(TenantStruct.delete)>
				<cfset TenantStruct.checkeddelete = 1>
			<cfelse>
				<cfset TenantStruct.checkeddelete = 0>
			</cfif>
		</cfif>
		<cfif structKeyExists(form,'exemptdate_#loopvar#')>
			<cfset TenantStruct.exemptdate = form["exemptdate_#loopvar#"]>
		</cfif>
			
		<cfoutput>
			<!---#TenantStruct.exemptdate#
			#TenantStruct.Period#
			#TenantStruct.cSolomonkey#<p>
			#TenantStruct.checkedthirdletter#<p>
			#TenantStruct.issuedate#<p>
			#TenantStruct.notes# <p>
			#TenantStruct.checkeddelete#--->
		</cfoutput>
		<!--- Update TenantCollection List --->
		<!--- if there is no issuedate, that means letter3 is going to issued --->
		<cfquery name="UpdateList" datasource="#application.datasource#">
			update 
				TenantCollectionList
			set 
				dtissue = '#TenantStruct.issuedate#' 
				,
				cNotes = '#TenantStruct.notes#' 
				,
				<cfif #TenantStruct.checkeddelete# eq 1> 
					<cfif #form.Stage# neq 3>
						dtrowdeleted = getdate() 
					<cfelse>
						dtexempt = '#TenantStruct.exemptdate#' 
					</cfif>
				<cfelse>
					dtrowdeleted = NULL
					, 
					dtexempt = NULL
				</cfif>
				,
				<cfif #TenantStruct.checkedthirdletter# eq 1> bIsLetterSent = 1 <cfelse>bIsLetterSent = 0 </cfif>
			where
				dtPeriod = #form.Period#
			and
				cSolomonkey = '#TenantStruct.cSolomonkey#'
			and
				istage = #form.Stage#
			and
				dtrowdeleted is NULL
		</cfquery>
	</cfloop>
	
	<p class="style1">	
		Data have been updated. 
	</p>
	<cfif ListFindNoCase(session.groupid, 240, ",") gt 0> 
		<p class="style1">  
			<a href="dsp_Main.cfm">
				Collection Letters Generator
			</a>
		</p>	  
	</cfif>
	<p class="style2">  
		<a href="dsp_NOIDMain.cfm">
			Back
		</a>
	</p>	  
</body>
</html>
