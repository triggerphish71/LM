<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Untitled Document</title>
</head>
<cfquery name="qryEmployee" datasource= "#APPLICATION.datasource#">
select * from  alcweb.[dbo].[Employees] emp
left join dms.[dbo].[users] u on emp.[Employee_Ndx] = u.employeeid
where emp.jobtitle = 'ED' or emp.jobtitle = 'Executive Director'
order by username
</cfquery>
<body>
<cfoutput>
<cfloop query="qryEmployee">
 
 		<cfquery name="adQueryResult2" datasource="Survey">
			EXECUTE sel_Access '#username#';
		</cfquery>	 
 
    
#username#  <cfif Isdefined('adQueryResult.n_AccessTo')>#adQueryResult.n_AccessTo#</cfif>  <br />
</cfloop>
</cfoutput>
</body>
</html>
