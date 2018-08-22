<!--- -----------------------------------------------------------------------------|
|  2017-05-22  Ganga Thota - created for FTA Houseid missing data alerts           |
|  2017-05-22  Ganga Thota - Added sql statement for missing houseid,              |
                              paycode and tracking categoryid                      |
----------------------------------------------------------------------------------->
<cfset today = now()> 
<cfset date = #DateFormat(now(), "yyyy-mmm-dd")#>
<cfset Lastdate = #DateAdd( 'd', -1, now())#>
<cfset period = #DateFormat(now(), "yyyymm")#>

<cfset dsn = "TIPS4">
<cfset dsn2 = "FTA">

<cfquery name="daysOT" datasource="FTA">
SELECT iDailyLaborTrackingDataId,iLaborTrackingCategoryId,cDepartmentNumber,fHours,cPayCode,dtApplyDate,iHouseId,dtCreated
  FROM dbo.DailyLaborTrackingData
  where (iLaborTrackingCategoryId = 0 AND cDepartmentNumber NOT IN ('RCP','MEDASTMC','RCPLEAD','MEDASST','MDASTNOC','RCC','RCPNOC','RCPMC','RCS','CRSM','RN','ASSTCHEF','CHEF','LEADCOOK','DSM','DSAMC','LFENRTL','LEASSTMC','LECMC',
	                'LEADHK','MNTECH','RMT','AED','RECEPTN','BOM','BOC','ADMASST','RSA','SMC','CRMB','CRM','CONCRGE','DSGM','MGRASST'))
         OR cPayCode is null OR cPayCode = '0'  OR ihouseid is null OR ihouseid = 0
     <!--- AND dtApplyDate between '' AND ''--->
</cfquery>



 <cfoutput>


 
<!---  FTA email Alerts for missing houseid in excel file--->
<cfif daysOT.recordcount GT 0>
<cfdocument format="pdf" name="FTAhouseid">
  
  <h3> <font color="##0000FF"> FTA houseid's missing in UTA Alert. - TIPS Upgrade testing </font></h3>
		<font color="##3399CC"><b> Today's Date : #date# </b></font>
	  <table>
			  <tr>
				  <td colspan='3' style="font-weight: bold; background-color: ##D7D7D7; text-decoration: underline;"><font color="##3399CC"> FTA house id's Alerts Daily report.</font></td>
			  </tr>
			  <tr bgcolor="##FFFF66"> 
				  <td><b>DailyLaborTrackingDataId</b></td> 
				  <td><b>LaborTrackingCategoryId</b></td>  
				  <td><b>DepartmentNumber</b></td> 
				  <td><b>Hours</b></td>  
				  <td><b>PayCode</b></td>
				  <td><b>ApplyDate</b></td>  
				  <td><b>HouseId</b></td> 
				  <td><b>HouseName</b></td>
				  <td><b>Created</b></td>  
			  </tr>
			
			 <cfloop query="daysOT">
			 <cfif ihouseId GT ''>
			  <cfquery name="qhouse" datasource="#dsn#">
					 SELECT cname
						FROM dbo.House					 	
						WHERE ihouse_id = #ihouseId# 					
				</cfquery>
			 </cfif>			
				<tr BGCOLOR="###IIF(daysOT.currentrow MOD 2, DE('E6E6E6'), DE('C0C0C0'))#">
					<td>#daysOT.iDailyLaborTrackingDataId#</td>
					<td>#daysOT.iLaborTrackingCategoryId# &nbsp;</td>                
					<td>#daysOT.cDepartmentNumber# &nbsp;</td>
					<td>#daysOT.fHours# &nbsp;</td>
					<td>#daysOT.cPayCode# &nbsp;</td>
					<td>#DateFormat(daysOT.dtApplyDate, "mm-dd-yyyy")# &nbsp;</td>
					<td align="center"><Cfif iHouseId NEQ ''> #iHouseId#&nbsp;<cfelse>null</cfif> </td>
					<td align="center"><Cfif iHouseId NEQ ''>#qhouse.cname#<cfelse>null </cfif> </td>
					<td align="center">#DateFormat(daysOT.dtCreated, "mm-dd-yyyy")#&nbsp;</td>					
				 </tr>
			 </cfloop>
			
	  </table> 
	  <br/><br/>
	  <hr><br/>
</cfdocument>
</cfif>

<!--- <cfset email = "gthota@enlivant.com,tbates@enlivant.com"> --->
 <cfset email = "gthota@enlivant.com">

 
<cfmail to="#email#" from="FTA@enlivant.com" subject="FTA missing houseid's Daily Alert. - TIPS Upgrade testing " type="html"> 
<cfmailparam   file="FTAhouseid.pdf"    type="application/pdf" content="#FTAhouseid#" />

<br/><br/>
  <td colspan='3' style="font-weight: bold; background-color: ##D7D7D7; text-decoration: underline;"><font color="##3399CC"> FTA Missing Houseid's Daily Alert Details. </font></td>			
<hr><br/>
	 <font color="##FF0000"> Do not reply to this email, as this email box is not monitored. </font>
</cfmail>

 </cfoutput>
