<!--- -----------------------------------------------------------------------------|
|  2014-08-26  Ganga Thota - created DVP email alerts for FTA budget               |
----------------------------------------------------------------------------------->
<cfset today = now()> 
<cfset date = #DateFormat(now(), "yyyy-mmm-dd")#>
<cfset Lastdate = #DateAdd( 'd', -1, now())#>
<cfset period = #DateFormat(now(), "yyyymm")#>

<cfoutput>
<cfquery name="DVP_mail" datasource="TIPS4">
   SELECT d.iRegion_ID as regionid, D.CNAME DIVISION, E.LNAME+ ' ' +E.FNAME DVP, e.email as email FROM dbo.REGION D
	 INNER JOIN ALCWEB.DBO.EMPLOYEES E ON D.IVPUSER_ID = E.EMPLOYEE_NDX
	 WHERE d.dtrowdeleted is null
</cfquery>

<cfloop query="DVP_mail">
<cfquery name="daysOT" datasource="FTA">
SELECT  *	        
	  FROM  
	       EmailAlertsData
	 WHERE  cAlertDesc IN('7 Day OverTime Alert') AND cDivisionName = '#DVP_mail.DIVISION#'	      
	      AND dtRowDeleted is null 
		  AND cflag = 1 
		  AND fovertime60 is not null
	 ORDER BY  
	       cDivisionName, cRegionName,chousename ,cAlertDesc,cdisplayname
</cfquery>

<cfquery name="daysOB" datasource="FTA">
SELECT  *	        
	  FROM  
	       EmailAlertsData
	 WHERE  cAlertDesc IN('Over Budget') AND cDivisionName = '#DVP_mail.DIVISION#'		      
	      AND dtRowDeleted is null 
		  AND cflag = 1 
		  AND fovertime60 is not null
	 ORDER BY  
	       cDivisionName, cRegionName,chousename ,cAlertDesc,cdisplayname
</cfquery>

<!---<cfquery name="days_prev_OT" datasource="FTA">
SELECT  *	        
	  FROM  
	       EmailAlertsData_Prev
	 WHERE  cAlertDesc IN('OverTime Hours')	 AND cDivisionName = '#DVP_mail.DIVISION#'	     
	      AND dtRowDeleted is null 
		  AND cflag = 1 
		  AND fovertime60 is not null
	 ORDER BY  
	       cDivisionName, cRegionName,chousename ,cAlertDesc,cdisplayname
</cfquery>
<cfquery name="days_prev_OB" datasource="FTA">
SELECT  *	        
	  FROM  
	       EmailAlertsData_Prev
	 WHERE  cAlertDesc IN('Over Budget') AND cDivisionName = '#DVP_mail.DIVISION#'		      
	      AND dtRowDeleted is null 
		  AND cflag = 1 
		  AND fovertime60 is not null
	 ORDER BY  
	       cDivisionName, cRegionName,chousename ,cAlertDesc,cdisplayname
</cfquery>--->


 
 <!---<cfset email = "gthota@enlivant.com">--->
	 
