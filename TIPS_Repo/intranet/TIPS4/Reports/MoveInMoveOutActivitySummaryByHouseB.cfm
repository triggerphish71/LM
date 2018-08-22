<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>MoveInMoveOutActivitySummaryByHouse </title> 
</head>
  	<cfparam name="prompt0" default="">
  	<cfparam name="prompt1" default="">	  	
	<cfparam name="prompt2" default="">
  	<cfparam name="prompt3" default="">
  	<cfparam name="prompt4" default="">
			
	<cfquery name="sp_HouseMoveInsAndOutsByYear" datasource="#application.datasource#">
		EXEC  rw.sp_HouseMoveInsAndOutsByYearRpt
			@Scope =   '#prompt0#' ,
			@Period =   '#prompt1#' ,
				@AsOfDate =   '#prompt2#' ,
				 @ActivityType ='#prompt3#' , 
				  @ResidentType ='#prompt4#' 
	</cfquery> 
<!--- 	@Scope =   '#prompt0#' ,
			@Period =   '#prompt1#' ,
				@AsOfDate =   '#prompt2#' ,
				 @ActivityType ='#prompt3#' , 
				  @ResidentType ='#prompt4#'  #sp_HouseMoveInsAndOutsByYear.cname#--->
<!--- <cfoutput><cfdump  var="#sp_HouseMoveInsAndOutsByYear#" label="sp_HouseMoveInsAndOutsByYear"></cfoutput> 
<cfabort> --->
<cfquery name="primarymovein" dbtype="query" >
	Select csolomonkey  
	from sp_HouseMoveInsAndOutsByYear 
	where iresidencytype_Id = 1 and iActivity_ID = 2 and ioccupancyposition = 1
</cfquery>
<cfquery name="primarymoveout" dbtype="query">
	Select csolomonkey   
	from sp_HouseMoveInsAndOutsByYear 
	where  iActivity_ID = 3 and ioccupancyposition = 1
</cfquery>
<cfquery name="primaryactivities" dbtype="query" >
	Select  ctenantname    
	from sp_HouseMoveInsAndOutsByYear 
	where  ioccupancyposition = 1 
</cfquery>
<cfquery name="totalmoveins" dbtype="query" >
	Select csolomonkey   
	from sp_HouseMoveInsAndOutsByYear 
	where  iActivity_ID = 2
</cfquery>
<cfquery name="totalmoveouts" dbtype="query" >
	Select csolomonkey   
	from sp_HouseMoveInsAndOutsByYear 
	where  iActivity_ID = 3
</cfquery>
  <cfquery name="moveins" dbtype="query" >
	Select *    
	from sp_HouseMoveInsAndOutsByYear 
	where  iActivity_ID = 2  
	order by RentEffperiod
</cfquery>
 <cfquery name="moveouts" dbtype="query" >
	Select *    
	from sp_HouseMoveInsAndOutsByYear 
	where  iActivity_ID = 3  
	order by MoveOutperiod
</cfquery> 

