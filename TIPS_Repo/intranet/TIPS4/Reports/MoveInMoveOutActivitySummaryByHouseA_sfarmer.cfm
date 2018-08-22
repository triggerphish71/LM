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

<cfsavecontent variable="PDFhtml">
<cfheader name="Content-Disposition" 
value="attachment;filename=MoveInMoveOutHouseReport-#sp_HouseMoveInsAndOutsByYear.cname#.pdf">

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
		<Table  width="100%"cellpadding="5";  cellspacing="5">
			<cfoutput  query="sp_HouseMoveInsAndOutsByYear"  group="iActivity_ID">
			<cfif iActivity_ID is 2> 
				<tr style="line-height:100%">
					<td>&nbsp;</td>  
					<td nowrap="nowrap" style="font-size:12px;">
						Move-Ins
					</td>
					
							
				</tr>
			<cfelse>
				<tr style="line-height:100%">
					<td>&nbsp;</td>  
					<td nowrap="nowrap" style="font-size:12px; page-break-before:always">
						 Move-Outs 
					</td>
										
				</tr>	
			</cfif>		
			<cfset reccnt = 0>
			<cfoutput  group="groupperiod">
				<tr style="line-height:100%">
					
					<td nowrap="nowrap" style="font-size:12px;">#dateformat(dtActivity,'yyyymm')#</td>
									
				</tr>
				<tr>
					
					<td style="text-align:center; font-size:10px; border-bottom: .5px solid black; ">
					Solomon Key</td>
					<td style="text-align:center; font-size:10px; border-bottom:  .5px  solid black;">
					Resident</td>
					<td style="text-align:center; font-size:10px; border-bottom: .5px solid black;">
					Apt</td>
					<td style="text-align:center; font-size:10px; border-bottom: .5px solid black;">
					Occ Pos</td>
					<td style="text-align:center; font-size:10px;border-bottom: .5px solid black;">
					Rent Effective<br> Date</td>
					<td style="text-align:center; font-size:10px; border-bottom:  .5px solid black;">
					Entered Date</td>
					<td style="text-align:center; font-size:10px;border-bottom: .5px solid black;">
					Move-Out Date</td>			
					<td style="text-align:center; font-size:10px; border-bottom: .5px solid black;">
					Stay Days</td>	
					<td style="text-align:center; font-size:10px;border-bottom: .5px solid black;">
					Type</td>	
				</tr>

			<cfoutput>
			<cfset reccnt = reccnt + 1>	
			<cfset housereccnt = housereccnt + 1>
			<cfset regionreccnt = regionreccnt + 1>  
			<cfset divreccnt = divreccnt + 1>				
			<tr style="line-height:100%">
				<td>&nbsp;</td>	
				<td>&nbsp;</td>
				<td>&nbsp;</td> 
				<td style="text-align:center; font-size:10px;"> #cSolomonKey# </td>
				<td style="text-align:left; font-size:10px;"> #cTenantName#</td>
				<td style="text-align:center; font-size:10px;">#cAptNumber#</td> 
				<td style="text-align:center; font-size:10px;">#iOccupancyPosition#</td>
				<td style="text-align:center; font-size:10px;">
				#dateformat(dtRentEffective,'mm/dd/yyyy')#
				</td>  
				<td style="text-align:center; font-size:10px;">
				#dateformat(dtEntered,'mm/dd/yyyy')#
				</td>
				<td style="text-align:center; font-size:10px;">
				#dateformat(dtMoveOut,'mm/dd/yyyy')#
				</td>
				<td style="text-align:center; font-size:10px; ">
					<cfif dtMoveOut is not ''> 
					#datediff('d',dtRentEffective,dtMoveOut)#
					<cfelse>
					&nbsp;
					</cfif>
				</td>
				<td style="text-align:center; font-size:10px;">
					<cfif iResidencyType_ID is 1>P
					<cfelseif iResidencyType_ID is 2>M
					<cfelseif iResidencyType_ID is 3>R
					<cfelse>&nbsp;
					</cfif>
				</td>
			</tr>
		</cfoutput>
	</cfoutput>
		<tr>
			<td colspan="12" style="font-size:10px; font-weight:bold">
				<cfif iActivity_ID is 2>
				#sp_HouseMoveInsAndOutsByYear.cname# MoveIns Total: 
				<cfelse>
				#sp_HouseMoveInsAndOutsByYear.cname# MoveOuts Total: 
				</cfif>
				#reccnt#
			</td>
		</tr>
	</cfoutput>

	<cfoutput>
			<tr>
				<td colspan="12" style="font-size:10px; font-weight:bold">
				#sp_HouseMoveInsAndOutsByYear.cName# Total: (#housereccnt# activities)
				</td>
			</tr>
			<tr>
				<td colspan="12" style="font-size:10px; font-weight:bold">
				#sp_HouseMoveInsAndOutsByYear.OpsName# Total: (#regionreccnt# activities)
				</td>
			</tr>
			<tr>
				<td colspan="12" style="font-size:10px; font-weight:bold">
				#sp_HouseMoveInsAndOutsByYear.RegionName# Total: (#divreccnt# activities)
				</td>
			</tr>
		</table>
	</cfoutput>
</cfsavecontent> 
	<cfdocument format="PDF" orientation="portrait" margintop="2" >	
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
