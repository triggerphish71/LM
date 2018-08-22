


<!--- =============================================================================================
Retrieves information for the all listed users
============================================================================================= --->
<CFQUERY NAME = "USERS" DATASOURCE = "DMS">
	SELECT u.employeeid, e.employee_ndx, e.fname, e.lname
	FROM USERS	u
	JOIN ALCWEB.dbo.Employees E ON u.employeeid = e.employee_ndx
	ORDER BY e. LName
</CFQUERY>