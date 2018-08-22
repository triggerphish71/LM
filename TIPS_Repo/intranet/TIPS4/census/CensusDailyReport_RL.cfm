<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>CensusDailyReport</title>
</head>
<cfparam name="prompt0" default="">
<cfparam name="prompt1" default="">

<cfquery name="checkhouse" datasource="#application.datasource#">
	select * from [dbo].[RL_RES_STG]	WHERE ToHouseID = #SESSION.qSelectedHouse.iHouse_ID#
</cfquery>	

<CFQUERY NAME="HouseData" DATASOURCE="#APPLICATION.datasource#">
	SELECT	H.iHouse_ID, h.cName, H.cNumber, OA.cNumber as OPS, R.cNumber as Region
	FROM	House H
	JOIN	OPSArea OA	ON	OA.iOPSArea_ID = H.iOPSArea_ID
	JOIN	Region R	ON	OA.iRegion_ID = R.iRegion_ID
	WHERE	iHouse_ID = #checkhouse.toHouseID#	
	  AND	H.dtrowdeleted is NULL
	  AND	H.bisSandbox = 0
</CFQUERY>
<cfset prompt0 = #HouseData.ihouse_id#>

<cfset dtcompare = prompt1> <!--- #dateformat(now(),'mm/dd/yyyy')#> --->
<cfquery name="spdailycensus" DATASOURCE="#APPLICATION.datasource#">
		EXEC dbo.sp_dailycensus_RL
		@ihouse_id = #HouseData.ihouse_id#,
		@period = '#dtcompare#'
