<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<!--- 
-------------------------------------------------------------------------------------------------------------------
| Project Nbr.  | Date        | Chagnged By   |   Description of change                                           |
-------------------------------------------------------------------------------------------------------------------
|               | 04/04/2017  |       S Farmer| changed "Move Out Date" to "Physical Move Out Date"               |
|               |             |               |                                                                   |
-------------------------------------------------------------------------------------------------------------------
 --->
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
<cfquery name="moveIn" dbtype="query" >
	Select *  
	from sp_HouseMoveInsAndOutsByYear 
	where iActivity_ID = 2 order by dtrenteffective
</cfquery>
<cfquery name="moveOut" dbtype="query" >
	Select *  
	from sp_HouseMoveInsAndOutsByYear 
	where iActivity_ID = 3 order by dtmoveout
</cfquery>

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
 <cfset whichpart = 'Move Ins'>
<!--- <cfsavecontent variable="PDFhtml">

 
</cfsavecontent> ---> 
	<cfdocument format="PDF" orientation="portrait" margintop="2" marginleft="0" >	
	<cfdocumentsection>
		<cfdocumentitem type="header" >  
			<Table  width="100%" cellpadding="1";  cellspacing="1">
				<tr>
					<td> <img src="../../images/Enlivant_logo.jpg"/></td>
					<td align="center">
					<h1 style="text-align:center">MOVE-IN/MOVE-OUT ACTIVITY SUMMARY BY HOUSE</h1>
					</td>					
				</tr>
				<cfoutput>
					<tr>
						<td colspan="2"><h1>#sp_HouseMoveInsAndOutsByYear.RegionName#</h1></td>
					</tr>
					<tr>
						<td colspan="2"><h1>&nbsp;&nbsp;#sp_HouseMoveInsAndOutsByYear.OpsName#</h1></td>
					</tr>
					<tr>
						<td colspan="2"><h1>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#sp_HouseMoveInsAndOutsByYear.cname#</h1></td>
					</tr>
				</cfoutput> 	
			</table>
		<cfif sp_HouseMoveInsAndOutsByYear.recordcount is 1 and sp_HouseMoveInsAndOutsByYear.csolomonkey is ''>
			<Table  width="100%" cellpadding="1";  cellspacing="1"  >
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
		<Table  width="100%" cellpadding="1";  cellspacing="1" >
			<colgroup>
				<col span="1" style="width:  10%;">
				<col span="1" style="width:  7%;">
				<col span="1" style="width:  10%;">	
				<col span="1" style="width: 19%;">
				<col span="1" style="width:  8%;">
				<col span="1" style="width: 8%;">
				<col span="1" style="width:  9%;">
				<col span="1" style="width: 9%;">
				<col span="1" style="width: 8%;">
				<col span="1" style="width:  8%;">
				<col span="1" style="width: 4%;">
			</colgroup>		
<!---  				<tr>
					<cfoutput><td colspan="11" style="text-align:center; "><h1>#whichpart#</h1></td></cfoutput>
				</tr> --->
				<tr>
					<td style="text-align:center; border-bottom: .5px solid black;"><h1>Activity</h1></td>
					<td style="text-align:center; border-bottom: .5px solid black;"><h1>Period</h1></td> 
					<td style="text-align:center; border-bottom: .5px solid black;"><h1>Solomon<br /> Key</h1></td>
					<td style="text-align:center; border-bottom: .5px solid black;"><h1>Resident</h1></td>
					<td style="text-align:center; border-bottom: .5px solid black;"><h1>A<br />P<br />T</h1></td>
					<td style="text-align:center; border-bottom: .5px solid black;"><h1>P<br />O<br />S</h1></td>
				<td style="text-align:center; border-bottom: .5px solid black;"><h1>Rent<br />Effective<br />Date</h1></td>
					<td style="text-align:center; border-bottom: .5px solid black;"><h1>Entered<br />Date</h1></td>
					<td style="text-align:center; border-bottom: .5px solid black;"><h1>Physical<br />Move Out<br />Date</h1></td>			
					<td style="text-align:center; border-bottom: .5px solid black;"><h1>Stay<br/>Days</h1></td>	
					<td style="text-align:center; border-bottom: .5px solid black;"><h1>T<br />Y<br />P<br />E</h1></td>	
				</tr>			
