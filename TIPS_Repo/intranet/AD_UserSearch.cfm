<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Untitled Document</title>
</head>
<CFOUTPUT>
<CFSET DATASOURCE = "DMS">
<cfset u='DEVTIPS'>
<cfset p='!A7eburUDETu'>
<cfset username='cmiller'>

<cfdump  var="#username#" label="username">

<CFLDAP ACTION="query" NAME="UserSearch" START="DC=alcco,DC=com" SCOPE="subtree" 
ATTRIBUTES="givenName,sn,displayName,cn,dn,member,memberof,physicalDeliveryOfficeName,Description,userPrincipalName" 
SERVER="CORPDC01" PORT="389"  FILTER="sAMAccountName=#UserName#" USERNAME="#u#" PASSWORD="#p#">
<cfdump var="#UserSearch#" label="UserSearch">

 <CFLDAP ACTION="query" NAME="FindSubAccountA" START="DC=alcco,DC=com" SCOPE="subtree" ATTRIBUTES="physicalDeliveryOfficeName,company,userPrincipalName" SERVER="#ADserver#" PORT="389"  FILTER="(&(objectCategory=CN=Person,CN=Schema,CN=Configuration,DC=alcco,DC=com)
 (physicalDeliveryOfficeName=#UserSearch.physicalDeliveryOfficeName#) 
 (userPrincipalName=#UserName#@alcco.com))" USERNAME="ldap" PASSWORD="paulLDAP939"> 
 <cfdump var="#FindSubAccountA#" label="FindSubAccountA">
 
 <CFLDAP ACTION="query" NAME="FindSubAccountB" START="DC=alcco,DC=com" SCOPE="subtree" ATTRIBUTES="physicalDeliveryOfficeName,company,Name" SERVER="#ADserver#" PORT="389"  FILTER="(&(objectCategory=CN=Person,CN=Schema,CN=Configuration,DC=alcco,DC=com)(physicalDeliveryOfficeName=#SESSION.EID#))" USERNAME="ldap" PASSWORD="paulLDAP939">
 <cfdump var="#FindSubAccountB#" label="FindSubAccountB">	
 	
 <cfdump var="#session#" label="session">
 </CFOUTPUT>
 
 <cfinclude template="ADEmailTest.cfm">
<body>
</body>
</html>