<!---  PDF files of FTA email Alerts--->
<cfif daysOT.recordcount GT 0>
<cfdocument format="pdf" name="FTAOvertime">
  <h3> <font color="##0000FF"> FTA Labor Over Time Alerts. </font></h3>
		<font color="##3399CC"><b> Today's Date : #date# </b></font>
	  <table border="1">
			  <tr>
				  <td colspan='3' style="font-weight: bold; background-color: ##D7D7D7; text-decoration: underline;"><font color="##3399CC"> FTA Labor Alerts Details of Over Time.</font></td>
			  </tr>
			  <tr bgcolor="##FFFF66"> 
				  <td><b>Division </b></td> <td><b>Region</b></td>  <td><b>Community</b></td>  <td><b>Department</b></td>  <td><b>Alert Type</b></td>
				  <td><b>From Date</b></td>  <td><b>60 days Avg</b></td> <td><b>30 days Avg</b></td>  <td><b>7 Days Avg</b></td>
			  </tr>
			
			 <cfloop query="daysOT">
				<tr BGCOLOR="###IIF(daysOT.currentrow MOD 2, DE('E6E6E6'), DE('C0C0C0'))#">
					<td>#daysOT.cDivisionName#</td>
					<td>#daysOT.cRegionName# &nbsp;</td>                
					<td>#daysOT.cHouseName# &nbsp;</td>
					<td>#daysOT.cDisplayname# &nbsp;</td>
					<td>#daysOT.cAlertDesc# &nbsp;</td>
					<td>#DateFormat(daysOT.dtFromDate, "yyyy-mm-dd")# &nbsp;</td>
					<td align="center">#numberformat(daysOT.fovertime60, "0.00")#&nbsp;</td>
					<td align="center">#numberformat(daysOT.fovertime30, "0.00")#&nbsp;</td>
					<td align="center"><font color="##CC0000">#numberformat(daysOT.fActual, "0.00")#</font></td>
				 </tr>
			 </cfloop>
			
	  </table> 
	  <br/><br/>
</cfdocument>
</cfif>
<cfif daysOB.Recordcount GT 0>
<cfdocument format="pdf" name="FTAOverBudget">	
 <h3> <font color="##0000FF"> FTA Labor Over Budget Alerts. </font></h3>
		<font color="##3399CC"><b> Today's Date : #date# </b></font>
	   <table border="1">
			  <tr>
				  <td colspan='3' style="font-weight: bold; background-color: ##D7D7D7; text-decoration: underline;"><font color="##3399CC"> FTA Labor Alerts Details of Over Budget. </font></td>
			  </tr>
			  <tr bgcolor="##FFFF66"> 
				  <td><b>Division </b></td> <td><b>Region</b></td>  <td><b>Community</b></td>  <td><b>Department</b></td>  <td><b>Alert Type</b></td>
				  <td><b>From Date</b></td>  <td><b>60 days Avg</b></td> <td><b>30 days Avg</b></td>  <td><b>7 Days Avg</b></td>
			  </tr>
			
			  <cfloop query="daysOB">
				<tr BGCOLOR="###IIF(daysOB.currentrow MOD 2, DE('E6E6E6'), DE('C0C0C0'))#">
					<td>#daysOB.cDivisionName#</td>
					<td>#daysOB.cRegionName# &nbsp;</td>                
					<td>#daysOB.cHouseName# &nbsp;</td>
					<td>#daysOB.cDisplayname# &nbsp;</td>
					<td>#daysOB.cAlertDesc# &nbsp;</td>
					<td>#DateFormat(daysOB.dtFromDate, "yyyy-mm-dd")# &nbsp;</td>
					<td align="center">#numberformat(daysOB.fovertime60, "0.00")#&nbsp;</td>
					<td align="center">#numberformat(daysOB.fovertime30, "0.00")#&nbsp;</td>
					<td align="center"><font color="##CC0000">#numberformat(daysOB.fActual, "0.00")#</font></td>
				 </tr>
			 </cfloop>			
	  </table> 
	  <!---<hr><br/>
	 <font color="##FF0000"> Do not reply to this email, as this email box is not monitored. </font>---> 
	</cfdocument>
</cfif>
<cfmail to="#DVP_mail.email#" from="FTA@enlivant.com" subject="FTA Labor Alerts." type="html">  <!--- to="#DVP_mail.email#" --->
<cfmailparam   file="FTAOvertime.pdf"    type="application/pdf" content="#FTAOvertime#" />
<cfmailparam   file="FTAOverBudget.pdf"    type="application/pdf" content="#FTAOverBudget#" />
<br/><br/>
  <td colspan='3' style="font-weight: bold; background-color: ##D7D7D7; text-decoration: underline;"><font color="##3399CC"> FTA Labor Alerts Details of Over Time and Over Budget. </font></td>			
<hr><br/>
	 <font color="##FF0000"> Do not reply to this email, as this email box is not monitored. </font>
</cfmail>

</cfloop>
 </cfoutput>



