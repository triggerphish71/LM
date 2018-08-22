<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Untitled Document</title>
</head>
<cfquery name="resdentlist" DATASOURCE="#APPLICATION.datasource#">
select   t.cSolomonKey,t.itenant_id, h.cname as 'House',t.cSolomonKey,
 t.cFirstName + ' ' +  t.cLastName  as Name  
 
from tenant t
	join tenantstate ts on t.itenant_id = ts.itenant_id and ts.itenantstatecode_id = 2
	join house h on t.ihouse_id = h.ihouse_id and t.ihouse_id <> 200
	  join  linktenantcontact ltc on  t.itenant_id  = ltc.itenant_id and ltc.dtRowDeleted is null
			and (ltc.bispayer = 1 or  ltc.bIsGuarantorAgreement = 1)
	order by House, t.csolomonkey


</cfquery>
 
<body>
<table>
	<cfoutput query="resdentlist">
	<tr>
		<td>#cSolomonKey#</td>
		<td>#House#</td>
		<td>#Name#</td>
		<cfquery name="contactlist" datasource="#APPLICATION.datasource#">
		 select c.cfirstname, c.clastname, ltc.bispayer, ltc.bIsGuarantorAgreement 
		 from  linktenantcontact ltc 
			
			join contact c on ltc.iContact_ID = c.icontact_id and c.dtRowDeleted is null
			where  #itenant_id# = ltc.itenant_id and ltc.dtRowDeleted is null
			and (ltc.bispayer = 1 or  ltc.bIsGuarantorAgreement = 1)
			order by ltc.bispayer
			 
		</cfquery>
		<cfloop query="contactlist">
			<td>#cfirstname#  #clastname#, <cfif   #bispayer# is 1>Payor</cfif>, <cfif #bIsGuarantorAgreement# is 1>Guarantor</cfif></td> 
		</cfloop>
		</tr>
	</cfoutput>
</table>
</body>
</html>