<!--- <cfoutput> <tr><td>#moveIn.recordcount# :: #moveIn.iactivity_ID# -- #sp_HouseMoveInsAndOutsByYear.recordcount# :: #sp_HouseMoveInsAndOutsByYear.iactivity_id# --#moveout.recordcount#:: #moveout.iactivity_id#</td></tr></cfoutput> --->
	</Table>
	</cfdocumentitem> 
	<!--- 	<cfoutput> --->
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

		<Table  width="100%" cellpadding="1";  cellspacing="1">
			<colgroup>
				<col span="1" style="width:  8%;">
				<col span="1" style="width:  7%;">
				<col span="1" style="width: 10%;">	
				<col span="1" style="width: 19%;">
				<col span="1" style="width:  8%;">
				<col span="1" style="width:  8%;">
				<col span="1" style="width:  8%;">
				<col span="1" style="width:  8%;">
				<col span="1" style="width:  8%;">
				<col span="1" style="width:  7%;">
				<col span="1" style="width:  8%;">
			</colgroup>			
			<tr >
				<td colspan="1" nowrap="nowrap" style="font-size:small" >Move-Ins</td>
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
			<cfoutput  query="moveIn"  group="RentEffperiod">
			<cfset reccnt = 0>
				<tr >
					<td>&nbsp;</td> 
					<td nowrap="nowrap"  style="font-size:small" >#RentEffperiod#</td>
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
			<cfoutput>
			<cfset reccnt = reccnt + 1>	
			<cfset housereccnt = housereccnt + 1>
			<cfset regionreccnt = regionreccnt + 1>  
			<cfset divreccnt = divreccnt + 1>	
			<cfif iActivity_ID is 2 and dtmoveout is not ''  and ((dtmoveOut - dtmovein) lt 7)>
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
			<tr >
				<td>&nbsp;</td>
				<td>&nbsp;</td>
				<td style="text-align:center;font-size:small">#cSolomonKey# </td>
				<td style="text-align:left;  font-size:small">#trim(cTenantName)#</td>
				<td style="text-align:center;font-size:small">#cAptNumber#</td> 
				<td style="text-align:center;font-size:small">#iOccupancyPosition#</td>
				<td style="text-align:center;font-size:small">#dateformat(dtRentEffective,'mm/dd/yyyy')#</td>  
				<td style="text-align:center;font-size:small">#dateformat(dtEntered,'mm/dd/yyyy')#</td>
				<td style="text-align:center;font-size:small">#dateformat(dtMoveOut,'mm/dd/yyyy')#</td>
				<td style="text-align:center;font-size:small">
					<cfif dtMoveOut is not ''> 
					#datediff('d',dtRentEffective,dtMoveOut)#
					<cfelse>
					&nbsp;
					</cfif>
				</td>
				<td style="text-align:center;font-size:small">
					<cfif iResidencyType_ID is 1>P
					<cfelseif iResidencyType_ID is 2>M
					<cfelseif iResidencyType_ID is 3>R
					<cfelse>&nbsp;
					</cfif>
				</td>
			</tr>
			<cfset reccnt = reccnt + 1>	
			<cfset housereccnt = housereccnt + 1>
			<cfset regionreccnt = regionreccnt + 1>  
			<cfset divreccnt = divreccnt + 1>	
			<cfif iActivity_ID is 2 and dtmoveout is not ''  and ((dtmoveOut - dtmovein) lt 7)>
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
		</cfoutput>
	</cfoutput>
		<cfoutput>		
			<tr>
				<td>&nbsp;</td>
				<td>&nbsp;</td>		
				<td>&nbsp;</td>					
				<td colspan="8" style="font-weight:bold;font-size:large">
					#sp_HouseMoveInsAndOutsByYear.cname# MoveIns Total:
					 (#totalmoveins.recordcount# Move-ins ,
					  #primarymovein.recordcount# Primary move-ins,
						#shorttermmovein# Short-stay primary move-ins)
				</td>
			</tr>
		</cfoutput>
		<cfset whichpart = 'Move Out'>
		<tr><td colspan="11"  style=" page-break-before:always;">&nbsp;</td></tr>	
		<tr>
			<td colspan="1" nowrap="nowrap" style="font-size:medium">Move-Outs</td>
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
	<cfoutput query="moveOut" group="MoveOutperiod">
		<tr >
			<td>&nbsp;</td> 
			<td style="font-size:small">#MoveOutperiod#</td>
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
		<cfset reccnt = 0>
 		<cfoutput>
			<cfset reccnt = reccnt + 1>	
			<cfset housereccnt = housereccnt + 1>
			<cfset regionreccnt = regionreccnt + 1>  
			<cfset divreccnt = divreccnt + 1>	
			<cfif iActivity_ID is 2 and dtmoveout is not ''  and ((dtmoveOut - dtmovein) lt 7)>
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
			<tr>
				<td colspan="1">&nbsp;</td>
				<td colspan="1">&nbsp;</td> 
				<td style="text-align:center;font-size:small">#cSolomonKey# </td>
				<td style="text-align:left;font-size:small">#cTenantName#</td>
				<td style="text-align:center;font-size:small">#cAptNumber#</td> 
				<td style="text-align:center;font-size:small">#iOccupancyPosition#</td>
				<td style="text-align:center;font-size:small">#dateformat(dtRentEffective,'mm/dd/yyyy')#</td>  
				<td style="text-align:center;font-size:small">#dateformat(dtEntered,'mm/dd/yyyy')#</td>
				<td style="text-align:center;font-size:small">#dateformat(dtMoveOut,'mm/dd/yyyy')#</td>
				<td style="text-align:center;font-size:small">
					<cfif dtMoveOut is not ''> 
					#datediff('d',dtRentEffective,dtMoveOut)#
					<cfelse>
					&nbsp;
					</cfif>
				</td>
				<td style="text-align:center;font-size:small">
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
			<td>&nbsp;</td>
			<td>&nbsp;</td>		
			<td>&nbsp;</td>					
			<td colspan="8" style="font-weight:bold;font-size:small">
				#sp_HouseMoveInsAndOutsByYear.cname# MoveOuts Total: 
				(#totalmoveouts.recordcount# Move-outs ,
				 #primarymoveout.recordcount# Primary Move-outs)
			</td>
		</tr>
	</cfoutput>
<cfif sp_HouseMoveInsAndOutsByYear.csolomonkey is not ''>
	<cfoutput>
			<tr>
				<td>&nbsp;</td>		
				<td>&nbsp;</td>	
					
				<td colspan="9" style="font-weight:bold;font-size:small">
				#sp_HouseMoveInsAndOutsByYear.cName# Total: 
				 (#sp_HouseMoveInsAndOutsByYear.recordcount# Activities,
				 #primaryactivities.recordcount# Primary Activities,
				  #shorttermmovein# Short Stay Primary Move-ins)
				</td>
			</tr>
<!--- 			<tr>
				<td>&nbsp;</td>	
				<td>&nbsp;</td>		
				<td colspan="9" style="font-weight:bold;font-size:small">
				#sp_HouseMoveInsAndOutsByYear.OpsName# Total:
				 (#sp_HouseMoveInsAndOutsByYear.recordcount# Activities,
				 #primaryactivities.recordcount# Primary Activities,
				  #shorttermmovein# Short Stay Primary Move-ins)
				</td>
			</tr>
			<tr>
				<td>&nbsp;</td>			
				<td colspan="10" style="font-weight:bold;font-size:small">
				#sp_HouseMoveInsAndOutsByYear.RegionName# Total:
				 (#sp_HouseMoveInsAndOutsByYear.recordcount# Activities,
				 #primaryactivities.recordcount# Primary Activities,
				  #shorttermmovein# Short Stay Primary Move-ins)
				</td>
			</tr>

			<tr>
				<td colspan="11" style="font-weight:bold;font-size:small">
				Grand Total:
				 (#sp_HouseMoveInsAndOutsByYear.recordcount# Activities,
				 #primaryactivities.recordcount# Primary Activities,
				  #shorttermmovein# Short Stay Primary Move-ins)
				</td>
			</tr> --->	
	 
		</table>
	</cfoutput>
	</cfif>
			<cfdocumentitem  type="footer"  evalAtPrint="true">
				<cfoutput>
					<Table  width="100%" cellpadding="1";  cellspacing="1" >
						<tr>
							<td colspan="3" style="font-size:small;text-align:right">
							Page: #cfdocument.currentpagenumber# of #cfdocument.totalpagecount#
							</td>
						</tr>
						<cfif #cfdocument.currentpagenumber# is #cfdocument.totalpagecount#>
							<tr>
								<td style="font-size:small; text-align:left" >
								MoveInMoveoutActivitySummaryByHouse
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
	</body></cfdocumentsection>
</cfdocument>

</html>
