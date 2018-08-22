<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Load data in DMS tables</title>
</head>

<body> <cfoutput>
<cfquery name="data1" datasource="ALCWEB">
Select * from Emp_temp
</cfquery>

<cfloop query="data1">  
      <cfquery name="insertemployee" datasource="ALCWeb" dbtype="ODBC">
		Insert into Employees(fname,lname,ndepartmentnumber,jobtitle,email,created_by_user_id,created_date)
		Values('#Trim(data1.firstname)#','#Trim(data1.lastname)#',#Trim(data1.dept)#,'#Trim(data1.jobtitle)#','#Trim(data1.email)#',null,'#dateFormat(Now(),"mm/dd/yy")#')
		</cfquery> 
		
		<cfquery name="getempid" datasource="DMS" dbtype="ODBC">
		Select employee_ndx
		From vw_employees
		Where fname = '#Trim(data1.firstname)#' AND lname = '#Trim(data1.lastname)#' AND email = '#Trim(data1.email)#' AND jobtitle = '#Trim(data1.jobtitle)#'
		</cfquery>
		
		<!---<cfset passexpdate = DateFormat(DateAdd("d",60,Now()))>--->
		<CFQUERY name="insertuser" datasource="DMS" dbtype="ODBC">
			INSERT INTO users(USERNAME,PASSWORD,employeeid,passexpires,creationdate,expires,created_by_user_id)
			VALUES('#Trim(data1.username)#','#Trim(data1.password)#',#getempid.employee_Ndx#,'2020-12-31','#Trim(Dateformat(Now()))#','2020-12-31',null)
		</CFQUERY>
		
		<cfquery name="addgroupassignment" datasource="DMS" dbtype="ODBC">
		Insert into groupassignments(groupid,userid)
		Values(3,#getempid.employee_ndx#)
		</cfquery>

</cfloop>
</cfoutput>
</body>
</html>
