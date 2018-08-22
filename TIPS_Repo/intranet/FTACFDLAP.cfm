<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Untitled Document</title>
</head>

<cfoutput>
<cfset u='DEVTIPS'>
<cfset p='!A7eburUDETu'>
<cfset session.EID = 'A8W999145'>
 
		<CFLDAP ACTION="query" 
		NAME="FindSubAccountA" 
		START="DC=alcco,DC=com" 
		SCOPE="subtree" 
		ATTRIBUTES="physicalDeliveryOfficeName,company,userPrincipalName" SERVER="#ADserver#" PORT="389"  FILTER="(&(objectCategory=CN=Person,CN=Schema,CN=Configuration,DC=alcco,DC=com)(physicalDeliveryOfficeName=#SESSION.EID#) (userPrincipalName=CindyWilliams@alcco.com))" 
		USERNAME="DEVTIPS" 
		PASSWORD="!A7eburUDETu" >

<br /><cfdump var="#FindSubAccountA#" label="FindSubAccountA">

 
	<CFLDAP ACTION="query" NAME="FindSubAccountB" START="DC=alcco,DC=com" SCOPE="subtree" 
			ATTRIBUTES="physicalDeliveryOfficeName,company,userPrincipalName" 
			SERVER="#ADserver#" 
			PORT="389"  
			FILTER="(&(objectCategory=CN=Person,CN=Schema,CN=Configuration,DC=alcco,DC=com)(sAMAccountName=CindyWilliams))" 
			USERNAME="DEVTIPS" 
			PASSWORD="!A7eburUDETu">
	
	 <br /> <cfdump var="#FindSubAccountB#" label="FindSubAccountB">
	 
			<CFLDAP ACTION="query" NAME="UserSearch" START="DC=alcco,DC=com" SCOPE="subtree" 
			ATTRIBUTES="givenName,sn,displayName,cn,dn,member,memberof,physicalDeliveryOfficeName,Description" 
			SERVER="CORPDC01" PORT="389"  FILTER="sAMAccountName=CindyWilliams" USERNAME="#u#" PASSWORD="#p#">	 
	
	 <br /><cfdump var="#UserSearch#" label="UserSearch">			
			
 </cfoutput>
	 <body>
</body>
</html>
