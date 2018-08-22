<cfset datasource = "DMS">
<cfparam name="functiontype" default="0">


<!----------------------------------------ADD--------------------------------------------------------------->
<CFIF functiontype is "insert">
<!--- comment: Test for unique employee--->
<cfquery name="checkemployee" datasource="alcweb" dbtype="ODBC">
	exec check_employee '#fname#','#lname#'
</cfquery>

<cfif checkemployee.errorflag is 1>
	<cflocation url="error.cfm?id=1" addtoken="No">
</cfif>

<!--- comment: check for unique username--->
<cfquery name="checkuser" datasource="#DATASOURCE#" dbtype="ODBC">
	exec check_user '#username#'
</cfquery>
<!--- Test: 
<cfoutput>#checkuser.errorflag#</cfoutput> --->
<cfif checkuser.errorflag is 1>
	<cflocation url="error.cfm?id=2" addtoken="No">
</cfif>
<!------------------------employee entry---------------------------------->
		<cfquery name="insertemployee" datasource="ALCWeb" dbtype="ODBC">
		Insert into Employees(fname,lname,ndepartmentnumber,jobtitle,email,created_by_user_id,created_date)
		Values('#Trim(fname)#','#Trim(lname)#',#Trim(dept)#,'#Trim(jobtitle)#','#Trim(email)#',#session.userid#,'#dateFormat(Now(),"mm/dd/yy")#')
		</cfquery> 
		
		<cfquery name="getempid" datasource="#datasource#" dbtype="ODBC">
		Select employee_ndx
		From vw_employees
		Where fname = '#Trim(fname)#' AND lname = '#Trim(lname)#' AND email = '#Trim(email)#' AND jobtitle = '#Trim(jobtitle)#'
		</cfquery>
		
		<cfset passexpdate = DateFormat(DateAdd("d",60,Now()))>
		<CFQUERY name="insertuser" datasource="#datasource#" dbtype="ODBC">
			INSERT INTO users(USERNAME,PASSWORD,employeeid,passexpires,creationdate,expires,created_by_user_id)
			VALUES('#Trim(username)#','#Trim(password)#',#getempid.employee_Ndx#,'#Trim(passexpdate)#','#Trim(Dateformat(Now()))#','#Trim(userexpirationdate)#',#session.userid#)
		</CFQUERY>
		
		<cfquery name="addgroupassignment" datasource="#datasource#" dbtype="ODBC">
		Insert into groupassignments(groupid,userid)
		Values(3,#getempid.employee_ndx#)
		</cfquery>
		
		 <cfif isDefined("return")>
			<cflocation url="/intranet/logout.cfm" addtoken="No">
		<cfelse>
			<cflocation url="confirm.cfm?confirm=1&employeendx=#getempid.employee_Ndx#" addtoken="No">
		</cfif> 
		

<!------------------------------------UPDATE--------------------------------------------------------------------->
<CFELSEIF functiontype is "update">

		<cfparam name="userinfo" default="0">
		
			<cfif Intranetuser is 1 AND isDefined("form.usernamecheck") is "true">
				<cfquery name="updateuser" datasource="#datasource#" dbtype="ODBC">
				Update users
				Set username = '#Trim(username)#'
				<cfif IsDefined("password")>,Password = '#Trim(Password)#'</cfif>
				<cfif IsDefined("expirationdate")>,passexpires = '#Trim(dateformat(expirationdate,"mm/dd/yy"))#'</cfif>
				<cfif IsDefined("userexpirationdate")>,expires = '#Trim(dateformat(userexpirationdate,"mm/dd/yy"))#'</cfif>
				<CFIF IsDefined("expirationdate") and IsDefined("userexpirationdate") 
					and (expirationdate gte now() and userexpirationdate gte now() ) >
				,dtrowdeleted=null ,crowdeleteduser_id=null
				</CFIF>
				Where employeeid = #employeeid#
				</cfquery>
				
			<cfelseif Intranetuser is 1 AND isDefined("form.usernamecheck") is "false">
				<cfset passexpdate = DateFormat(DateAdd("d",60,Now()))>
				<CFQUERY name="insertuser" datasource="#datasource#" dbtype="ODBC">
					INSERT INTO users(USERNAME,PASSWORD,employeeid,passexpires,creationdate,expires)
					VALUES('#Trim(username)#','#Trim(password)#',#Trim(employeeid)#,'#Trim(passexpdate)#','#Trim(Dateformat(Now()))#','#Trim(userexpirationdate)#')
				</CFQUERY>
				
				<cfquery name="addgroupassignment" datasource="#datasource#" dbtype="ODBC">
				Insert into groupassignments(groupid,userid)
				Values(3,#employeeid#)
				</cfquery>
				
			<cfelseif Intranetuser is 2>
			<!---Comment: for when the user updates their password--->
				<cfquery name="updateuser" datasource="#datasource#" dbtype="ODBC">
				Update users
				Set username = '#Trim(username)#'
				<cfif IsDefined("password")>,Password = '#Trim(Password)#'</cfif>
				<cfif IsDefined("expirationdate")>,passexpires = '#Trim(dateformat(expirationdate,"mm/dd/yy"))#'</cfif>
				<cfif IsDefined("userexpirationdate")>,expires = '#Trim(dateformat(userexpirationdate,"mm/dd/yy"))#'</cfif>
				<CFIF IsDefined("expirationdate") and IsDefined("userexpirationdate") 
					and (expirationdate gte now() and userexpirationdate gte now() ) >
				,dtrowdeleted=null ,crowdeleteduser_id=null
				</CFIF>
				Where employeeid = #employeeid#
				</cfquery>
			<cflocation url="confirm.cfm?confirm=2" addtoken="No">
			</cfif>
				
				
				<cfquery name="updateemps" datasource="#datasource#" dbtype="ODBC">
				Update vw_employees
				Set fname = '#Trim(fname)#',
					lname = '#Trim(lname)#'
					<cfif email IS NOT "">,email = '#Trim(email)#'</cfif>
					<cfif dept IS NOT "">,ndepartmentnumber = #dept#</cfif>
					<cfif jobtitle IS NOT "">,jobtitle = '#Trim(jobtitle)#'</cfif>
				Where employee_ndx = #employeeid#
				</cfquery>
			
			<cflocation url="confirm.cfm?confirm=2" addtoken="No"> 
<!--------------------------------------------------DELETE--------------------------------------------------------------------->
	<CFELSEIF functiontype is "delete">
		
			<cfquery name="deleteemployee" datasource="#datasource#" dbtype="ODBC">
				Delete from vw_Employees Where employee_ndx = #employeeid#
			</cfquery>
			
			<cfquery name="deleterelationship" datasource="#datasource#" dbtype="ODBC">
				Delete from groupassignments Where userid = #employeeid#
			</cfquery> 
			
			<cfquery name="deleteuser" datasource="#datasource#" dbtype="ODBC">
				Delete from users Where employeeid = #employeeid#
			</cfquery>
		<cflocation url="confirm.cfm?confirm=3" addtoken="No">
	</CFIF>
