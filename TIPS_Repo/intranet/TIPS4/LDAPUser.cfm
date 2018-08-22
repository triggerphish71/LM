<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Untitled Document</title>
</head>

<body>
<cfset u='ldap'>
<cfset p='paulLDAP939'>
<CFSET DATASOURCE = "DMS">
<!--- <cfquery  name="qryPeople"  	DATASOURCE = "#datasource#">
select * from dbprod01.DMS.dbo.users
where employeeid in (3032,
3083,
3113,
3122,
3150,
3147,
3161,
3264,
3120,
3128,
3200,
4186,
4104,
3278,
3279,
3281,
3282,
3283,
3289,
4220,
3398,
3399,
4118,
4111,
4114,
3591,
4235,
4239,
4193,
4691,
4214,
4224,
4693,
4401,
4524,
4697,
4176,
4694,
4103,
4222,
4124,
4168)
</cfquery>
<cfloop query="qryPeople" > --->

			<CFLDAP ACTION="query" NAME="UserSearch" START="DC=alcco,DC=com" SCOPE="subtree" 
			ATTRIBUTES="givenName,sn,displayName,cn,dn,member,memberof,physicalDeliveryOfficeName,Description" 
			SERVER="CORPDC01" PORT="389"  FILTER="sAMAccountName=tsawyer" USERNAME="#u#" PASSWORD="#p#">
			
 

		<cfoutput>
	<!--- 	<br>	*** userSearch.displayName:<B>#qryPeople.UserName#</B><BR> --->
	 
			<cfdump var="#UserSearch#" label="UserSearch">
		</cfoutput>
<!--- </cfloop> --->
end
</body>
</html>
