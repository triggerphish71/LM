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
<cfquery name="qryTenantRosterReport" DATASOURCE="#APPLICATION.datasource#">
		EXEC rw.sp_Occupancy
			  @HouseNumber =   '#HouseData.cnumber#' , 
			@Period =   '#prompt1#'  
</cfquery>
<cfquery name="getTenconInfo" datasource="#application.datasource#">
	select t.cEmail as tenantEmail, c.cEmail as contactEmail, c.cPhoneNumber1 as contactPhone, cast(isnull(t.bIsPayer, 0) as char(1)) + cast(isnull(ltc.bIsPayer, 0) as char(1)) as bIsPayer,t.itenant_id
	FROM tenant t
	inner join LinkTenantContact ltc on t.iTenant_id = ltc.iTenant_ID
	inner join contact c on ltc.iContact_ID = c.iContact_Id
	where t.iHouse_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.qSelectedhouse.iHouse_ID#">
</cfquery>
<cfquery  name="qryOccupiedUnits" dbtype="query">
	select count (distinct(aptnumber)) as OccupiedUnits from qryTenantRosterReport
	where tenantid is not null
</cfquery>
<cfquery  name="qryMovedInResidents" dbtype="query">
	select count (distinct(tenantid)) as MovedInResidents from qryTenantRosterReport
	where tenantid is not null
</cfquery>
<cfquery  name="qryMovedOutCount" dbtype="query">
	select count (distinct(tenantid)) as movedoutcount from qryTenantRosterReport
	where tenantid is not null and tenantstatecode = 3
</cfquery>
<cfquery  name="qryOnRosterCount" dbtype="query"> 
	select count (distinct(tenantid)) as onRosterCount from qryTenantRosterReport
	where tenantid is not null  
</cfquery>
<cfquery  name="qryTotalUnitsCount" dbtype="query">
	select count (distinct(aptnumber)) as unitcount from qryTenantRosterReport 
</cfquery>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Untitled Document</title>
</head>

<body>

<cfsavecontent variable="theResults">
	<cfoutput>
		<table  width="100%" >
			<tr>
				<td style="font-family:Arial,Verdana,Helvetica; font-size:large; border-bottom: 1px solid black;">Contact ?</td>	
				<td style="font-family:Arial,Verdana,Helvetica; font-size:large; border-bottom: 1px solid black;">Unit</td>
				<!---<td style="width: 15%;font-size:xx-large; border-bottom: 1px solid black;">ResidentID</td>--->
				<td style="font-family:Arial,Verdana,Helvetica; font-size:large; border-bottom: 1px solid black;">Resident Name</td>
				<td style="font-family:Arial,Verdana,Helvetica; font-size:large; border-bottom: 1px solid black;">Status</td>
				<td style="font-family:Arial,Verdana,Helvetica; font-size:large; border-bottom: 1px solid black;">Move In Date</td>
				<td style="font-family:Arial,Verdana,Helvetica; font-size:large; border-bottom: 1px solid black;">Billing Name</td>
				<td style="font-family:Arial,Verdana,Helvetica; font-size:large; border-bottom: 1px solid black;">Phone</td>
				<td style="font-family:Arial,Verdana,Helvetica; font-size:large; border-bottom: 1px solid black;">Email</td>								
				<td style="font-family:Arial,Verdana,Helvetica; font-size:large; border-bottom: 1px solid black;">Notes</td>					
			</tr>		
			<cfloop query="qryTenantRosterReport">				
				<tr>
					<td width="1%"><input type="checkbox"></td>
					<td style="font-family:Arial,Verdana,Helvetica; font-size:small;">#AptNumber#</td>
					<!---<td style="width: 15%;">#Solomonkey#</td>---->
					<td style="font-family:Arial,Verdana,Helvetica; font-size:xx-small;">#TenantFName# #tenantLName#</td>
					<td style="font-family:Arial,Verdana,Helvetica; font-size:xx-small;">#cDescription#</td>
					<td style="font-family:Arial,Verdana,Helvetica; font-size:xx-small;">#dateformat(MoveIn, 'mm/dd/yyyy')#</td>
					<td style="font-family:Arial,Verdana,Helvetica; font-size:xx-small;">#cpayerName#</td>
					<td style="font-family:Arial,Verdana,Helvetica; font-size:xx-small;">#cPhoneNumber#</td>
					<td style="font-family:Arial,Verdana,Helvetica; font-size:xx-small;">#cEmail#</td>					
					<td>&nbsp;&nbsp;</td>
				</tr>
			</cfloop>
		</table>
		<table width="100%">	
			<tr>
				<td colspan="6"><hrwidth="100%"/></td>
			</tr>
			<tr>
				<td colspan="6" align="center">House Summary</td>
			</tr>
			<tr>
				<td colspan="2" style="font-size:medium">Occupied Units</td>
				<td>#qryOccupiedUnits.OccupiedUnits#</td>
				<td colspan="2">Moved Out/Not Closed Residents</td>
				<td><cfif qryMovedOutCount.movedoutcount is ''>0 <cfelse>#qryMovedOutCount.movedoutcount#</cfif></td>
			</tr>
			
			<tr>
				<td colspan="2">Moved In Residents:</td>
				<td>#qryMovedInResidents.MovedInResidents#</td>
				<td colspan="2">Number of Residents on Roster:</td>
				<td>#qryOnRosterCount.onRosterCount#</td>
			</tr>
			
			<tr>
				<td colspan="2">Total Units:</td>
				<td>#qryTotalUnitsCount.unitcount#</td>
				<td colspan="2">&nbsp;</td>
				<td>&nbsp;</td>
			</tr>
			
			<tr>
				<td colspan="6"><hr  width="100%"/></td>
			</tr>
		
		</table>
	</cfoutput>	
