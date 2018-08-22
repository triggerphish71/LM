<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Untitled Document</title>
</head>
<cfoutput>
<cfset u='DEVTIPS'>
<cfset p='!A7eburUDETu'>	
<cfquery name="qryemp"  datasource="DMS">
select * from  alcweb.[dbo].[Employees] emp
left join dms.[dbo].[users] u on emp.[Employee_Ndx] = u.employeeid

where emp.jobtitle = 'ED' or emp.jobtitle = 'Executive Director'
</cfquery>
<body>

<cfloop query="qryemp">
#username# - #Fname# #Lname# #jobtitle#<br />
 	<CFLDAP ACTION="query" NAME="UserSearch" START="DC=alcco,DC=com" SCOPE="subtree" 
		ATTRIBUTES="givenName,sn,displayName,cn,dn,company,member,memberof,physicalDeliveryOfficeName,Description,organization,userPrincipalName" 
		SERVER="CORPDC01" 
		PORT="389"  
		FILTER="sAMAccountName=#username#"  
		USERNAME="#u#" 
		PASSWORD="#p#">
		#UserSearch.givenName#,#UserSearch.memberof# <br />
<CFSET altGroupList= 
REReplaceNoCase(userSearch.MemberOf, ",DC=alcco,DC=Com,|,DC=alcco,DC=Com", "**", "all")>
 
<CFIF FindNoCase('-ADMIN', altGroupList, 1) GT 0> 
<B>ADMIN</B><BR> 
</CFIF>

<CFIF FindNoCase('RDQCSSurveyHouse', altGroupList, 1) GT 0> 
<B>RDQCSSurveyHouse</B><BR> 
</CFIF>

<CFIF FindNoCase('RDQCSSurveyAdmin', altGroupList, 1) GT 0> 
<B>RDQCSSurveyAdmin</B><BR> 
</CFIF>

<CFIF FindNoCase('_ALC All Rgnl Dir of Qual Clin Serv', altGroupList, 1) GT 0> 
<B>_ALC All Rgnl Dir of Qual Clin Serv</B><BR> 
</CFIF>

<CFIF FindNoCase('_ALC IT', altGroupList, 1) GT 0> 
<B>_ALC IT</B><BR> 
</CFIF>

<CFIF FindNoCase('Support-IT', altGroupList, 1) GT 0> 
<B>Support-IT</B><BR> 
</CFIF>

<CFIF FindNoCase('RDQCSSurveyUser', altGroupList, 1) GT 0> 
<B>RDQCSSurveyUser</B><BR> 
</CFIF>

<CFIF FindNoCase('QI and Clinical Services', altGroupList, 1) GT 0> 
<B>QI and Clinical Services</B><BR> 
</CFIF>
<CFIF FindNoCase('RD Access Groups', altGroupList, 1) GT 0> 
<B>RD Access Groups</B><BR> 
</CFIF>

 <br />
</cfloop>
 
</body>
</cfoutput>
</html>
