<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Untitled Document</title>
</head>
<cfquery name="qryCharge" DATASOURCE="#APPLICATION.datasource#">
select c.*,len(c.cdescription),  sl.csleveltypeset,h.cname as 'House'
 
 ,case when (len(c.cdescription) = 34) then
    ((  cast(substring(c.cdescription, 27,1) as int)  * 1.79) + 84)   
    when   (len(c.cdescription) = 35)  then
     (( cast(substring(c.cdescription, 27,2) as int)  * 1.79) + 84)   
   when len(c.cdescription) = 36  then
     (( cast(substring(c.cdescription, 27,3) as int) * 1.79) + 84)   
     end       
       newamount
from charges c
join chargetype ct on (ct.ichargetype_id = c.ichargetype_id and ct.dtrowdeleted is null)
and ct.bSLevelType_ID is not null and ct.bisdaily is not null
and getdate() between c.dteffectivestart and c.dteffectiveend
 
join sleveltype sl on sl.isleveltype_id = c.isleveltype_id and sl.dtrowdeleted is null
join house h on h.ihouse_id = c.ihouse_id 
and c.ihouse_id = 32
where c.dtrowdeleted is null  and sl.csleveltypeset = 11
and cchargeset = '2012Jan'
order by c.mamount	
</cfquery>

<!--- 32 sylvan --->
<!--- 25 warren --->
	<body>
		<cfoutput query="qryCharge">
			<cfif find('Level 6 +' , CDESCRIPTION)>Found
<!--- 				<cfquery name="updRoomChg" DATASOURCE="#APPLICATION.datasource#">
					update charges
					set mamount = #newamount#
					where icharge_id = #icharge_id#
					and ichargetype_ID = #ichargetype_ID#
					and IHOUSE_ID = #IHOUSE_ID#
					and  CCHARGESET  = '#CCHARGESET#'
				</cfquery>   ---> 
				#icharge_id# #ichargetype_ID# #IHOUSE_ID# #CCHARGESET#  #CDESCRIPTION#  #mamount#  #newamount#  #House# <br  />
			</cfif>
		</cfoutput>
			Done 
	</body>
</html>