</cfsavecontent>

<cfdocument  format="PDF" orientation="portrait" margintop="2"   marginbottom="1" marginleft="0" marginright="0" fontembed="true">

	<cfdocumentitem type="header" evalAtPrint="true" >  

		<cfoutput> 
			<table width="100%">
				<tr>
					<td> <img src="../../images/Enlivant_logo.jpg"/></td>
					<td align="center">
					<h1 style="text-align:center; text-decoration:underline;">Resident Roster</h1>
					</td>					
				</tr>
				<tr>
					<td>
					<h3>#HouseData.cname#    <br />
					#HouseData.Caddressline1#    <br />
					#HouseData.cCity#, #HouseData.cstatecode#  #HouseData.czipcode#<br />
					(#left(Housedata.cphonenumber1,3)#) 					#mid(Housedata.cphonenumber1,4,3)#-#right(Housedata.cphonenumber1,4)#</h2>
					</td>
					<td align="center">
				<h2 style="text-align:center; ">Period:					
					<cfif right(prompt1,2) is 01>
					January #left(prompt1,4)#
					<cfelseif right(prompt1,2) is 02>
					February #left(prompt1,4)#				
					<cfelseif right(prompt1,2) is 03>
					March #left(prompt1,4)#
					<cfelseif right(prompt1,2) is 04>
					April #left(prompt1,4)#				
					<cfelseif right(prompt1,2) is 05>
					May #left(prompt1,4)#				
					<cfelseif right(prompt1,2) is 06>
					June #left(prompt1,4)#
					<cfelseif right(prompt1,2) is 07>
					July #left(prompt1,4)#
					<cfelseif right(prompt1,2) is 08>
					August #left(prompt1,4)#				
					<cfelseif right(prompt1,2) is 09>
					September #left(prompt1,4)#
					<cfelseif right(prompt1,2) is 10>
					October #left(prompt1,4)#				
					<cfelseif right(prompt1,2) is 11>
					November #left(prompt1,4)#
					<cfelseif right(prompt1,2) is 12>
					December #left(prompt1,4)#
					</cfif>
					<br />(#dateformat(qryTenantRosterReport.dtCompare, 'mm/dd/yyyy')#)
					</h3>
					</td>					
				</tr>				
			</table>		
		</cfoutput>	
	</cfdocumentitem> 
	<cfoutput>
		#theResults#
	</cfoutput>



 	<cfdocumentitem  type="footer" evalAtPrint="true">
		<cfoutput>
			Page: #cfdocument.currentpagenumber# of #cfdocument.totalpagecount#
			<cfif #cfdocument.currentpagenumber# is #cfdocument.totalpagecount#><br />			
	Enlivant&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Printed: #dateformat(now(), 'mm/dd/yyyy')#&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	ResidentRoster.cfm
			</cfif>
		</cfoutput>
	</cfdocumentitem>

 	<cfoutput>  	
		<cfheader name="Content-Disposition"   
 		value="attachment;filename=ResidentRoster-#HouseData.cname#-#prompt1#.pdf"> 
	</cfoutput>			
	
</cfdocument>

</body>
</html>