<cfsavecontent variable="PDFhtml">
<cfheader name="Content-Disposition" 
value="attachment;filename=MoveInMoveOutHouseReport-#sp_HouseMoveInsAndOutsByYear.cname#-#prompt1#.pdf">

	<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
	<!--- <html xmlns="http://www.w3.org/1999/xhtml"> --->
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
		<title>Move In Move Out House Report</title>
		 <style>
			table{ 
				font-size:0em;
				border-collapse: collapse;
			}
		</style>
	</head>	
	<body>
		<cfset reccnt = 0>
		<cfset housereccnt = 0>
		<cfset regionreccnt = 0> 
		<cfset divreccnt = 0>
		<cfset shorttermmovein = 0>
		<cfset cntmovein = 0>
		<cfset cntmoveout = 0>
		<cfset cntioccupancyposition = 0>

		<Table  width="100%" cellpadding="0";  cellspacing="5">
		<tbody>
			<cfoutput  query="moveins"  group="iActivity_ID">
			<thead>
				<tr style="line-height:100%">
					<td>&nbsp;</td>  
					<td nowrap="nowrap" style="font-size:14px;">
						Move-Ins
					</td>
					<td>&nbsp;</td>
					<td>&nbsp;</td>  
					<td>&nbsp;</td> 
					<td>&nbsp;</td>  
					<td>&nbsp;</td> 
					<td>&nbsp;</td>  
					<td>&nbsp;</td> 
					<td>&nbsp;</td>  
					<td>&nbsp;</td> 
					<td>&nbsp;</td> 					
				</tr>
			</thead>
			<cfoutput  group="RentEffperiod" >
			<cfset reccnt = 0>
				<tr style="line-height:100%">
					<td>&nbsp;</td>  
					<td>&nbsp;</td> 
					<td nowrap="nowrap" style="font-size:14px;">#RentEffperiod#</td>
					<td>&nbsp;</td>  
					<td>&nbsp;</td> 
					<td>&nbsp;</td>  
					<td>&nbsp;</td> 
					<td>&nbsp;</td>  
					<td>&nbsp;</td> 
					<td>&nbsp;</td>  
					<td>&nbsp;</td> 
					<td>&nbsp;</td> 					
				</tr>
				<tr>
					<td>&nbsp;</td>	
					<td>&nbsp;</td>
					<td>&nbsp;</td> 
					<td style="text-align:center; font-size:14px; border-bottom: .5px solid black; ">
					Solomon Key</td>
					<td style="text-align:center; font-size:14px; border-bottom:  .5px  solid black;">
					Resident</td>
					<td style="text-align:center; font-size:14px; border-bottom: .5px solid black;">
					Apt</td>
					<td style="text-align:center; font-size:14px; border-bottom: .5px solid black;">
					Occ Pos</td>
					<td style="text-align:center; font-size:14px;border-bottom: .5px solid black;">
					Rent-Effective Date</td>
					<td style="text-align:center; font-size:14px; border-bottom:  .5px solid black;">
					Entered Date</td>
					<td style="text-align:center; font-size:14px;border-bottom: .5px solid black;">
					Charge<br />Through<br />Date</td>			
					<td style="text-align:center; font-size:14px; border-bottom: .5px solid black;">
					Stay Days</td>	
					<td style="text-align:center; font-size:14px;border-bottom: .5px solid black;">
					Type</td>	
				</tr>

			<cfoutput>
			<cfset reccnt = reccnt + 1>	
			<cfset housereccnt = housereccnt + 1>
			<cfset regionreccnt = regionreccnt + 1>  
			<cfset divreccnt = divreccnt + 1>	
			<cfif iActivity_ID is 2 and dtChargeThrough is not ''  and ((dtChargeThrough - dtmovein) lt 7)>
				<cfset shorttermmovein = shorttermmovein + 1>
			</cfif>	
			<cfif ioccupancyposition is 1>
				<cfset cntioccupancyposition = cntioccupancyposition + 1>
			</cfif>				
			<cfif iActivity_ID is 2> 
			<cfset cntmoveout = cntmoveout + 1>
			<cfelse>	
			<cfset cntmovein= cntmovein + 1>
			</cfif>	
			<tr style="line-height:100%">
				<td>&nbsp;</td>	
				<td>&nbsp;</td>
				<td>&nbsp;</td> 
				<td style="text-align:center; font-size:14px;"> #cSolomonKey# </td>
				<td style="text-align:left; font-size:14px;"> #cTenantName#</td>
				<td style="text-align:center; font-size:14px;">#cAptNumber#</td> 
				<td style="text-align:center; font-size:14px;">#iOccupancyPosition#</td>
				<td style="text-align:center; font-size:14px;">
				#dateformat(dtRentEffective,'mm/dd/yyyy')#
				</td>  
				<td style="text-align:center; font-size:14px;">
				#dateformat(dtEntered,'mm/dd/yyyy')#
				</td>
				<td style="text-align:center; font-size:14px;">
				#dateformat(dtChargeThrough,'mm/dd/yyyy')#
				</td>
				<td style="text-align:center; font-size:14px; ">
					<cfif dtChargeThrough is not ''> 
					#datediff('d',dtRentEffective,dtChargeThrough)#
					<cfelse>
					&nbsp;
					</cfif>
				</td>
				<td style="text-align:center; font-size:14px;">
					<cfif iResidencyType_ID is 1>P
					<cfelseif iResidencyType_ID is 2>M
					<cfelseif iResidencyType_ID is 3>R
					<cfelse>&nbsp;
					</cfif>
				</td>
			</tr>
		</cfoutput>
	</cfoutput>	
	</cfoutput>
	<cfoutput>	 		
		<tr>
			<td colspan="2">&nbsp;</td>
			<td colspan="10" style="font-size:12px; font-weight:bold">
				#sp_HouseMoveInsAndOutsByYear.cname# MoveIns Total:
				 (#totalmoveins.recordcount# Move-ins ,
				  #primarymovein.recordcount# Primary move-ins,
				    #shorttermmovein# Short-stay primary move-ins)
			</td>
		</tr>
	</cfoutput>	
	 
			<thead>
				<tr style="line-height:100%">
					<td>&nbsp;</td>  
					<td nowrap="nowrap" style="font-size:14px; page-break-before:always">
						 Move-Outs 
					</td>
					<td>&nbsp;</td>
					<td>&nbsp;</td>  
					<td>&nbsp;</td> 
					<td>&nbsp;</td>  
					<td>&nbsp;</td> 
					<td>&nbsp;</td>  
					<td>&nbsp;</td> 
					<td>&nbsp;</td>  
					<td>&nbsp;</td> 
					<td>&nbsp;</td> 					
				</tr>	
			</thead>	
			<cfoutput  query="moveouts" group="MoveOutperiod">
			<cfset reccnt = 0>
				<tr style="line-height:100%">
					<td>&nbsp;</td>  
					<td>&nbsp;</td> 
					<td nowrap="nowrap" style="font-size:14px;">#MoveOutperiod#</td>
					<td>&nbsp;</td>  
					<td>&nbsp;</td> 
					<td>&nbsp;</td>  
					<td>&nbsp;</td> 
					<td>&nbsp;</td>  
					<td>&nbsp;</td> 
					<td>&nbsp;</td>  
					<td>&nbsp;</td> 
					<td>&nbsp;</td> 					
				</tr>
				<tr>
					<td>&nbsp;</td>	
					<td>&nbsp;</td>
					<td>&nbsp;</td> 
					<td style="text-align:center; font-size:14px; border-bottom: .5px solid black; ">
					Solomon Key</td>
					<td style="text-align:center; font-size:14px; border-bottom:  .5px  solid black;">
					Resident</td>
					<td style="text-align:center; font-size:14px; border-bottom: .5px solid black;">
					Apt</td>
					<td style="text-align:center; font-size:14px; border-bottom: .5px solid black;">
					Occ Pos</td>
					<td style="text-align:center; font-size:14px;border-bottom: .5px solid black;">
					Rent-Effective Date</td>
					<td style="text-align:center; font-size:14px; border-bottom:  .5px solid black;">
					Entered Date</td>
					<td style="text-align:center; font-size:14px;border-bottom: .5px solid black;">
					Charge<br />Through<br />Date</td>			
					<td style="text-align:center; font-size:14px; border-bottom: .5px solid black;">
					Stay Days</td>	
					<td style="text-align:center; font-size:14px;border-bottom: .5px solid black;">
					Type</td>	
				</tr>

			<cfoutput>
			<cfset reccnt = reccnt + 1>	
			<cfset housereccnt = housereccnt + 1>
			<cfset regionreccnt = regionreccnt + 1>  
			<cfset divreccnt = divreccnt + 1>	
			<cfif iActivity_ID is 2 and dtChargeThrough is not ''  and ((dtChargeThrough - dtmovein) lt 7)>
				<cfset shorttermmovein = shorttermmovein + 1>
			</cfif>	
			<cfif ioccupancyposition is 1>
				<cfset cntioccupancyposition = cntioccupancyposition + 1>
			</cfif>				
			<cfif iActivity_ID is 2> 
			<cfset cntmoveout = cntmoveout + 1>
			<cfelse>	
			<cfset cntmovein= cntmovein + 1>
			</cfif>	
			<tr style="line-height:100%">
				<td>&nbsp;</td>	
				<td>&nbsp;</td>
				<td>&nbsp;</td> 
				<td style="text-align:center; font-size:14px;"> #cSolomonKey# </td>
				<td style="text-align:left; font-size:14px;"> #cTenantName#</td>
				<td style="text-align:center; font-size:14px;">#cAptNumber#</td> 
				<td style="text-align:center; font-size:14px;">#iOccupancyPosition#</td>
				<td style="text-align:center; font-size:14px;">
				#dateformat(dtRentEffective,'mm/dd/yyyy')#
				</td>  
				<td style="text-align:center; font-size:14px;">
				#dateformat(dtEntered,'mm/dd/yyyy')#
				</td>
				<td style="text-align:center; font-size:14px;">
				#dateformat(dtChargeThrough,'mm/dd/yyyy')#
				</td>
				<td style="text-align:center; font-size:14px; ">
					<cfif dtChargeThrough is not ''> 
					#datediff('d',dtRentEffective,dtChargeThrough)#
					<cfelse>
					&nbsp;
					</cfif>
				</td>
				<td style="text-align:center; font-size:14px;">
					<cfif iResidencyType_ID is 1>P
					<cfelseif iResidencyType_ID is 2>M
					<cfelseif iResidencyType_ID is 3>R
					<cfelse>&nbsp;
					</cfif>
				</td>
			</tr>
		</cfoutput>
	</cfoutput>
	<cfoutput>	 		
		<tr>
			<td colspan="2">&nbsp;</td>
			<td colspan="10" style="font-size:12px; font-weight:bold">
				#sp_HouseMoveInsAndOutsByYear.cname# MoveOuts Total: 
				(#totalmoveouts.recordcount# Move-outs ,
				 #primarymoveout.recordcount# Primary Move-outs)
			</td>
		</tr>
	</cfoutput>
<cfif sp_HouseMoveInsAndOutsByYear.csolomonkey is not ''>
	<cfoutput>
			<tr>
				<td colspan="2">&nbsp;</td>			
				<td colspan="10" style="font-size:14px; font-weight:bold">
				#sp_HouseMoveInsAndOutsByYear.cName# Total: 
				 (#sp_HouseMoveInsAndOutsByYear.recordcount# Activities,
				 #primaryactivities.recordcount# Primary Activities,
				  #shorttermmovein# Short Stay Primary Move-ins)
				</td>
			</tr>
<!--- 			<tr>
			<td colspan="1">&nbsp;</td>			
				<td colspan="11" style="font-size:14px; font-weight:bold">
				#sp_HouseMoveInsAndOutsByYear.OpsName# Total:
				 (#sp_HouseMoveInsAndOutsByYear.recordcount# Activities,
				 #primaryactivities.recordcount# Primary Activities,
				  #shorttermmovein# Short Stay Primary Move-ins)
				</td>
			</tr> --->
<!--- 			<tr>
				<td colspan="12" style="font-size:14px; font-weight:bold">
				#sp_HouseMoveInsAndOutsByYear.RegionName# Total:
				 (#sp_HouseMoveInsAndOutsByYear.recordcount# Activities,
				 #primaryactivities.recordcount# Primary Activities,
				  #shorttermmovein# Short Stay Primary Move-ins)
				</td>
			</tr> --->

<!--- 			<tr>
				<td colspan="12" style="font-size:14px; font-weight:bold">
				Grand Total:
				 (#sp_HouseMoveInsAndOutsByYear.recordcount# Activities,
				 #primaryactivities.recordcount# Primary Activities,
				  #shorttermmovein# Short Stay Primary Move-ins)
				</td>
			</tr> --->	
		<tbody>	
		</table>
	</cfoutput>
	</cfif>
 
</cfsavecontent> 
	<cfdocument format="PDF" orientation="portrait" margintop="2" marginleft="0" >	
	<cfdocumentsection>
		<cfdocumentitem type="header" >  
			<table width="100%">
				<tr>
					<td> <img src="../../images/Enlivant_logo.jpg"/></td>
					<td align="center">
					<h1 style="text-align:center">MOVE-IN/MOVE-OUT ACTIVITY SUMMARY BY HOUSE</h1>
					</td>					
				</tr>
			<cfoutput query="sp_HouseMoveInsAndOutsByYear" group="RegionNumber">
				<tr><td colspan="2"><h2>#RegionName#</td></h2></tr>
				<cfoutput  group="OpsNumber">
					<tr><td colspan="2"><h2>&nbsp;&nbsp;#OpsName#</h2></td></tr>
					<cfoutput group="cNumber">
						<tr><td colspan="2"><h2>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#cname#</h2></td></tr>
					</cfoutput>	
				</cfoutput>	
			</cfoutput> 	
		<cfif sp_HouseMoveInsAndOutsByYear.recordcount is 1 and sp_HouseMoveInsAndOutsByYear.csolomonkey is ''>
		<table>
			<tr>
				<td>
				<cfoutput>
					No Activity for 	Period #prompt1#, <cfif #prompt4# is 'M'> Medicaid
					<cfelseif #prompt4# is 'P'> Private
					<cfelseif #prompt4# is 'R'>Respite
					<cfelse> All Residents</cfif>
					<!--- 	@AsOfDate =   '#prompt2#' ,
					@ActivityType ='#prompt3#' , 
					@ResidentType ='#prompt4# --->
				</cfoutput>
				</td>
			</tr>
		</table>
 
		</cfif>	
		</table>	
		</cfdocumentitem> 
		<cfoutput>
			#variables.PDFhtml#
		</cfoutput>		
			<cfdocumentitem  type="footer"  evalAtPrint="true">
				<cfoutput>
					<table  width="95%">
						<tr>
							<td colspan="3" style="font-size:small;text-align:right">
							Page: #cfdocument.currentpagenumber# of #cfdocument.totalpagecount#
							</td>
						</tr>
						<cfif #cfdocument.currentpagenumber# is #cfdocument.totalpagecount#>
							<tr>
								<td style="font-size:small; text-align:left" >
								MoveInMoveoutActivitySummaryByHouse.rpt
								</td>
								<td style="font-size:small; text-align:center">
								Use only as authorized by Enlivant&trade;
								</td>
								<td style="font-size:small; text-align:right">
								Printed: #dateformat(now(), 'mm/dd/yyyy')#
								</td>
							</tr> 
						</cfif>			
					</table>		
				</cfoutput>
			</cfdocumentitem>
	</cfdocumentsection>
</cfdocument>
</body>
</html>
