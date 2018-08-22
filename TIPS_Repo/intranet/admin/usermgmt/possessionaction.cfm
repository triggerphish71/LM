<!--------------------------------------->
<!--- Programmer: Andy Leontovich     --->
<!--- File: admin/usermgmt/possessionreassignment.cfm  --->
<!--- Company: Maxim Group/ALC        --->
<!--- Date: November                  --->
<!--------------------------------------->
<cfset datasource = "DMS">

<!--- comment: The following queries are for the Content Possessions section of this page--->
<!--- comment: query employees--->
<cfquery name="updateemployees" datasource="ALCWeb" dbtype="ODBC">
UPDATE employees
SET  created_by_user_id = #employeendx#
WHERE created_by_user_id  = #contentownerid# 
</cfquery>

<!--- comment: Query users--->
<cfquery name="updateusers" datasource="#datasource#" dbtype="ODBC">
UPDATE users
SET created_by_user_id = #employeendx#
WHERE created_by_user_id = #contentownerid# 
</cfquery>

<!--- comment: Query Groups and assignments--->
<cfquery name="updategroups" datasource="#datasource#" dbtype="ODBC">
UPDATE groups
SET user_id = #employeendx#
WHERE user_id = #contentownerid# 
</cfquery>

<!--- comment: Query releases --->
<cfquery name="updatereleases" datasource="#datasource#" dbtype="ODBC">
UPDATE releases
SET postedby = #employeendx#
WHERE postedby = #contentownerid# 
</cfquery>

<!--- comment: Query mediainfo--->
<cfquery name="updatemedia" datasource="#datasource#" dbtype="ODBC">
UPDATE mediainfo
SET uploadedby = #employeendx#
WHERE uploadedby = #contentownerid# 
</cfquery>

<!--- comment: Query categories--->
<cfquery name="updatecategories" datasource="#datasource#" dbtype="ODBC">
UPDATE categories
SET user_id = #employeendx#
WHERE user_id = #contentownerid#
</cfquery>

<!--- comment: Query Joblistings--->
<cfquery name="updateJoblistings" datasource="#datasource#" dbtype="ODBC">
UPDATE joblistings
SET submittedby = #employeendx#
WHERE submittedby = #contentownerid# 
</cfquery>

<!--- comment: Query JobTOC--->
<cfquery name="updatejobtoc" datasource="#datasource#" dbtype="ODBC">
UPDATE jobtoc
SET user_id = #employeendx#
WHERE user_id = #contentownerid# 
</cfquery>

<html>
<head>
<script language="JavaScript1.2" type="text/javascript">
<!--
	opener.location.reload();
 	this.close();
//-->
</script>
</head>

<body>



</body>
</html>