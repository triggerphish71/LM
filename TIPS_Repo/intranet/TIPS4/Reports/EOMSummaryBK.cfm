<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>EOMSummary.cfm</title>
</head>
<cfparam name="prompt1" default="">
<cfif IsDefined('url.prompt1')and url.prompt1 is not ''>
	<cfset url.prompt1 = '201509'>
<cfelseif  IsDefined('form.prompt1')and form.prompt1 is not ''>
	<cfset form.prompt1 = '201509'>
<cfelse>
	<cfset prompt1 = '201509'>
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
select   Sum ( Other ) as Other from spEOMSummary
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
<cfset totalrevenue =  SumPrivatePay.PrivatePay + SumResidentCare.ResidentCare + SumCoPay.CoPay + SumStateMed.StateMed + sumOther.Other>

 
<cfset PurchaseTotal = sumResidentCare.ResidentCare + sumPrivatePay.PrivatePay + sumCoPay.CoPay + sumStateMed.StateMed + sumOther.Other>
<cfoutput>
			<h1 style="text-align:center; text-decoration:underline;">End of Month Summary</h1>
			<DIV><img src="../../images/Enlivant_logo.jpg"    /><br />
			 #Housedata.cname#<br />
			#Housedata.caddressline1#<br />
			<cfif Housedata.caddressline2 is not ''> #Housedata.caddressline2#<br /></cfif>
			#HouseData.ccity#, #Housedata.cstatecode# #Housedata.czipcode#<br />
			(#left(Housedata.cphonenumber1,3)#)	#mid(Housedata.cphonenumber1,4,3)#-#right(Housedata.cphonenumber1,4)#
			</div>
			<cfoutput>
				<h2 style="text-align:center; ">					
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
					</cfif></h2>
					<h2 style="text-align:center; ">Product Line: ALL</h2>

			</cfoutput>
	<table width="100%" style="vertical-align:top">
	<tr><td>
		<table style="vertical-align:top">
			<tr>
				<td>&nbsp;</td>
				<td>&nbsp;</td>
				<td>&nbsp;</td>
				<td colspan="2">House Default</td>
				<td colspan="2">All Others</td>
				<td>&nbsp;</td>
				<td>&nbsp;</td>
				<td>&nbsp;</td>
				<td>&nbsp;</td>
			</tr>
			<tr>
				<td>Total Occupancy:</td>
				<td>#spEOMSummary.movedIn#</td>
				<td>Base Rate:</td>
				<td>#spEOMSummary.Acuity0#</td>
				<td><!--- <cfif spEOMSummary.movedIn is  0>
						<cfset baseratedefault = 0> 
					<cfelse > --->
						<cfset baseratedefault = 100 * ( spEOMSummary.Acuity0/spEOMSummary.movedIn)>
					<!--- </cfif> --->
					#Numberformat(baseratedefault,'___.__')#%
				</td>	
				<td>O0</td>
				<cfset AcuityO0Pct = 100 * (spEoMSummary.AcuityO0/spEOMSummary.movedIn)>
				<td>#Numberformat(AcuityO0Pct, '___.__')#%</td>
				<td>Total Revenue:</td>
				<td style="text-align:right">#dollarformat(totalrevenue)#</td>
				<td style="text-align:right">Total Purchases:</td>
				<td style="text-align:right">#dollarformat(spEOMSummary.Purchases)#</td> 	
			</tr>
			<tr>
				<td>Percent Medicaid:</td>
					<cfIf  spEOMSummary.movedIn gt  0>
						<cfset medicaidcount = spEOMSummary.MedicaidCounter/spEOMSummary.movedIn * 100>
					<cfElse>
						<cfset medicaidcount =    0>
					</cfIf>
				<td>#medicaidcount#%</td>
				<td>Level 1:</td>
				<td>#spEOMSummary.Acuity1#</td>
				<td><cfif spEOMSummary.movedIn is  0>
						<cfset baseratedefault = 0> 
					<cfelse >
						<cfset baseratedefault =   spEOMSummary.Acuity1/spEOMSummary.movedIn * 100>
					</cfif>
					#Numberformat(baseratedefault,'___.__')#%
				</td>	
				<td>O1</td>
				<cfset AcuityO1Pct = 100 * spEoMSummary.AcuityO1/spEOMSummary.movedIn>
				<td>#Numberformat(AcuityO1Pct, '___.__')#%</td>
				<td>Average Rev/Occ Unit:</td><br />
				<cfset avgRev = totalrevenue/spEOMSummary.Occupancy>
				<td style="text-align:right">#dollarformat(avgRev)#</td>
				<td style="text-align:right">Total Beauty Shop:</td>
				<td style="text-align:right">#dollarformat(sumBeautyShop.BeautyShop)#</td> 	
			</tr>	
			<tr>
				<td>Total Service Pts:</td>
				<td>#sumSPoints.Spoints#</td>
				<td>Level 2:</td>
				<td>#spEOMSummary.Acuity2#</td>
				<td><cfif spEOMSummary.movedIn is  0>
						<cfset baseratedefault = 0> 
					<cfelse >
						<cfset baseratedefault = (spEOMSummary.Acuity2/spEOMSummary.movedIn) * 100>
					</cfif>
					#Numberformat(baseratedefault,'___.__')#%
				</td>	
				<td>O2</td>
				<cfset AcuityO2Pct = 100 * spEoMSummary.AcuityO2/spEOMSummary.movedIn>
				<td>#Numberformat(AcuityO2Pct, '___.__')#%</td>
				<td>Average Rent/Occ Unit:</td>
			<cfset AvgRent = (sumPrivatePay.PrivatePay +  sumCoPay.CoPay + sumStateMed.StateMed)/spEOMSummary.Occupancy>
				<td style="text-align:right">#dollarformat(AvgRent)#</td>
				<td style="text-align:right">Total Cable</td>
				<td style="text-align:right">#dollarformat(sumCable.Cable)#</td> 	
			</tr>	
			<tr>
				<td>Avg Service Pts:</td>
					<cfIf  spEOMSummary.movedIn gt  0>
						<cfset AvgServicePts = sumSPoints.Spoints/spEOMSummary.movedIn >
					<cfElse>
						<cfset AvgServicePts = 0>
					</cfIf>
				<td>#Numberformat(AvgServicePts,'___.__')#</td>
				<td>Level 3:</td>
				<td>#spEOMSummary.Acuity3#</td>
				<td><cfif spEOMSummary.movedIn is  0>
						<cfset baseratedefault = 0> 
					<cfelse >
						<cfset baseratedefault = 100 *  spEOMSummary.Acuity3/spEOMSummary.movedIn>
					</cfif>
					#numberformat(baseratedefault,'___.__')#%
				</td>	
				<td>O3</td>
				<cfset AcuityO3Pct = 100 * spEoMSummary.AcuityO3/spEOMSummary.movedIn>
				<td>#Numberformat(AcuityO3Pct, '___.__')#%</td>
				<td>Total Private BSF:</td>
				<td style="text-align:right">#dollarformat(sumPrivatePay.PrivatePay)#</td>
				<td style="text-align:right">Total Meals:</td>
				<td style="text-align:right">#dollarformat(sumMeals.Meals)#</td> 	
			</tr>	
			<tr>
				<td>Avg Service Level:</td>
 					<cfIf  spEOMSummary.iDivisor gt  0>
						<cfset avgServLvl = AvgServicePts / spEOMSummary.iDivisor>
					<cfElse>
						<cfset avgServLvl =    0>
					</cfIf>
				<td>#NumberFormat(avgServLvl,'___.__')#</td>
				<td>Level 4:</td>
				<td>#spEOMSummary.Acuity4#</td>
				<cfif spEOMSummary.movedIn is  0>
					<cfset baseratedefault = 0> 
				<cfelse >
					<cfset baseratedefault = 100 *  spEOMSummary.Acuity4/spEOMSummary.movedIn>
				</cfif>				
				<td>#Numberformat(baseratedefault,'___.__')#%</td>	
				<td>O4</td>
				<cfset AcuityO4Pct = 100 * spEoMSummary.AcuityO4/spEOMSummary.movedIn>
				<td>#Numberformat(AcuityO4Pct, '___.__')#%</td>
				<td>Total Private Medicaid:</td>
				<td style="text-align:right">#dollarformat(sumCoPay.CoPay)#</td>
				<td style="text-align:right">Total Other:</td>
				<td style="text-align:right">#dollarformat(sumOther.Other)#</td> 	
			</tr>	
			<tr>
				<td>&nbsp;</td>
				<td>&nbsp;</td>
				<td>Level 5:</td>
				<td>#spEOMSummary.Acuity5#</td>
				<td><cfif spEOMSummary.movedIn is  0>
						<cfset baseratedefault = 0> 
					<cfelse >
						<cfset baseratedefault = 100 *  spEOMSummary.Acuity5/spEOMSummary.movedIn>
					</cfif>
					#Numberformat(baseratedefault,'___.__')#%
				</td>	
				<td>O5</td>
				<cfset AcuityO5Pct = 100 * spEoMSummary.AcuityO5/spEOMSummary.movedIn>
				<td>#Numberformat(AcuityO5Pct, '___.__')#%</td>
				<td>Total State Medicaid:</td>
				<td  style="text-align:right">#dollarformat(sumStateMed.StateMed)#</td>
				<td>&nbsp;</td>
				<td>&nbsp;</td>
			</tr>	
			<tr>
				<td>&nbsp;</td>
				<td>&nbsp;</td>
				<td>Level 6:</td><td>#spEOMSummary.Acuity6#</td>
				<td><cfif spEOMSummary.movedIn is  0>
						<cfset baseratedefault = 0> 
					<cfelse >
						<cfset baseratedefault = 100 *  spEOMSummary.Acuity6/spEOMSummary.movedIn>
					</cfif>
					#numberformat(baseratedefault,'___.__')#%
				</td>	
				<td>O6</td>
				<cfset AcuityO6Pct = 100 * spEoMSummary.AcuityO6/spEOMSummary.movedIn>
				<td>#Numberformat(AcuityO6Pct, '___.__')#%</td>
				<td>Total Resident Care:</td>
				<td style="text-align:right">#dollarformat(SumResidentCare.ResidentCare)#</td>
				<td style="text-align:right">Batch Total:</td>
				<td style="text-align:right">#dollarformat(TotalAV.TotalAv)#</td> 	
			</tr>													
		</table>
	</td>
	<td >
  
<table style="vertical-align:top" >
<tr>
	<td colspan="8" style="text-align:center">ACUITY (HOUSE DEFAULT SET: #spRentTable.cSLevelTypeSet#)</td>	
</tr>
<tr>
	<td style="text-align:center">Unit</td>
	<td style="text-align:center">Base</td>
	<td style="text-align:center">1</td>
	<td style="text-align:center">2</td>
	<td style="text-align:center">3</td>	
	<td style="text-align:center">4</td>
	<td style="text-align:center">5</td>
	<td style="text-align:center">6</td>	
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
	<td>#qryRoomType.cdescription#</td>
	<td>#dollarformat(qryAcuity0.totalrent)#</td>
	<td>#dollarformat(qryAcuity1.totalrent)#</td>
	<td>#dollarformat(qryAcuity2.totalrent)#</td>
	<td>#dollarformat(qryAcuity3.totalrent)#</td>	
	<td>#dollarformat(qryAcuity4.totalrent)#</td>
	<td>#dollarformat(qryAcuity5.totalrent)#</td>
	<td>#dollarformat(qryAcuity6.totalrent)#</td>	
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
	<td>2nd Resident</td>
	<td>#dollarformat(qry2ndResident0.totalrent)#</td>
	<td>#dollarformat(qry2ndResident1.totalrent)#</td>
	<td>#dollarformat(qry2ndResident2.totalrent)#</td>
	<td>#dollarformat(qry2ndResident3.totalrent)#</td>	
	<td>#dollarformat(qry2ndResident4.totalrent)#</td>
	<td>#dollarformat(qry2ndResident5.totalrent)#</td>
	<td>#dollarformat(qry2ndResident6.totalrent)#</td>	
</tr>
</table>
 
	</td>
	
	
	</tr>
	</table>
	<table width="100%" style="border:medium">
		<tr>
			<td class="16">#HouseData.cname# #prompt1#</td>
		</tr>
		<tr style="line-height:100%">
			<td  style="border-bottom: .5px solid black;">Unit</td>
			<td  style="border-bottom: .5px solid black;">Size</td>
			<td  style="border-bottom: .5px solid black;">Resident<br />ID</td>
			<td  style="border-bottom: .5px solid black;">Resident Name</td>
			<td  style="border-bottom: .5px solid black;">Review</td>
			<td  style="border-bottom: .5px solid black;">Pts</td>
			<td  style="border-bottom: .5px solid black;">Set</td>
			<td  style="border-bottom: .5px solid black;">Lvl</td>
			<td  style="border-bottom: .5px solid black;">Line</td>
			<td  style="border-bottom: .5px solid black;">Private<br />BSF</td>
			<td  style="border-bottom: .5px solid black;">Resident<br />Care</td>
			<td  style="border-bottom: .5px solid black;">Medicaid<br />Co-Pay</td>
			<td  style="border-bottom: .5px solid black;">State<br />Medicaid</td>
			<td  style="border-bottom: .5px solid black;">Other</td>
			<td  style="border-bottom: .5px solid black;">Standard<br />Rent</td>
			<td  style="border-bottom: .5px solid black;">Current<br />Rent</td>
			<td  style="border-bottom: .5px solid black;">Charges<br />This Invoice</td>
		</tr>
		<cfloop query="spEOMSummary">
			<tr>
				<td>#AptNumber#</td>
				<td><cfif Descript is 'Studio'>ST
					<cfelseif 	Descript is 'IL Studio'>STIL
					<cfelseif 	Descript is 'Studio'>ST					
					<cfelseif 	Descript is 'Studio IL A'>STIL
					<cfelseif 	Descript is 'Studio AL A'>STAL
					<cfelseif 	Descript is 'Studio AL B'>STAL	
					<cfelseif 	Descript is 'Studio AL C'>STAL	
					<cfelseif 	Descript is 'Studio Premium'>STP		
					<cfelseif 	Descript is 'Studio Deluxe' > STDX
					<cfelseif 	Descript is 'Studio Kitchen' > STDK	
					<cfelseif 	Descript is 'Studio Suite' > STS		
					<cfelseif 	Descript is 'One Bedroom'>1B	
					<cfelseif 	Descript is 'One Bedroom Deluxe'>1BDX	
					<cfelseif 	Descript is 'One Bedroom AL B'>1BALB
					<cfelseif 	Descript is 'One Bedroom AL C'>1BALC
					<cfelseif 	Descript is 'One Bedroom AL D'>1BALD
					<cfelseif 	Descript is 'One Bedroom AL E'>1BALE	
					<cfelseif 	Descript is 'One Bedroom IL C'>1BILC
					<cfelseif 	Descript is 'One Bedroom IL D'>1BILD
					<cfelseif 	Descript is 'One Bedroom IL E'>1BILE	
					<cfelseif 	Descript is 'One Bedroom Deluxe'>1BDX
					<cfelseif 	Descript is 'One Bedroom Premium'>1BP	
					<cfelseif 	Descript is 'One Bedroom Premium Plus'>1BP+	
					<cfelseif 	Descript is 'One Bedroom Premium w/ Patio'>1BPP								
					<cfelseif 	Descript is 'IL One Bedroom'>1BIL
					<cfelseif 	Descript is 'IL Two Bedroom'>2BIL	
					<cfelseif 	Descript is 'Two Bedroom' > 2B
					<cfelseif 	Descript is 'Two Bed Two Bath' > 2B2B	
					<cfelseif 	Descript is 'Two Bed Two Bath Deluxe' > 2B2BDX	
					<cfelseif 	Descript is 'Two Bedroom AL A' > 2BAL 
					<cfelseif 	Descript is 'Two Bedroom IL A' > 2BILA 
					<cfelseif 	Descript is 'Two Bedroom IL B' > 2BILB 
					<cfelseif 	Descript is 'Two Bedroom Premium' > 2BP 				
					<cfelseif 	Descript is 'Two Bedroom Deluxe' > 2BDX		
					<cfelseif 	Descript is 'Alcove'> AL
					<cfelseif 	Descript is 'Deluxe'> DX
					<cfelseif 	Descript is 'Duplex'> DPX
					<cfelseif 	Descript is 'Efficiency' > EFF
					<cfelseif 	Descript is 'Home Health Room' > HHR
					<cfelseif 	Descript is 'Double Room'> DBL
					<cfelseif 	Descript is 'Companion Studio'> CST
					<cfelseif 	Descript is 'Companion Studio Deluxe'> CSD
					<cfelseif 	Descript is 'Companion One Bedroom'> C1B
					<cfelseif 	Descript is 'Companion Two Bedroom'> C2B
					<cfelseif 	Descript is 'Companion Deluxe'> CDX
					<cfelseif 	Descript is 'Companion One Bedroom Premium'>C1BP
					<cfelseif 	Descript is 'Companion Two Bedroom Premium'>C2BP	
					<cfelseif 	Descript is 'MC Studio'>MC-ST
					<cfelseif 	Descript is 'MC Studio Deluxe'>MC-DX
					<cfelseif 	Descript is 'MC Companion Studio'>MC-CST
					<cfelseif 	Descript is 'MC Companion Studio Deluxe'>MC-CSD
					<cfelseif 	Descript is 'MC One Bedroom'>MC-1B
					<cfelseif 	Descript is 'MC Companion One Bedroom'>MC-C1B
					<cfelseif 	Descript is 'MC Two Bedroom'>MC-2B
					<cfelseif 	Descript is 'MC Companion Two Bedroom'>MC-C2B
					<cfelse >#Descript#	
					</cfif>
				</td>
				<td>#solomonkey#</td>
				<td>#firstname# #lastname#</td>
				<td>#dateformat(SPEvaluation,'mm/dd/yyyy')#</td>
				<td>#Spoints#</td>
				<td>#SLevelTypeSet#</td>
				<td>#Acuity#</td>
				<td><cfif firstname is 'Vacant'>&nbsp;<cfelse>#AptProductLineCode#</cfif></td>
				<td style="text-align:left">
					<cfif PrivatePay is 0>&nbsp;  
					<cfelseif PrivatePay is ''>&nbsp;
					<cfelse>
						$#Numberformat(PrivatePay,'_____.__')#
 						<cfset totalPrivatePay = #totalPrivatePay# + 0>	
					</cfif>
				</td>
				<td style="text-align:left"> 
					<cfif ResidentCare is 0>&nbsp;  
					<cfelseif ResidentCare is ''>&nbsp;
					<cfelse>
						$#Numberformat(ResidentCare,'_____.__')#
						 <cfset totalResidentCare = #totalResidentCare# + #ResidentCare#> 						
					</cfif>
				</td>
				<td style="text-align:left">
					<cfif CoPay is 0>&nbsp;  
					<cfelseif CoPay is ''>&nbsp;
					<cfelse>
						$#Numberformat(CoPay,'_____.__')#
						<cfset totalCoPay = #totalCoPay# + #CoPay#>					
					</cfif>
				</td>
				<td style="text-align:left">
					<cfif StateMed is 0>&nbsp;  
					<cfelseif StateMed is ''>&nbsp;
					<cfelse>
						$#Numberformat(StateMed,'_____.__')#
						<cfset totalStateMed = #totalStateMed# + #StateMed#>
					</cfif>
				</td>
				<cfset Othertotal =#Purchases#  + #BeautyShop#+ #Cable# + #Meals# + #Other#>
				<td style="text-align:left">
					<cfif Othertotal is 0>&nbsp;  
					<cfelseif Othertotal is ''>&nbsp;
					<cfelse>
						$#Numberformat(Othertotal,'_____.__')#
						<cfset totalOthertotal = #totalOthertotal# + #Othertotal#>
					</cfif>
				</td>
				
				<td style="text-align:left"> 
					<cfif StdRate is 0>&nbsp; 
					<cfelseif StdRate is ''>&nbsp;
					<cfelse>
						$#Numberformat(StdRate,'_____.__')#
						<cfset totalStdRate = #totalStdRate# + #StdRate#>
					</cfif>
				</td>
				<cfset CurrentRent = #PrivatePay#  + #ResidentCare#  + #CoPay#>
				<cfset totalCurrentRent = #totalCurrentRent# + #CurrentRent#>
				<td style="text-align:left">
					<cfif CurrentRent is 0>&nbsp; 
					<cfelseif #CurrentRent# is ''>&nbsp;
					<cfelse>$#Numberformat(CurrentRent,'_____.__')#
					</cfif>
				</td>
				<cfset totalCharges = #PrivatePay#  +  #ResidentCare#  +  #CoPay# +  #StateMed#  +  #Othertotal#>
				<cfset totalTotalCharges = #totalTotalCharges# + #totalCharges#>
				<td style="text-align:left">
					<cfif totalCharges is 0>&nbsp; 
					<cfelseif totalCharges is ''>&nbsp;
					<cfelse>$#Numberformat(totalCharges,'_____.__')#
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
			<td>&nbsp;</td>
			<td  style="border-top: .5px solid black;">$#Numberformat(totalPrivatePay,'_____.__')#</td>
			<td  style="border-top: .5px solid black;">$#Numberformat(totalResidentCare,'_____.__')#</td>
			<td  style="border-top: .5px solid black;">$#Numberformat(totalCoPay,'_____.__')#</td>
			<td  style="border-top: .5px solid black;">$#Numberformat(totalStateMed,'_____.__')#</td>
			<td  style="border-top: .5px solid black;">$#Numberformat(totalOthertotal,'_____.__')#</td>
			<td  style="border-top: .5px solid black;">$#Numberformat(totalStdRate,'_____.__')#</td>
			<td  style="border-top: .5px solid black;">$#Numberformat(totalCurrentRent,'_____.__')#</td>
			<td  style="border-top: .5px solid black;">$#Numberformat(totalTotalCharges,'_____.__')#</td>
																																								
		</tr>
		
	</table>
</cfoutput>
</body>
</html>
