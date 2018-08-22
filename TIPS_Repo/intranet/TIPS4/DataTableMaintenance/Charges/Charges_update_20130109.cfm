<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Untitled Document</title>
</head>
<cftransaction>
<cfquery name="extrMamount" DATASOURCE='#APPLICATION.datasource#'>
select Ochg.mamount thisamount ,Ochg.ihouse_id,Ochg.ichargetype_id,Ochg.cdescription , Ochg.cchargeset
from  charges Ochg

where 
 Ochg.ichargetype_id=91  and Ochg.cchargeset='2013Jan'
  and Ochg.crowstartuser_id = 'Jan2013 SFarmer 2012-11-30'   
  and Ochg.ihouse_id in (212)
 
 order by Ochg.ihouse_id, Ochg.mamount 
</cfquery>
<cfset updcount = 0>
<cfoutput>
	<cfloop query="extrMamount">
<!---    <cfquery name="updchg" DATASOURCE='#APPLICATION.datasource#'> 
		update charges   ---> 
		set mamount = #thisamount#
		where charges.ihouse_id =  #ihouse_id# 
			 and charges.ichargetype_id = #ichargetype_id#  
			 	and charges.cchargeset= '#cchargeset#'
					and charges.cdescription = '#cdescription#'
					and  charges.crowstartuser_id  = 'SFarmer 15 ManualInsert'
		    </cfquery> 
	<cfset updcount = updcount + 1>
	</cfloop>
	DONE: #updcount#
<!---  </cfoutput>  --->

</cftransaction>
<body>
</body>
</html>
