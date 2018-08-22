<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Untitled Document</title>
</head>
<cfquery name="house" datasource="#application.datasource#">
select * from house where dtrowdeleted is null and iunitsavailable > 0
</cfquery>
<body>
<table>
<cfoutput query="house">
<tr>
<td>#cname#</td>
<td>
<cfset thispath = ExpandPath("../../images/HouseImage/HouseImageNew/HouseImageNew/#Replace(cname, ' ', '', 'all')#_Addressonly_Medium.jpeg")>
<cfset thisdirectory = GetDirectoryFromPath(thispath)>
#thispath# <br />
#thisdirectory#<br />
<!---   <cfif FileExists(E:\inetpub\wwwroot\intranet\images\HouseImage\HouseImageNew\HouseImageNew\Replace(cname, ' ', '', 'all')_Addressonly_Medium.jpeg)>		
	<img src="../../images/HouseImage/HouseImageNew/HouseImageNew/#Replace(cname, ' ', '', 'all')#_Addressonly_Medium.jpeg" 
			 alt="#Replace(cName, ' ', '', 'all')#"    />
	<cfelse>not found #cname# ../../images/HouseImage/HouseImageNew/HouseImageNew/#Replace(cname, ' ', '', 'all')#_Addressonly_Medium.jpeg
	</cfif> --->
	<cfif Fileexists("#thispath#")>
	<img src="#thispath#" />
	 <cfelse>
	 where is it: #thispath#
	 </cfif>
</td>
</tr>

</cfoutput>
</table>
</body>
</html>
