<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Untitled Document</title>
</head>

<body>
<cfoutput>
<cfset u='ldap'>
<cfset p='paulLDAP939'>	

 <CFQUERY NAME='qHouses' DATASOURCE='TIPS4'>
	select h.ihouse_id, h.cname from house h  where h.dtrowdeleted is null  and h.ihouse_id not in (200)
  and h.iunitsavailable > 0 and h.bissandbox != 1
</CFQUERY>
<!--- <cfdump var="#qHouses#" label="qHouses"> --->
<!--- <cfloop query="qHouses"> --->

<!---   <cfset session.username = 'Addison House'>
   <cfset session.password = 'tips'> ---> 
 	<CFLDAP ACTION="query" NAME="UserSearch" START="DC=alcco,DC=com" SCOPE="subtree" 
		ATTRIBUTES="givenName,sn,displayName,cn,dn,company,member,memberof,physicalDeliveryOfficeName,Description,organization,userPrincipalName" 
		SERVER="CORPDC01" 
		PORT="389"  
		FILTER="sAMAccountName=Addison Place"  
		USERNAME="#u#" 
		PASSWORD="#p#">
#UserSearch.cn#	#UserSearch.userPrincipalName#<br />	
		<!--- </cfloop> --->
		END
	</cfoutput>
</body>
</html>
