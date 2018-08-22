<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<!--- 
|Sfarmer     |02/16/2016  | Report change to Coldfusion CFDocument PDF from Crystal Reports    |
 --->
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>EOMSummary.cfm</title>
</head>
<cfparam name="prompt1" default="">
<cfif IsDefined('url.prompt1')and url.prompt1 is not ''>
	<cfset prompt1 = url.prompt1 >
<cfelseif  IsDefined('form.prompt1')and form.prompt1 is not ''>
	<cfset prompt1 = form.prompt1>
</cfif>

<cfset totalPrivatePay    = 0>
<cfset totalTotalCharges  = 0>
<cfset totalResidentCare  = 0>
<cfset totalCoPay         = 0>
<cfset totalStateMed      = 0>
<cfset totalOthertotal    = 0>
<cfset totalStdRate   	  = 0>
<cfset totalCurrentRent   = 0>
<cfset medicaidcount      = 0> 

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
 
<cfquery name="spEOMSummary" DATASOURCE="#APPLICATION.datasource#">
		EXEC rw.sp_EoMSummary
			  @HouseNumber =   '#HouseData.cnumber#' , 
			@Period =   '#prompt1#'  
</cfquery>

<cfquery name="spEoMSummaryExceptions" DATASOURCE="#APPLICATION.datasource#">
		EXEC rw.sp_EoMSummaryExceptions
			  @v_HouseID =    #spEOMSummary.HouseID#  , 
			@v_Period =   '#prompt1#'  
</cfquery>

<cfquery name="spRentTable" DATASOURCE="#APPLICATION.datasource#">
		EXEC rw.sp_RentTable
			  @iHouse_ID =  #SESSION.qSelectedHouse.iHouse_ID#  , 
			@cPeriod =   '#prompt1#'   
</cfquery>
<body>
<cfquery  name="sumResidentCare" dbtype="query"  >
select Sum ( ResidentCare) as ResidentCare from spEOMSummary
</cfquery>
<cfquery  name="sumPrivatePay" dbtype="query"  >
select Sum ( PrivatePay ) as PrivatePay from spEOMSummary 
</cfquery>
<cfquery  name="sumCoPay" dbtype="query"  >
select  Sum ( CoPay)  as CoPay from spEOMSummary
</cfquery>
<cfquery  name="sumStateMed" dbtype="query"  >
select Sum  (  StateMed ) as StateMed from spEOMSummary
</cfquery>
<cfquery  name="sumOther" dbtype="query"  >
select   Sum ( Other )  as Other from spEOMSummary
</cfquery>
<cfquery  name="sumSPoints" dbtype="query"  >
select   Sum ( SPoints ) as Spoints from spEOMSummary
</cfquery>
<cfquery  name="sumBeautyShop" dbtype="query"  >
select   Sum ( BeautyShop ) as BeautyShop from spEOMSummary
</cfquery>
<cfquery  name="sumCable" dbtype="query"  >
select   Sum ( Cable ) as Cable from spEOMSummary
</cfquery>
<cfquery  name="sumMeals" dbtype="query"  >
select   Sum ( Meals ) as Meals from spEOMSummary
</cfquery>
<cfquery  name="qrySleveltypeset" dbtype="query"  maxrows="1" >
select sleveltypeset  from spEOMSummary where solomonkey is not null
</cfquery>

<cfquery name="TotalAV" dbtype="query">
Select Sum (PrivatePayAV) + 
Sum (ResidentCareAV) + 
Sum (CoPayAV) + 
Sum (StateMedAV) + 
sum (PurchasesAV) + 
sum (BeautyShopAV) + 
sum (CableAV) + 
sum (MealsAV) + 
sum (OtherAV) as TotalAv from spEOMSummary
</cfquery>
<cfquery  name="qryRentTableAptID"  dbtype="query">
select distinct(iAptType_id) iAptType_id  from spRentTable  where iapttype_id is not null
</cfquery>
<cfset totalrevenue =  SumPrivatePay.PrivatePay + SumResidentCare.ResidentCare + SumCoPay.CoPay + SumStateMed.StateMed + sumOther.Other  + sumCable.cable>
 
<cfset PurchaseTotal = sumResidentCare.ResidentCare + sumPrivatePay.PrivatePay + sumCoPay.CoPay + sumStateMed.StateMed + sumOther.Other>

<cfdocument  format="PDF" orientation="landscape" margintop="2" marginbottom="1" marginleft=".5" marginright=".5">
	<cfdocumentitem type="header"  evalAtPrint="true">  
		<cfoutput>
			<table width="100%">
				<tr>
					<td>&nbsp;</td>
					<td align="center">
						<h1 style="text-align:center; text-decoration:underline;">End of Month Summary</h1>
					</td>
										
				</tr>			
				<tr>
					<td   style="text-align:left;"> <img src="../../images/Enlivant_logo.jpg"/ >
					<br /><h2>#HouseData.cname#   <br />
						#HouseData.Caddressline1#    <br />
						#HouseData.cCity#, #HouseData.cstatecode#  #HouseData.czipcode#    