</cfquery>
<body>

	<cfdocument  format="PDF" orientation="portrait" margintop="2" marginbottom="1" marginleft=".5" marginright=".5">
		<cfdocumentitem type="header"  evalAtPrint="true">
			<cfoutput>
				<table width="100%">
					<tr>
						<td align="center">
							<h1 style="text-align:center; text-decoration:underline;">#HouseData.cname#<br /> Relocated Residents Daily Census Report<br />Date: #dateformat(dtcompare,'mmmm dd, yyyy')#</h1>
						</td>
					</tr>			
				</table>
				</cfoutput>
			<cfoutput>
			<table width="100%" cellpadding="3" cellspacing="4">
			<tbody>
			<colgroup>
				<col span="1" style="width: 5%;"> 
				<col span="1" style="width: 9%;">	
				<col span="1" style="width: 11%;"> 
				<col span="1" style="width: 11%;">	
				<col span="1" style="width: 11%;"> 
				<col span="1" style="width: 9%;">	
				<col span="1" style="width: 9%;"> 
				<col span="1" style="width: 11%;">	
			<!---	<col span="1" style="width: 11%;">	--->								
			</colgroup>
			<tr>
				<td valign="bottom"  style="border: 2px solid black; text-align: center; font-weight:bold;" >Room</td>
				<td valign="bottom" style="border: 2px solid black; text-align: center; font-weight:bold;" >Tenant ID</td>
				<td valign="bottom" style="border: 2px solid black; text-align: center; font-weight:bold;" >
				Resident's Name</td>
			<!---	<td valign="bottom" style="border: 2px solid black; text-align: center; font-weight:bold;" >MoveIn Date</td> --->
				<td valign="bottom"  style="border: 2px solid black; text-align: center; font-weight:bold;">From House</td> <!--- Payor Type --->
				<td valign="bottom"  style="border: 2px solid black; text-align: center; font-weight:bold;" >
					Previous<br /> 
					Day<br /> 
					Status <br />
					(Y/N)<br />
					#dateformat(spdailycensus.Previousdate,'mm/dd/yyyy')#</td>
				<td valign="bottom"  style="border: 2px solid black; text-align: center; font-weight:bold;"  >
					Current<br />
					Status in<br /> 
					Bed<br /> 
					@Midnight<br />
					(Y/N)<br />
					#dateformat(spdailycensus.currentdate,'mm/dd/yyyy')#</td>
				<td valign="bottom"  style="border: 2px solid black; text-align: center; font-weight:bold;">
				Expected<br />Date of <br  />Move Out</td> 
				<td valign="bottom"  style="border: 2px solid black; text-align: center; font-weight:bold;">
				Expected<br />Date of <br  />Return</td>
			<!---	<td valign="bottom"  style="border: 2px solid black; text-align: center; font-weight:bold;">From House</td> --->
			</tr>
			</tbody>
			</table>
			</cfoutput>
	</cfdocumentitem>
	<cfoutput>
		<table width="100%" cellpadding="3" cellspacing="4"  style="empty-cells:show;">
			<tbody>
				<colgroup>
					<col span="1" style="width: 5%;"> 
					<col span="1" style="width: 9%;">	
					<col span="1" style="width: 11%;"> 
					<col span="1" style="width: 11%;">	
					<col span="1" style="width: 5%;"> 
					<col span="1" style="width: 5%;">	
					<col span="1" style="width: 9%;"> 
					<col span="1" style="width: 11%;">	
				<!---	<col span="1" style="width: 20%;">--->									
				</colgroup>		
				<cfloop query="spdailycensus">
					<tr>
						<td style="border: 1px solid black; text-align: center; font-size:10px;">#AptNbr#</td>
						<cfif Tenant is 0>
							<td  style="color:##FFFFFF;border: 1px solid black;">.</td>
						<cfelse>
							<td style="border: 1px solid black; text-align: center; font-size:10px;">
							#Tenant#
							</td>
						</cfif>
						
						<cfif trim(lastname) is ''>
							<td  style=" color:##FFFFFF;border: 1px solid black;">.</td>
						<cfelse>
							<td style="border: 1px solid black; font-size:10px;">
							#trim(lastname)#, #trim(Firstname)# 
							</td>
						</cfif>
						
					<!---	<cfif Movein is '01/01/1900'>
							<td  style=" color:##FFFFFF;border: 1px solid black;">.</td>
						<cfelse>
							<td style="border: 1px solid black; text-align: center; font-size:10px;">
							#dateformat(Movein,'mm/dd/yyyy')#
							</td>
						</cfif> --->
						
						<cfif trim(Type) is ''>
							<td  style=" color:##FFFFFF;border: 1px solid black;">.</td>
						<cfelse>
							<td style="border: 1px solid black; text-align: center; font-size:10px;">
							<!---#Type# ---> #HouseName#
							</td>
						</cfif>
						
						<cfif trim(PreviousStatus) is ''>
							<td  style=" color:##FFFFFF;border: 1px solid black;">.</td>
						<cfelse>
							<td style="border: 1px solid black; text-align: center; font-size:10px;">
							#PreviousStatus#</td>
						</cfif>
						
						<cfif trim(currentstatus) is ''>
							<td  style=" color:##FFFFFF;border: 1px solid black;">.</td>
						<cfelse>			
							<td style="border: 1px solid black; text-align: center; font-size:10px;">
							#currentstatus#
							</td>
						</cfif>
						
						<cfif Dischargedate is '01/01/1900'  or Dischargedate is ' ' or trim(Dischargedate) is ''>
							<td  style=" color:##FFFFFF;border: 1px solid black;">.</td>
						<cfelse>
							<td style="border: 1px solid black; text-align: center; font-size:10px;">
							#dateformat(Dischargedate,'mm/dd/yyyy')#
							</td>
						</cfif>			
						
						<cfif Returndate is '01/01/1900' or Returndate is ' ' or trim(Returndate) is ''>
							<td  style="color:##FFFFFF;border: 1px solid black;">.</td>
						<cfelse>
							<td style="border: 1px solid black; text-align: center; font-size:10px;">
							#dateformat(Returndate,'mm/dd/yyyy')#
							</td>
						<!---	<td style="border: 1px solid black; text-align: center; font-size:10px;">#HouseName#</td> --->
							
						</cfif>	
					</tr>
				</cfloop> 
			</tbody>
		</table> 
	</cfoutput>		
	<cfdocumentitem  type="footer" evalAtPrint="true">
			<table width="100%" style="border-bottom:1px solid black;; border-right:1px solid black;; border-left:1px solid black;; border-top:1px solid black;">
					<tr>
						<td style=" font-weight:bold;">Event Codes:</td>
					</tr>	
					<tr>
						<td style=" font-weight:bold;">Temp (HT - Hospital Temp, OT - Other Temp, HO - Home, SNF)</td>
					</tr>
					<tr>
						<td style=" font-weight:bold;">Perm (HP - Hospital Perm, OP - Other Perm, D - Death, E - Eviction)</td>
					</tr>	
					<tr>
						<td style=" font-weight:bold;">&nbsp;&nbsp;&nbsp;&nbsp; (CA - Competitor ALF, SA - Sister ALF, HO - Home, SNF)</td>
					</tr>				
			</table>
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
									CensusDailyReport_RL.cfm
							</td>
						</tr>
					</cfif>
				</cfoutput>
			</table>
	</cfdocumentitem>

 	<cfoutput>  	
		<cfheader name="Content-Disposition"   
 		value="attachment;filename=DailyCensus-#HouseData.cname#-#prompt1#.pdf"> 
	</cfoutput>			

</cfdocument>
</body>
</html>
