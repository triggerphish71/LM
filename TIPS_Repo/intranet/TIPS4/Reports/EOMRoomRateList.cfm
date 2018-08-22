<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Untitled Document</title>
</head>
<cfparam name="prompt1" default="">
<cfif IsDefined('url.prompt1')and url.prompt1 is not ''>
	<cfset url.prompt1 = '201509'>
<cfelseif  IsDefined('form.prompt1')and form.prompt1 is not ''>
	<cfset form.prompt1 = '201509'>
<cfelse>
	<cfset prompt1 = '201509'>
</cfif>
<CFQUERY NAME="HouseData" DATASOURCE="#APPLICATION.datasource#">
	SELECT	H.iHouse_ID,H.cName, H.cNumber,h.caddressLine1, h.caddressline2
	, h.ccity, h.cstatecode, h.czipcode
	,h.cPhoneNumber1
	, OA.cNumber as OPS, R.cNumber as Region
	,hl.dtCurrentTipsmonth
	FROM	House H
	Join 	Houselog hl on h.ihouse_id = hl.ihouse_id
	JOIN	OPSArea OA ON OA.iOPSArea_ID = H.iOPSArea_ID
	JOIN	Region R ON OA.iRegion_ID = R.iRegion_ID
	WHERE	H.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#	
</CFQUERY>
<cfquery name="spRentTable" DATASOURCE="#APPLICATION.datasource#">
		EXEC rw.sp_RentTable
			  @iHouse_ID =  #SESSION.qSelectedHouse.iHouse_ID#  , 
			@cPeriod =   '#prompt1#'  
</cfquery>
<!--- <cfdump var="#spRentTable#" label="spRentTable"> --->
<body>
<cfoutput>
<cfquery  name="qryRentTableAptID"  dbtype="query">
select distinct(iAptType_id) iAptType_id  from spRentTable  where iapttype_id is not null
</cfquery>  
<table>
<tr>
	<td>Unit</td>
	<td>Base</td>
	<td>1</td>
	<td>2</td>
	<td>3</td>	
	<td>4</td>
	<td>5</td>
	<td>6</td>	
</tr> 
<!--- <cfdump var="#qryRentTableAptID#" label="qryRentTableAptID"> --->
<cfloop  query="qryRentTableAptID">

<cfquery  name="qryRoomType" DATASOURCE="#APPLICATION.datasource#">
select * from apttype    
where iapttype_id = #qryRentTableAptID.iapttype_id#
</cfquery>

<cfquery  name="qryAcuity0" dbtype="query">
select totalrent from spRentTable  
where  acuity = '0' and iapttype_id = #qryRentTableAptID.iapttype_id#
</cfquery>
<cfquery  name="qryAcuity1" dbtype="query">
select totalrent from spRentTable  
where  acuity = '1' and iapttype_id = #qryRentTableAptID.iapttype_id#
</cfquery>
<cfquery  name="qryAcuity2" dbtype="query">
select totalrent from spRentTable  
where  acuity = '2' and IAPTTYPE_ID = #qryRentTableAptID.IAPTTYPE_ID#
</cfquery>
<cfquery  name="qryAcuity3" dbtype="query">
select totalrent from spRentTable  
where  acuity = '3' and iapttype_id = #qryRentTableAptID.iapttype_id#
</cfquery>
<cfquery  name="qryAcuity4" dbtype="query">
select totalrent from spRentTable  
where  acuity = '4' and iapttype_id = #qryRentTableAptID.iapttype_id#
</cfquery>
<cfquery  name="qryAcuity5" dbtype="query">
select totalrent from spRentTable  
where  acuity = '5' and iapttype_id =#qryRentTableAptID.iapttype_id#
</cfquery>
<cfquery  name="qryAcuity6" dbtype="query">
select totalrent from spRentTable  
where  acuity = '6' and iapttype_id = #qryRentTableAptID.iapttype_id#
</cfquery>

<tr>
	<td>#qryRoomType.cdescription#</td>
	<td>#qryAcuity0.totalrent#</td>
	<td>#qryAcuity1.totalrent#</td>
	<td>#qryAcuity2.totalrent#</td>
	<td>#qryAcuity3.totalrent#</td>	
	<td>#qryAcuity4.totalrent#</td>
	<td>#qryAcuity5.totalrent#</td>
	<td>#qryAcuity6.totalrent#</td>	
</tr>
</cfloop>
</table>
</cfoutput>
</body>
</html>
 