<br />(#left(Housedata.cphonenumber1,3)#) #mid(Housedata.cphonenumber1,4,3)#-#right(Housedata.cphonenumber1,4)#
						 </h2></td>
					<td align="center">
						<h1 style="text-align:center; ">					
						<cfif right(prompt1,2) is 01>
						January, #left(prompt1,4)#
						<cfelseif right(prompt1,2) is 02>
						February, #left(prompt1,4)#				
						<cfelseif right(prompt1,2) is 03>
						March, #left(prompt1,4)#
						<cfelseif right(prompt1,2) is 04>
						April, #left(prompt1,4)#				
						<cfelseif right(prompt1,2) is 05>
						May, #left(prompt1,4)#				
						<cfelseif right(prompt1,2) is 06>
						June, #left(prompt1,4)#
						<cfelseif right(prompt1,2) is 07>
						July, #left(prompt1,4)#
						<cfelseif right(prompt1,2) is 08>
						August, #left(prompt1,4)#				
						<cfelseif right(prompt1,2) is 09>
						September, #left(prompt1,4)#
						<cfelseif right(prompt1,2) is 10>
						October, #left(prompt1,4)#				
						<cfelseif right(prompt1,2) is 11>
						November, #left(prompt1,4)#
						<cfelseif right(prompt1,2) is 12>
						December, #left(prompt1,4)#
						</cfif>
						<br />Product Line: ALL
						<br />SLevelType: #qrySleveltypeset.SLevelTypeSet#
						<br />All monetary values are ($)
						</h1>

					</td>							
				</tr>
				
			</table>
 
 	<cfif  #cfdocument.currentpagenumber# gt 1>
	<table    width="100%"  cellpadding="1" cellspacing="1" >			
		<tbody>
			<colgroup>
			<col span="1" style="width: 4%;">  <!--- unit --->
			<col span="1" style="width: 5%;">  <!--- size --->
			<col span="1" style="width: 7%;">  <!--- res id --->
			<col span="1" style="width: 12%;"> <!--- res name --->
			<col span="1" style="width: 6%;">  <!--- last review --->
			<col span="1" style="width: 2%;">  <!--- points --->
			<col span="1" style="width: 2%;">  <!--- set --->
			<col span="1" style="width: 2%;">  <!--- line --->
			<col span="1" style="width: 7%;">  <!--- bsf --->
			<col span="1" style="width: 7%;">  <!--- care --->
			<col span="1" style="width: 7%;">  <!--- med copay --->
			<col span="1" style="width: 8%;">  <!--- st med --->
			<col span="1" style="width: 7%;">  <!--- other --->
			<col span="1" style="width: 7%;">  <!--- std rent --->
			<col span="1" style="width: 7%;">  <!--- curr rent --->
			<col span="1" style="width: 10%;">  <!--- chgs this invoice --->  		
			</colgroup>
			<tr>
				<th style="border-bottom: 1px solid black;text-align:center; vertical-align:bottom">
				<h1>Unit</h1></th>
				<th style="border-bottom: 1px solid black;text-align:center; vertical-align:bottom">
				<h1>Size</h1></th>
				<th style="border-bottom: 1px solid black; text-align:center; vertical-align:bottom">
				<h1>Resident<br />ID</h1></th>
				<th style="border-bottom: 1px solid black;text-align:left; vertical-align:bottom">
				<h1>Resident Name</h1></th>
				<th style="border-bottom: 1px solid black;text-align:center; vertical-align:bottom">
				<h1>Last<br />Review</h1></th>
				<th style="border-bottom: 1px solid black;text-align:center; vertical-align:bottom">
				<h1>P<br />o<br />i<br/>n<br />t<br />s</h1></th>
				<th style="border-bottom: 1px solid black;text-align:center; vertical-align:bottom">
				<h1>L<br />V<br />L</h1></th>
				<th style="border-bottom: 1px solid black;text-align:center; vertical-align:bottom">
				<h1>L<br />i<br />n<br />e</h1></th>
				<th style="border-bottom: 1px solid black;text-align:center; vertical-align:bottom">
				<h1>Private<br />BSF</h1></th>
				<th style="border-bottom: 1px solid black;text-align:center; vertical-align:bottom">
				<h1>Resident<br />Care</h1></th>
				<th style="border-bottom: 1px solid black;text-align:center; vertical-align:bottom">
				<h1>Medic-<br />aid<br />Co-<br />Pay</h1></th>
				<th style="border-bottom: 1px solid black;text-align:center; vertical-align:bottom">
				<h1>State<br />Medic-<br />aid</h1></th>
				<th style="border-bottom: 1px solid black;text-align:center; vertical-align:bottom">
				<h1>Other</h1></th>
				<th style="border-bottom: 1px solid black;text-align:center; vertical-align:bottom">
				<h1>Standard<br />Rent</h1></th>
				<th style="border-bottom: 1px solid black;text-align:center; vertical-align:bottom">
				<h1>Current<br />Rent</h1></th>
				<th style="border-bottom: 1px solid black;text-align:left; vertical-align:bottom">
				<h1>Charges<br />This<br />Invoice</h1></th>
			</tr>	
		</tbody>
	</table>
 	</cfif>	 		
		</cfoutput>	
	</cfdocumentitem> 

	<cfoutput>
		<table width="100%" style="vertical-align:top; 
			border-top: 1px solid black; border-bottom: 1px solid black;">
		<!--- <tr><td><hr width="100"  /></td></tr> --->
		<tr><td  valign="top">
			<table width="100%" style="vertical-align:top" cellpadding="0" cellspacing="0">
				<tr>
					<td>&nbsp;</td>
					<td  style="border-right: 1px solid black;font-size:10px;">&nbsp;</td>
					<td>&nbsp;</td>
					<td  colspan="2" style="border-bottom: 1px solid black;font-size:10px;">House Default</td>
					<td  colspan="2" style="border-bottom: 1px solid black;border-right: 1px solid black;font-size:10px;">
					All Others</td>
					<td>&nbsp;</td>
					<td style="border-right: 1px solid black;font-size:10px;">&nbsp;</td>
					<td>&nbsp;</td>
					<td >&nbsp;</td>
				</tr>
				<tr>
					<td  style="font-size:10px;">Total Occupancy:</td>
					<td  style="border-right: 1px solid black;font-size:10px;">#spEOMSummary.movedIn#</td>
					<td style="font-size:10px;">Base Rate:</td>
					<td style="font-size:10px;">#spEOMSummary.Acuity0#&nbsp;</td>
					<td style="font-size:10px;"><cfif spEOMSummary.movedIn is  0>
							<cfset baseratedefault = 0> 
						<cfelse >
							<cfset baseratedefault = 100 * ( spEOMSummary.Acuity0/spEOMSummary.movedIn)>
						</cfif>
						#Numberformat(baseratedefault,'___.__')#%
					</td>	
					<td style="font-size:10px;">#spEoMSummary.AcuityO0#</td>
					<cfset AcuityO0Pct = 100 * (spEoMSummary.AcuityO0/spEOMSummary.movedIn)>
					<td style="border-right: 1px solid black;font-size:10px;">
						#Numberformat(AcuityO0Pct, '___.__')#%
					</td>
					<td style="font-size:10px;">Total Revenue:</td>
					<td style="text-align:right;border-right: 1px solid black;font-size:10px;">
						#numberformat(totalrevenue,'___,___.99')#
					</td>
					<td style="text-align:right;font-size:10px;">Total Purchases:</td>
					<td style="text-align:right;font-size:10px;">#numberformat(spEOMSummary.Purchases,'___,___.99')#</td> 	
				</tr>
				<tr>
					<td style="font-size:10px;" nowrap="nowrap">Percent Medicaid:</td>
						<cfIf  spEOMSummary.movedIn gt  0>
							<cfset medicaidcount = 
								spEOMSummary.MedicaidCounter/spEOMSummary.movedIn * 100>
						<cfElse>
							<cfset medicaidcount =    0>
						</cfIf>
					<td style="border-right: 1px solid black;font-size:10px;">#medicaidcount#%</td>
					<td style="font-size:10px;" nowrap="nowrap">Level 1:</td>
					<td style="font-size:10px;">#spEOMSummary.Acuity1#</td>
					<td style="font-size:10px;"><cfif spEOMSummary.movedIn is  0>
							<cfset baseratedefault = 0> 
						<cfelse >
							<cfset baseratedefault =   spEOMSummary.Acuity1/spEOMSummary.movedIn * 100>
						</cfif>
						#Numberformat(baseratedefault,'___.__')#%
					</td>	
					<td style="font-size:10px;">#spEoMSummary.AcuityO1# </td>
					<cfset AcuityO1Pct = 100 * spEoMSummary.AcuityO1/spEOMSummary.movedIn>
					<td style="border-right: 1px solid black;font-size:10px;">
					#Numberformat(AcuityO1Pct, '___.__')#%
					</td>
					<td style="font-size:10px;">Average Rev/Occ Unit:</td><br />
					<cfset avgRev = totalrevenue/spEOMSummary.Occupancy>
					<td style="text-align:right;border-right: 1px solid black;font-size:10px;">
						#numberformat(avgRev,'___,___.99')#
					</td>
					<td style="text-align:right;font-size:10px;">Total Beauty Shop:</td>
					<td style="text-align:right;font-size:10px;">
						#numberformat(sumBeautyShop.BeautyShop,'___,___.99')#
					</td> 	
				</tr>	
				<tr>
					<td nowrap="nowrap" style="font-size:10px;">Total Service Pts:</td>
					<td style="border-right: 1px solid black;font-size:10px;">#sumSPoints.Spoints#</td>
					<td nowrap="nowrap" style="font-size:10px;">Level 2:</td>
					<td style="font-size:10px;">#spEOMSummary.Acuity2#&nbsp;</td>
					<td style="font-size:10px;"><cfif spEOMSummary.movedIn is  0>
							<cfset baseratedefault = 0> 
						<cfelse >
							<cfset baseratedefault = (spEOMSummary.Acuity2/spEOMSummary.movedIn) * 100>
						</cfif>
						#Numberformat(baseratedefault,'___.__')#%
					</td>	
					<td style="font-size:10px;">#spEoMSummary.AcuityO2# </td>
					<cfset AcuityO2Pct = 100 * spEoMSummary.AcuityO2/spEOMSummary.movedIn>
					<td style="border-right: 1px solid black;font-size:10px;">
						#Numberformat(AcuityO2Pct, '___.__')#%
					</td>
					<td style="font-size:10px;">Average Rent/Occ Unit:</td>
				<cfset AvgRent = (sumPrivatePay.PrivatePay + sumCoPay.CoPay + sumStateMed.StateMed)/spEOMSummary.Occupancy>
					<td style="text-align:right;border-right: 1px solid black;font-size:10px;">
						#numberformat(AvgRent,'___,___.99')#
					</td>
					<td style="text-align:right;font-size:10px;">Total Cable</td>
					<td style="text-align:right;font-size:10px;" >
						#numberformat(sumCable.Cable,'___,___.99')#
					</td> 	
				</tr>	
				<tr>
					<td  style="font-size:10px;" nowrap="nowrap">Avg Service Pts:</td>
						<cfIf  spEOMSummary.movedIn gt  0>
							<cfset AvgServicePts = sumSPoints.Spoints/spEOMSummary.movedIn >

						<cfElse>
							<cfset AvgServicePts = 0>
						</cfIf>
					<td style="border-right: 1px solid black;font-size:10px;">
						#Numberformat(AvgServicePts,'___.__')#
						</td>
					<td style="font-size:10px;" nowrap="nowrap">Level 3:</td>
					<td style="font-size:10px;">#spEOMSummary.Acuity3#&nbsp;</td>
					<td style="font-size:10px;"><cfif spEOMSummary.movedIn is  0>
							<cfset baseratedefault = 0> 
						<cfelse >
							<cfset baseratedefault = 100 *  spEOMSummary.Acuity3/spEOMSummary.movedIn>
						</cfif>
						#numberformat(baseratedefault,'___.__')#%
					</td>	
					<td style="font-size:10px;">#spEoMSummary.AcuityO3# </td>
					<cfset AcuityO3Pct = 100 * spEoMSummary.AcuityO3/spEOMSummary.movedIn>
					<td style="border-right: 1px solid black;font-size:10px;">
						#Numberformat(AcuityO3Pct, '___.__')#%
						</td>
					<td style="font-size:10px;">Total Private BSF:</td>
					<td style="text-align:right;border-right: 1px solid black;font-size:10px;">
						#numberformat(sumPrivatePay.PrivatePay,'___,___.99')#
					</td>
					<td style="text-align:right;font-size:10px;">Total Meals:</td>
					<td style="text-align:right;font-size:10px;">
						#numberformat(sumMeals.Meals,'___,___.99')#
					</td> 	
				</tr>	
				<tr>
					<td  style="font-size:10px;" nowrap="nowrap">Avg Service Level:</td>
						<cfIf  spEOMSummary.iDivisor gt  0>
							<cfset avgServLvl = AvgServicePts / spEOMSummary.iDivisor + 1>
						<cfElse>
							<cfset avgServLvl =    0>
						</cfIf>
					<td style="border-right: 1px solid black;font-size:10px;">#NumberFormat(avgServLvl,'___.__')#&nbsp;</td>
					<td  style="font-size:10px;" nowrap="nowrap" >Level 4:</td>
					<td style="font-size:10px;">#spEOMSummary.Acuity4#</td>
					<cfif spEOMSummary.movedIn is  0>
						<cfset baseratedefault = 0> 
					<cfelse >
						<cfset baseratedefault = 100 *  spEOMSummary.Acuity4/spEOMSummary.movedIn>
					</cfif>				
					<td style="font-size:10px;">#Numberformat(baseratedefault,'___.__')#%</td>	
					<td style="font-size:10px;">#spEoMSummary.AcuityO4# </td>
					<cfset AcuityO4Pct = 100 * spEoMSummary.AcuityO4/spEOMSummary.movedIn>
					<td style="border-right: 1px solid black;font-size:10px;">
						#Numberformat(AcuityO4Pct, '___.__')#%
					</td>
					<td style="font-size:10px;">Total Private Medicaid:</td>
					<td style="text-align:right;border-right: 1px solid black;font-size:10px;">
						#numberformat(sumCoPay.CoPay,'___,___.99')#
					</td>
					<td style="text-align:right;font-size:10px;">Total Other:</td>
					<td style="text-align:right;font-size:10px;" >
						#numberformat(sumOther.Other,'___,___.99')#
					</td> 	
				</tr>	
				<tr>
					<td >&nbsp;</td>
					<td style="border-right: 1px solid black;font-size:10px;">&nbsp;</td>
					<td style="font-size:10px;"  nowrap="nowrap">Level 5:</td>
					<td style="font-size:10px;" >#spEOMSummary.Acuity5#&nbsp;</td>
					<td style="font-size:10px;"><cfif spEOMSummary.movedIn is  0>
							<cfset baseratedefault = 0> 
						<cfelse >
							<cfset baseratedefault = 100 *  spEOMSummary.Acuity5/spEOMSummary.movedIn>
						</cfif>
						#Numberformat(baseratedefault,'___.__')#%
					</td>	
					<td style="font-size:10px;">#spEoMSummary.AcuityO5# </td>
					<cfset AcuityO5Pct = 100 * spEoMSummary.AcuityO5/spEOMSummary.movedIn>
					<td style="border-right: 1px solid black;font-size:10px;">
						#Numberformat(AcuityO5Pct, '___.__')#%</td>
					<td style="font-size:10px;">Total State Medicaid:</td>
					<td style="text-align:right;border-right: 1px solid black;font-size:10px;">
						#numberformat(sumStateMed.StateMed,'___,___.99')#
					</td>
					<td >&nbsp;</td>
					<td style="text-align:right;font-size:10px;">&nbsp;</td>
				</tr>	
				<tr>
					<td>&nbsp;</td>
					<td style="border-right: 1px solid black;font-size:10px;">&nbsp;</td>
					<td  nowrap="nowrap" style="font-size:10px;">Level 6:</td>
					<td style="font-size:10px;">#spEOMSummary.Acuity6#&nbsp;</td>
					<td style="font-size:10px;"><cfif spEOMSummary.movedIn is  0>
							<cfset baseratedefault = 0> 
						<cfelse >
							<cfset baseratedefault = 100 *  spEOMSummary.Acuity6/spEOMSummary.movedIn>
						</cfif>
						#numberformat(baseratedefault,'___.__')#%
					</td>	
					<td style="font-size:10px;">#spEoMSummary.AcuityO6# </td>
					<cfset AcuityO6Pct = 100 * spEoMSummary.AcuityO6/spEOMSummary.movedIn>
					<td style="border-right: 1px solid black;font-size:10px;">
						#Numberformat(AcuityO6Pct, '___.__')#%
					</td>
					<td style="font-size:10px;">Total Resident Care:</td>
					<td style="text-align:right;border-right: 1px solid black;font-size:10px;">
						#numberformat(SumResidentCare.ResidentCare,'___,___.99')#
					</td>
					<td style="text-align:right;font-size:10px;">Batch Total:</td>
					<td style="text-align:right;font-size:10px;">
						#numberformat(TotalAV.TotalAv,'___,___.99')#
					</td> 	
				</tr>													
			</table>
		</td>
		<td  valign="top">
			<table style="vertical-align:top;" cellspacing="0"  cellpadding="0">
			<tr>
				<td colspan="8"  style="text-align:center;font-size:10px;">
					ACUITY (HOUSE DEFAULT SET: #spRentTable.cSLevelTypeSet#)
				</td>	
			</tr>
			<tr >
				<td style="text-align:center;border-bottom: 1px solid black;text-align:center;
				border-left: 1px solid black;font-size:10px;">Unit</td>
				<td style="text-align:center;border-bottom: 1px solid black;font-size:10px;">Base</td>
				<td style="text-align:center;border-bottom: 1px solid black;font-size:10px;">1</td>
				<td style="text-align:center;border-bottom: 1px solid black;font-size:10px;">2</td>
				<td style="text-align:center;border-bottom: 1px solid black;font-size:10px;">3</td>	
				<td style="text-align:center;border-bottom: 1px solid black;font-size:10px;">4</td>
				<td style="text-align:center;border-bottom: 1px solid black;font-size:10px;">5</td>
				<td style="text-align:center;border-bottom: 1px solid black;font-size:10px;">6</td>	
			</tr> 
		
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
				<td style="border-left: 1px solid black;font-size:10px;">#qryRoomType.cdescription#&nbsp;</td>
				<td style="text-align:right;font-size:10px;">#numberformat(qryAcuity0.totalrent,'___.99')#&nbsp;</td>
				<td style="text-align:right;font-size:10px;">#numberformat(qryAcuity1.totalrent,'___.99')#&nbsp;</td>
				<td style="text-align:right;font-size:10px;">#numberformat(qryAcuity2.totalrent,'___.99')#&nbsp;</td>
				<td style="text-align:right;font-size:10px;">#numberformat(qryAcuity3.totalrent,'___.99')#&nbsp;</td>	
				<td style="text-align:right;font-size:10px;">#numberformat(qryAcuity4.totalrent,'___.99')#&nbsp;</td>
				<td style="text-align:right;font-size:10px;">#numberformat(qryAcuity5.totalrent,'___.99')#&nbsp;</td>
				<td style="text-align:right;font-size:10px;">#numberformat(qryAcuity6.totalrent,'___.99')#&nbsp;</td>	
			</tr>
			</cfloop>
			<cfquery  name="qry2ndResident0" dbtype="query">
			select totalrent from spRentTable  
			where  acuity = '0' and iapttype_id is null and ioccupancyPosition = 2
			</cfquery>
			<cfquery  name="qry2ndResident1" dbtype="query">
			select totalrent from spRentTable  
			where  acuity = '1' and iapttype_id  is null and ioccupancyPosition = 2
			</cfquery>
			<cfquery  name="qry2ndResident2" dbtype="query">
			select totalrent from spRentTable  
			where  acuity = '2' and iapttype_id  is null and ioccupancyPosition = 2
			</cfquery>
			<cfquery  name="qry2ndResident3" dbtype="query">
			select totalrent from spRentTable  
			where  acuity = '3' and iapttype_id  is null and ioccupancyPosition = 2
			</cfquery>
			<cfquery  name="qry2ndResident4" dbtype="query">
			select totalrent from spRentTable  
			where  acuity = '4' and iapttype_id  is null and ioccupancyPosition = 2
			</cfquery>
			<cfquery  name="qry2ndResident5" dbtype="query">
			select totalrent from spRentTable  
			where  acuity = '5' and iapttype_id is null and ioccupancyPosition = 2
			</cfquery>
			<cfquery  name="qry2ndResident6" dbtype="query">
			select totalrent from spRentTable  
			where  acuity = '6' and iapttype_id  is null and ioccupancyPosition = 2
			</cfquery>
		
		<tr>
			<td style="text-align:left;border-left: 1px solid black;font-size:10px;">2nd Resident</td>
			<td style="text-align:right;font-size:10px;">#numberformat(qry2ndResident0.totalrent,'___.99')#&nbsp;</td>
			<td style="text-align:right;font-size:10px;">#numberformat(qry2ndResident1.totalrent,'___.99')#&nbsp;</td>
			<td style="text-align:right;font-size:10px;">#numberformat(qry2ndResident2.totalrent,'___.99')#&nbsp;</td>
			<td style="text-align:right;font-size:10px;">#numberformat(qry2ndResident3.totalrent,'___.99')#&nbsp;</td>	
			<td style="text-align:right;font-size:10px;">#numberformat(qry2ndResident4.totalrent,'___.99')#&nbsp;</td>
			<td style="text-align:right;font-size:10px;">#numberformat(qry2ndResident5.totalrent,'___.99')#&nbsp;</td>
			<td style="text-align:right;font-size:10px;">#numberformat(qry2ndResident6.totalrent,'___.99')#&nbsp;</td>	
		</tr>
		</table>
		
		</td>
		</tr>
		</table>
		<cfdocumentitem type="pagebreak" />
		<table    width="100%"  cellpadding="1" cellspacing="1" >
			
	<tbody>
		<colgroup>
			<col span="1" style="width: 4%;">  <!--- unit --->
			<col span="1" style="width: 5%;">  <!--- size --->
			<col span="1" style="width: 7%;">  <!--- res id --->
			<col span="1" style="width: 12%;"> <!--- res name --->
			<col span="1" style="width: 6%;">  <!--- last review --->
			<col span="1" style="width: 2%;">  <!--- points --->
			<col span="1" style="width: 2%;">  <!--- set --->
			<col span="1" style="width: 2%;">  <!--- line --->
			<col span="1" style="width: 7%;">  <!--- bsf --->
			<col span="1" style="width: 7%;">  <!--- care --->
			<col span="1" style="width: 7%;">  <!--- med copay --->
			<col span="1" style="width: 8%;">  <!--- st med --->
			<col span="1" style="width: 7%;">  <!--- other --->
			<col span="1" style="width: 7%;">  <!--- std rent --->
			<col span="1" style="width: 7%;">  <!--- curr rent --->
			<col span="1" style="width: 10%;">  <!--- chgs this invoice ---> 		
		</colgroup>
	
				<cfloop query="spEOMSummary">
					<cfset Descript = #trim(Descript)#>
					<cfif Descript is 'Studio'><cfset RoomSize = 'ST'>
					<cfelseif 	Descript is 'IL Studio'><cfset RoomSize = 'STIL'>
					<cfelseif 	Descript is 'Studio'><cfset RoomSize = 'ST'>	
					<cfelseif 	Descript is 'Studio                                            '>
						<cfset RoomSize = 'ST'>						
					<cfelseif 	Descript is 'Studio IL A'><cfset RoomSize = 'STIL'>
					<cfelseif 	Descript is 'Studio AL A'><cfset RoomSize = 'STAL'>
					<cfelseif 	Descript is 'Studio AL B'><cfset RoomSize = 'STAL'>	
					<cfelseif 	Descript is 'Studio AL C'><cfset RoomSize = 'STAL'>	
					<cfelseif 	Descript is 'Studio Premium'><cfset RoomSize = 'STP'>		
					<cfelseif 	Descript is 'Studio Deluxe' ><cfset RoomSize = 'STDX'>
					<cfelseif 	Descript is 'Studio Deluxe                                     '><cfset RoomSize = 'STDX'>
					<cfelseif 	Descript is 'Studio Kitchen' > <cfset RoomSize = 'STDK'>	
					<cfelseif 	Descript is 'Studio Suite' > <cfset RoomSize = 'STS'>		
					<cfelseif 	Descript is 'OneBedroom'><cfset RoomSize = '1B'>	
					<cfelseif 	Descript is 'One Bedroom'><cfset RoomSize = '1B'>   
					<cfelseif 	Descript is 'One Bedroom '><cfset RoomSize = '1B'> 	
					<cfelseif 	Descript is 'One Bedroom                                       '>
						<cfset RoomSize = '1B'> 									                                    
					<cfelseif 	Descript is 'One Bedroom Deluxe'><cfset RoomSize = '1BDX'>	
					<cfelseif 	Descript is 'One Bedroom AL B'><cfset RoomSize = '1BALB'>
					<cfelseif 	Descript is 'One Bedroom AL C'><cfset RoomSize = '1BALC'>
					<cfelseif 	Descript is 'One Bedroom AL D'><cfset RoomSize = '1BALD'>
					<cfelseif 	Descript is 'One Bedroom AL E'><cfset RoomSize = '1BALE'>	
					<cfelseif 	Descript is 'One Bedroom IL C'><cfset RoomSize = '1BILC'>
					<cfelseif 	Descript is 'One Bedroom IL D'><cfset RoomSize = '1BILD'>
					<cfelseif 	Descript is 'One Bedroom IL E'><cfset RoomSize = '1BILE'>	
					<cfelseif 	Descript is 'One Bedroom Deluxe'><cfset RoomSize = '1BDX'>
					<cfelseif 	Descript is 'One Bedroom Premium'><cfset RoomSize = '1BP'>	
					<cfelseif 	Descript is 'One Bedroom Premium Plus'><cfset RoomSize = '1BP+'>	
					<cfelseif 	Descript is 'One Bedroom Premium w/ Patio'><cfset RoomSize = '1BPP'>								
					<cfelseif 	Descript is 'IL One Bedroom'><cfset RoomSize = '1BIL'>
					<cfelseif 	Descript is 'IL Two Bedroom'><cfset RoomSize = '2BIL'>	
					<cfelseif 	Descript is 'Two Bedroom' > <cfset RoomSize = '2B'>
					<cfelseif 	Descript is 'Two Bed Two Bath' > <cfset RoomSize = '2B2B'>	
					<cfelseif 	Descript is 'Two Bed Two Bath Deluxe' > <cfset RoomSize = '2B2BDX'>	
					<cfelseif 	Descript is 'Two Bedroom AL A' > <cfset RoomSize = '2BAL'> 
					<cfelseif 	Descript is 'Two Bedroom IL A' > <cfset RoomSize = '2BILA'> 
					<cfelseif 	Descript is 'Two Bedroom IL B' > <cfset RoomSize = '2BILB'> 
					<cfelseif 	Descript is 'Two Bedroom Premium' > <cfset RoomSize = '2BP'> 				
					<cfelseif 	Descript is 'Two Bedroom Deluxe' > <cfset RoomSize = '2BDX'>		
					<cfelseif 	Descript is 'Alcove'> <cfset RoomSize = 'AL'>
					<cfelseif 	Descript is 'Deluxe'> <cfset RoomSize = 'DX'>
					<cfelseif 	Descript is 'Duplex'> <cfset RoomSize = 'DPX'>
					<cfelseif 	Descript is 'Efficiency' > <cfset RoomSize = 'EFF'>
					<cfelseif 	Descript is 'Home Health Room' > <cfset RoomSize = 'HHR'>
					<cfelseif 	Descript is 'Double Room'> <cfset RoomSize = 'DBL'>
					<cfelseif 	Descript is 'Companion'> <cfset RoomSize = 'CST'>
					<cfelseif 	Descript is 'Companion Studio'> <cfset RoomSize = 'CST'>
					<cfelseif 	Descript is 'Companion Studio Deluxe'> <cfset RoomSize = 'CSD'>
					<cfelseif 	Descript is 'Companion One Bedroom'> <cfset RoomSize = 'C1B'>
					<cfelseif 	Descript is 'Companion Two Bedroom'> <cfset RoomSize = 'C2B'>
					<cfelseif 	Descript is 'Companion Deluxe'> <cfset RoomSize = 'CDX'>
					<cfelseif 	Descript is 'Companion One Bedroom Premium'><cfset RoomSize = 'C1BP'>
					<cfelseif 	Descript is 'Companion Two Bedroom Premium'><cfset RoomSize = 'C2BP'>	
					<cfelseif 	Descript is 'MC Studio'><cfset RoomSize = 'MC-ST'>
					<cfelseif 	Descript is 'MC Studio Deluxe'><cfset RoomSize = 'MC-DX'>
					<cfelseif 	Descript is 'MC Companion Studio'><cfset RoomSize = 'MC-CST'>
					<cfelseif 	Descript is 'MC Companion Studio Deluxe'><cfset RoomSize = 'MC-CSD'>
					<cfelseif 	Descript is 'MC One Bedroom'><cfset RoomSize = 'MC-1B'>
					<cfelseif 	Descript is 'MC Companion One Bedroom'><cfset RoomSize = 'MC-C1B'>
					<cfelseif 	Descript is 'MC Two Bedroom'><cfset RoomSize = 'MC-2B'>
					<cfelseif 	Descript is 'MC Companion Two Bedroom'><cfset RoomSize = 'MC-C2B'>
					<cfelse ><cfset RoomSize = #Descript#>	
					</cfif>			
				<cfset residentname = firstname & ' ' & lastname>
				<cfset residentname = trim(residentname)>
	<cfset CurrentRent = #PrivatePay#  + #ResidentCare#  + #CoPay#>
	<cfset Othertotal =#Purchases#  + #BeautyShop#+ #Cable# + #Meals# + #Other#>
	<cfset totalCharges = #PrivatePay#  +  #ResidentCare#  +  #CoPay# +  #StateMed#  +  #Othertotal#>
				<cfset totalrent = 0>
				<cfset totalrent = PrivatePay + ResidentCare>
				<CFset stdrateHi = ''>
				<cfif PrivatePay gt 0>
					<cfif ((totalrent is totalCharges) and (totalrent is not ''))>
						<cfset stdrateHi = 'T'>
					<cfelse>	 
						<cfset stdrateHi = ''>
					</cfif>
				<cfelse>
				<cfset stdrateHi = ''>
				</cfif>
				<tr>
					<td style="text-align:center;font-size:10px;">#trim(AptNumber)#</td>
					<td style="font-size:10px;" >#RoomSize#</td>
					<td style="font-size:10px;"  >#solomonkey#</td>
					<td style="font-size:10px;" >#residentname#</td>
					<td style="font-size:10px;" >#dateformat(SPEvaluation,'mm/dd/yyyy')#</td>
					<td style="text-align:center;font-size:10px;">#Spoints#</td>
					<td style="font-size:10px;"  >#Acuity#</td>
					<td style="font-size:10px;" >
						<cfif firstname is 'Vacant'>&nbsp;<cfelse>#AptProductLineCode#</cfif>
					</td>
					<td style="text-align:right; font-size:10px;" nowrap="nowrap">
						<cfif PrivatePay is 0>&nbsp;  
						<cfelseif PrivatePay is ''>&nbsp;
						<cfelse>
							 #Numberformat(PrivatePay,'__,___.99')#
							<cfset totalPrivatePay = #totalPrivatePay# + #PrivatePay#>	
						</cfif>
					</td>
					<td style="text-align:right; font-size:10px;" nowrap="nowrap"> 
						<cfif ResidentCare is 0>&nbsp;  
						<cfelseif ResidentCare is ''>&nbsp;
						<cfelse>
							 #Numberformat(ResidentCare,'__,___.99')#
							 <cfset totalResidentCare = #totalResidentCare# + #ResidentCare#> 						
						</cfif>
					</td>
					<td style="text-align:right; font-size:10px;" nowrap="nowrap">
						<cfif CoPay is 0>&nbsp;  
						<cfelseif CoPay is ''>&nbsp;
						<cfelse>
							 #Numberformat(CoPay,'__,___.99')#
							<cfset totalCoPay = #totalCoPay# + #CoPay#>					
						</cfif>
					</td>
					<td style="text-align:right; font-size:10px;" nowrap="nowrap">
						<cfif StateMed is 0>&nbsp;  
						<cfelseif StateMed is ''>&nbsp;
						<cfelse>
							 #Numberformat(StateMed,'__,___.99')#
							<cfset totalStateMed = #totalStateMed# + #StateMed#>
						</cfif>
					</td>
					
					<td style="text-align:right; font-size:10px;" nowrap="nowrap">
						<cfif Othertotal is 0>&nbsp;  
						<cfelseif Othertotal is ''>&nbsp;
						<cfelse>
							 #Numberformat(Othertotal,'__,___.99')#
							<cfset totalOthertotal = #totalOthertotal# + #Othertotal#>
						</cfif>
					</td>
					 <cfif stdrateHi is 'T'>
				<td style="text-align:right; color:##FFFFFF ;font-size:10px; background-color:##333333;" nowrap="nowrap"> 
							<cfif StdRate is 0>&nbsp; 
							<cfelseif StdRate is ''>&nbsp;
							<cfelse>
								 #Numberformat(StdRate,'__,___.99')#
							 	<cfif StdRate is not ''>
								<cfset totalStdRate = #totalStdRate# + #StdRate#>
								</cfif>
							</cfif>
						</td>
					<cfelseif residentname is 'Vacant'>
				<td style="text-align:right;font-size:10px;" nowrap="nowrap">&nbsp;</td>
 					<cfelse>
				<td style="text-align:right; font-size:10px;"  nowrap="nowrap"> 
							 #Numberformat(StdRate,'__,__9.99')#
								<cfif StdRate is not ''>
								<cfset totalStdRate = #totalStdRate# + #StdRate#>
								</cfif>
						</td>
					</cfif>
					<cfif CurrentRent is not ''>
					<cfset totalCurrentRent = #totalCurrentRent# + #CurrentRent#>
					</cfif>
					<td style="text-align:right; font-size:10px;" nowrap="nowrap">
						<cfif CurrentRent is 0>&nbsp; 
						<cfelseif #CurrentRent# is ''>&nbsp;
						<cfelse> #Numberformat(CurrentRent,'__,___.99')#
						</cfif>
					</td>
					<cfif totalCharges is not ''>
					<cfset totalTotalCharges = #totalTotalCharges# + #totalCharges#>
					</cfif>
					<td style="text-align:left; font-size:10px;" nowrap="nowrap">
						<cfif totalCharges is 0>&nbsp; 
						<cfelseif totalCharges is ''>&nbsp;
						<cfelse> #Numberformat(totalCharges,'__,___.99')#
						</cfif>
					</td>
				</tr>
			</cfloop>
			<tr  style="line-height:100%">
				<td>&nbsp;</td>
				<td>&nbsp;</td>
				<td>&nbsp;</td>
				<td>&nbsp;</td>
				<td>&nbsp;</td>
				<td>&nbsp;</td>
				<td>&nbsp;</td>
				<td>&nbsp;</td>
				<td  style="border-top: .5px solid black;font-size:10px; text-align:right" nowrap="nowrap">
					  #Numberformat(totalPrivatePay,'__,___.99')#
				</td>
				<td  style="border-top: .5px solid black;font-size:10px; text-align:right" nowrap="nowrap">
					 #Numberformat(totalResidentCare,'__,___.99')#
				</td>
				<td  style="border-top: .5px solid black;font-size:10px; text-align:right" nowrap="nowrap">
					 #Numberformat(totalCoPay,'__,___.99')#
				</td>
				<td  style="border-top: .5px solid black;font-size:10px; text-align:right" nowrap="nowrap">
					 #Numberformat(totalStateMed,'__,___.99')#
				</td>
				<td  style="border-top: .5px solid black;font-size:10px; text-align:right" nowrap="nowrap">
					 #Numberformat(totalOthertotal,'__,___.99')#
				</td>
				<td  style="border-top: .5px solid black;font-size:10px; text-align:right" nowrap="nowrap">
					 #Numberformat(totalStdRate,'__,___.99')#
				</td>
				<td  style="border-top: .5px solid black;font-size:10px; text-align:right" nowrap="nowrap">
					 #Numberformat(totalCurrentRent,'__,___.99')#
				</td>
				<td  style="border-top: .5px solid black;font-size:10px; text-align:left" nowrap="nowrap">
					 #Numberformat(totalTotalCharges,'__,___.99')#
				</td>
			</tr>
		</tbody>
		</table>
		<table width="100%" align="center">
		<tr>
			<td colspan="5">&nbsp;</td>
		</tr>		
		<tr>
			<td colspan="5" style="border-bottom:.5px solid black;text-align:center; font-size:12px; font-weight:bold">
				 End Of Month Summary Exceptions 
			</td>
		</tr>
		
		<tr>
			<td>&nbsp;</td>
			<td style="border-bottom: .5px solid black; text-align:center; font-size:10px;">Teant ID</td>
			<td style="border-bottom: .5px solid black; text-align:left; font-size:10px;">Resident Name</td>
			<td style="border-bottom: .5px solid black; text-align:center; font-size:10px;">Tenant State</td>
			<td>&nbsp;</td>			
		</tr>
		<Cfloop query="spEoMSummaryExceptions">
			<tr>
				<td>&nbsp;</td>		
				<td  style="text-align:center; font-size:10px;">#cSolomonKey#</td>
				<td style="text-align:left; font-size:10px;">#cFirstname# #clastname#</td>
				<td style="text-align:center; font-size:10px;">#itenantstatecode_ID# (#cDescription#)</td>
				<td>&nbsp;</td>	
			</tr>			
		</Cfloop>
		</table>
	</cfoutput>	
 	
 	<cfdocumentitem  type="footer" evalAtPrint="true">
		<table width="100%">
			<cfoutput>
				<tr>
					<td style="font-size:small; ">
						Page: #cfdocument.currentpagenumber# of #cfdocument.totalpagecount#
					</td>
				</tr>						
				<cfif #cfdocument.currentpagenumber# is #cfdocument.totalpagecount#>
					<tr>
						<td style="font-size:small; text-align:center; ">
							Enlivant&trade;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Printed: #dateformat(now(), 'mm/dd/yyyy')#&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
								EOMSummary.cfm
						</td>
					</tr>
				</cfif>
			</cfoutput>
		</table>
	</cfdocumentitem>

 <cfoutput>  	
		<cfheader name="Content-Disposition"   
 		value="attachment;filename=EOMSummary-#HouseData.cname#-#prompt1#.pdf"> 
	</cfoutput>			

</cfdocument>
</body>
</html>
