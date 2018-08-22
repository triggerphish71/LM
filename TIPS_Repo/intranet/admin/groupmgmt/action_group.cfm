<cfset datasource = "DMS">
				
<!----------------------------------------ADD--------------------------------------------------------------->
<CFIF functiontype is "insert">
<cfparam name="systemgroup" default="0">
		
	<!------------------------group entry---------------------------------->
	<cfquery name="checkgroup" datasource="dms" dbtype="ODBC">
		exec check_group '#groupname#'
	</cfquery>
	
	<cfif checkgroup.errorflag is 1>
		<cflocation url="../error.cfm?errorid=2" addtoken="No">
	</cfif>
	
		<CFQUERY name="insertgroup" datasource="#datasource#" dbtype="ODBC">
			INSERT INTO groups(groupname,systemgroup,user_id,created_date)
			VALUES('#Trim(groupname)#',#systemgroup#,#session.userid#,'#DateFormat(Now(),"mm/dd/yy")#')
		</CFQUERY>
	<cflocation url="confirm.cfm?confirm=1" addtoken="No">
	
<!------------------------------------UPDATE--------------------------------------------------------------------->
	<CFELSEIF functiontype is "update">
		<cfparam name="systemgroup" default="0">
			<cfquery name="updategroup" datasource="#datasource#" dbtype="ODBC">
			Update groups
			Set groupname = '#Trim(groupname)#',
			systemgroup = #systemgroup#
			Where groupid = #groupid#
			</cfquery>
				<cflocation url="confirm.cfm?confirm=2" addtoken="No">
		

<!--------------------------------------------------DELETE--------------------------------------------------------------------->
	<CFELSEIF functiontype is "delete">
		
			<cfquery name="deletegroup" datasource="#datasource#" dbtype="ODBC">
				Delete from groups
				Where groupid = #groupid#
			</cfquery>
			
			<cfquery name="deleterelationship" datasource="#datasource#" dbtype="ODBC">
				Delete from groupassignments
				Where groupid = #groupid#
			</cfquery>

				
		
			<cflocation url="confirm.cfm?confirm=3" addtoken="No">
	</CFIF>
