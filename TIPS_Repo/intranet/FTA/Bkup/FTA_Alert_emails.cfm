<!--- -------------------------------------------------------------|
|  2014-04-09  Ganga Thota - created for RCP email alerts          |
|                                                                  |
--------------------------------------------------------------- --->
<cfset today = now()> 
<cfset date = #DateFormat(now(), "yyyy-mmm-dd")#>
<cfset Lastdate = #DateAdd( 'd', -1, now())#>
<cfset period = #DateFormat(now(), "yyyymm")#>

<cfquery name="PSAalert" datasource="FTA">
	SELECT  cDivisionName
			,cRegionName
			,cHouseName
			,iHouseId
			,cPeriod
			,dtCreated
			,fBudget
			,fActual
			,cAlertDesc
			,dtFromDate
			,dtToDate	
			,dtLastUpdate
			,dtRowDeleted
			,cflag
			,cDisplayname	        
	  FROM  
	       EmailAlertsData
	 WHERE  
	        dtRowDeleted is null AND cflag = 1
	 ORDER BY  
	       cDivisionName, cRegionName
</cfquery>
<!---<cfdump var="#PSAalert#">--->
<cfquery name="Overtimealert" datasource="FTA">
    SELECT  cDivisionName
			,cRegionName
			,cHouseName
			,iHouseId
			,cPeriod
			,dtCreated
			,fBudget
			,fActual
			,cAlertDesc
			,dtFromDate
			,dtToDate	
			,dtLastUpdate
			,dtRowDeleted
			,cflag
			,cDisplayname	        
	  FROM  
	       EmailAlertsData
	 WHERE  
	       cAlertDesc = '7 Day OverTime Alert' 
		   AND dtCreated > getdate()-1 
		   AND dtRowDeleted is null AND cflag = 1
	 ORDER BY  
	       cDivisionName ,cRegionName
</cfquery>

<cfquery name="EA_PSA" datasource="FTA">
  SELECT cDayscalculation FROM AlertCalculation WHERE cAlertTypeId = 1 AND dtrowdeleted is null
</cfquery>
<cfquery name="EA_OverTime" datasource="FTA">
  SELECT cDayscalculation FROM AlertCalculation WHERE cAlertTypeId = 2 AND dtrowdeleted is null
</cfquery>


 <cfoutput>

<!--- <cfset email = "cPhillips@enlivant.com, dguill@enlivant.com, gthota@enlivant.com, tbates@enlivant.com, skannukkaden@enlivant.com, _ALC5DVPGroup@enlivant.com,_AllRgnlDirofOperations@enlivant.com">--->
 <!---<cfset email = "gthota@enlivant.com">--->

 <!---<cfmail to="#email#"   from="FTA@enlivant.com" subject="FTA RCP Alert > 64 hours" type="html">  --->
	  <h3>The FTA Email Alerts .</h3>
	  <font color="##3300FF"> Today's Date : #date# </font>
	  <table border="1">
			  <tr>
				  <td colspan='3' style="font-weight: bold; background-color: ##D7D7D7; text-decoration: underline;"><font color="##3300FF"> FTA Variable Budget PSA Details </font></td> 
			  </tr>
			  <tr> 
				   <td><b> Division </b></td><td><b>Region</b></td><td><b>House Name</b></td><td><b>Alert Type</b></td><td><b>Department</b></td><td><b>From Date</b></td><td><b>To Date</b></td><td><b>&nbsp;Actual&nbsp;</b></td>
			  </tr>
			<cfloop query="PSAalert">
				<tr>
					<td>#PSAalert.cDivisionName#</td>
					<td>#PSAalert.cRegionName#</td>                
					<td>#PSAalert.cHouseName#</td>
					<td>#PSAalert.cAlertDesc#</td>
					<td>#PSAalert.cDisplayname#</td>				
					<td>#DateFormat(PSAalert.dtFromDate, "yyyy-mm-dd")# &nbsp;</td>
					<td>#DateFormat(PSAalert.dtToDate, "yyyy-mm-dd")# &nbsp;</td>
					<td align="center"><font color="<cfif PSAalert.fActual gt PSAalert.fBudget>Black<cfelse>red</cfif>">#numberformat(PSAalert.fActual, "0.0")#</font></td>
					<!---<td align="center">#numberformat(PSAalert.fBudget, "0.0")#</td>--->
					<!---<td align="center"><!---<font color="<cfif PSAalert.fActual gt PSAalert.fBudget>red<cfelse>Black</cfif>">--->#numberformat((PSAalert.fBudget - PSAalert.fActual), "0.0")#</td>--->
				</tr>
			</cfloop>
	  </table>
	  <br/><br/>
	  <hr><br/>
	  Do not reply to this email, as this email box is not monitored.  
 <!--- </cfmail>--->
  <br/>
  
 <!--- <cfmail to="#email#"   from="FTA@enlivant.com" subject="FTA OverTime Budget Alert - #EA_OverTime.cDayscalculation# Days Avg" type="html"> --->
	   <h3>The FTA budget Alert, Average Overtime last 7 days > 1 hour per day. </h3>
		<font color="##3399CC"> Today's Date : #date# </font>
	  <table border="1">
			  <tr>
				  <td colspan='3' style="font-weight: bold; background-color: ##D7D7D7; text-decoration: underline;"><font color="##3399CC"> FTA Budget overtime Details </font></td>
			  </tr>
			  <tr> 
				  <td><b> Division </b></td><td><b>Region</b></td><td><b>House Name</b></td><td><b>Alert Type</b></td><td><b>From Date</b></td><td><b>To Date</b></td><td><b>Average</b></td>
			  </tr>
			 <cfloop query="Overtimealert">
				<tr>
					<td>#Overtimealert.cDivisionName#</td>
					<td>#Overtimealert.cRegionName#</td>                
					<td>#Overtimealert.cHouseName#</td>
					<td>#Overtimealert.cAlertDesc#</td>
					<td>#DateFormat(Overtimealert.dtFromDate, "yyyy-mm-dd")# &nbsp;</td>
					<td>#DateFormat(Overtimealert.dtToDate, "yyyy-mm-dd")# &nbsp;</td>
					<td align="center"><font color="##CC0000">#numberformat(Overtimealert.fActual, "0.00")#</font></td>
				 </tr>
			 </cfloop>
	  </table>
	  <br/><br/>
	  <hr><br/>
	  Do not reply to this email, as this email box is not monitored. 
<!---  </cfmail>--->
 
 </cfoutput>
