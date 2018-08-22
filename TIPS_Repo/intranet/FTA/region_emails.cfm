<!----------------------------------------------------------------------------------------------
| DESCRIPTION                                                                                  |
|----------------------------------------------------------------------------------------------|
|                                                                                              |
|----------------------------------------------------------------------------------------------|
| STORED PROCEDURES                                                                            |
|----------------------------------------------------------------------------------------------|
|  none                                                                                        |
|----------------------------------------------------------------------------------------------|
| INCLUDES                                                                                     |
|----------------------------------------------------------------------------------------------|
|  none                                                                                        |
|----------------------------------------------------------------------------------------------|
| HISTORY                                                                                      |
|----------------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                        |
|------------|------------|--------------------------------------------------------------------|
| gthota    | 08/26/2014 | sending FTA emails alerts to all regional RDO's                     |
----------------------------------------------------------------------------------------------->

<!--- create a param for qldap.mail because this function always excpets it to be populated --->
<!--- <cfparam name="qldap.mail" default="mlaw@alcco.com"> --->
<cfparam name="qldap.mail" default="cfdevelopers@enlivant.com">
<!---<cfset attributes.ihouse_id  = 191> ---> 
<cfset today = now()> 
<cfset date = #DateFormat(now(), "yyyy-mmm-dd")#>
<cfset Lastdate = #DateAdd( 'd', -1, now())#>
<cfset period = #DateFormat(now(), "yyyymm")#>

<!---<cfset ldp="ldap">
<cfset ldpass="paulLDAP939">--->
<cfoutput>
 
	<cfquery name="qRDO" datasource="TIPS4">
		SELECT r.iOpsArea_ID, R.CNAME REGION, E.LNAME+ ' ' +E.FNAME RDO, e.email,r.iregion_id FROM dbo.OPSAREA R 
	     INNER JOIN ALCWEB.DBO.EMPLOYEES E ON R.IDIRECTORUSER_ID = E.EMPLOYEE_NDX 
          WHERE r.dtrowdeleted is null and r.iRegion_id in (1,2,4,14) order by r.iregion_id
	</cfquery>



<cfloop query="qRDO">

<cfquery name="qHouseIDs" datasource="TIPS4">
 SELECT iHouse_id FROM House 
    Where iOpsArea_ID = #qRDO.iOpsArea_ID# AND dtrowdeleted is null
</cfquery>
<cfset houseid = valuelist(qHouseIDs.iHouse_id,',')>
<!---House list = #houseid#--->
<cfif qHouseIDs.recordcount NEQ 0>

<cfquery name="daysOT" datasource="FTA">
SELECT  *	        
	  FROM  
	       EmailAlertsData
	 WHERE  cAlertDesc IN('7 Day OverTime Alert')  AND iHouseId IN (#houseid#)	      
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
	 WHERE  cAlertDesc IN('Over Budget')  AND iHouseId IN (#houseid#)	      
	      AND dtRowDeleted is null 
		  AND cflag = 1 
		  AND fovertime60 is not null
	 ORDER BY  
	       cDivisionName, cRegionName,chousename ,cAlertDesc,cdisplayname
</cfquery>

<cfquery name="days_prev_OT" datasource="FTA">
SELECT  *	        
	  FROM  
	       EmailAlertsData_Prev
	 WHERE  cAlertDesc IN('OverTime Hours')	 AND iHouseId IN (#houseid#)      
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
	 WHERE  cAlertDesc IN('Over Budget')  AND iHouseId IN (#houseid#)	      
	      AND dtRowDeleted is null 
		  AND cflag = 1 
		  AND fovertime60 is not null
	 ORDER BY  
	       cDivisionName, cRegionName,chousename ,cAlertDesc,cdisplayname
</cfquery>
</cfif>
<cfif qRDO.email NEQ 0> 
<!---<cfmail to="#qldap.mail#" from="FTA@enlivant.com" subject="FTA Labor Alerts." type="html">--->
<cfif daysOB.recordcount NEQ 0>
<!---<cfdocument format="pdf" name="FTAOverBudget">--->
 <h3>  <font color="##0000FF">The FTA Over Budget Alerts - 7/30/60 days Avg. </font></h3>
		<font color="##3399CC"> Today's Date : #date# </font>
	  <table border="1">
			  <tr>
				  <td colspan='3' style="font-weight: bold; background-color: ##D7D7D7; text-decoration: underline;"><font color="##3399CC"> FTA Over Budget Alert Details ! </font></td>
			  </tr>
			  <tr bgcolor="##FFFF66"> 
				  <td><b> Division </b></td>
				  <td><b>Region</b></td>
				  <td><b>Community</b></td>
				  <td><b>Department</b></td>
				  <td><b>Alert Type</b></td
				  ><td><b>From Date</b></td>
				  <td><b>60 days Avg</b></td>
				  <td><b>30 days Avg</b></td>
				  <td><b>7 Days Avg</b></td>
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
	 <!---</cfdocument>--->	
	</cfif> 
<cfif daysOT.recordcount NEQ 0>
<!---<cfdocument format="pdf" name="FTAOvertime">--->
 <h3> <font color="##0000FF">FTA OverTime Alert - 7/30/60 Days Avg. </font></h3>
		<font color="##3399CC"> Today's Date : #date# </font>
	  <table border="1">
			  <tr>
				  <td colspan='3' style="font-weight: bold; background-color: ##D7D7D7; text-decoration: underline;"><font color="##3399CC"> FTA Budget overtime Details </font></td>
			  </tr>
			  <tr bgcolor="##FFFF66"> 
				  <td><b>Division </b></td>
				  <td><b>Region</b></td>
				  <td><b>Community</b></td>
				  <td><b>Department</b></td>
				  <td><b>Alert Type</b></td>
				  <td><b>From Date</b></td>
				  <td><b>60 days Avg</b></td>
				  <td><b>30 days Avg</b></td>
				  <td><b>7 Days Avg</b></td>
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
	<!--- </cfdocument>	--->	 
	 </cfif>
 
<cfif days_prev_OB.recordcount NEQ 0>
<!---<cfdocument format="pdf" name="FTAPreviousday_OB">--->
 <h3> <font color="##0000FF"> FTA Labor Over Budget Alerts prev day. </font></h3>
		<font color="##3399CC"><b> Today's Date : #date# </b></font>
	   <table border="1">
			  <tr>
				  <td colspan='3' style="font-weight: bold; background-color: ##D7D7D7; text-decoration: underline;"><font color="##3399CC"> FTA Previous day Over Budget. </font></td>
			  </tr>
			  <tr bgcolor="##FFFF66"> 
				  <td><b>Division </b></td> <td><b>Region</b></td>  <td><b>Community</b></td>  <td><b>Department</b></td>  <td><b>Alert Type</b></td>
				  <td><b>From Date</b></td> <td><b>To Date</b>   <td><b>Prev Day</b></td>
			  </tr>
			
			  <cfloop query="days_prev_OB">
				<tr BGCOLOR="###IIF(days_prev_OB.currentrow MOD 2, DE('E6E6E6'), DE('C0C0C0'))#">
					<td>#days_prev_OB.cDivisionName#</td>
					<td>#days_prev_OB.cRegionName# &nbsp;</td>                
					<td>#days_prev_OB.cHouseName# &nbsp;</td>
					<td>#days_prev_OB.cDisplayname# &nbsp;</td>
					<td>#days_prev_OB.cAlertDesc# &nbsp;</td>
					<td>#DateFormat(days_prev_OB.dtFromDate, "yyyy-mm-dd")# &nbsp;</td>
					<td>#DateFormat(days_prev_OB.dttoDate, "yyyy-mm-dd")# &nbsp;</td>					
					<td align="center"><font color="##CC0000">#numberformat(days_prev_OB.fActual, "0.00")#</font></td>
				 </tr>
			 </cfloop>			
	  </table> 
<!---</cfdocument> --->
</cfif>
<cfif days_prev_OT.recordcount NEQ 0>
<!---<cfdocument format="pdf" name="FTApreviousday_OT">--->
<h3> <font color="##0000FF"> FTA Labor Over Time Alerts prev day. </font></h3>
		<font color="##3399CC"><b> Today's Date : #date# </b></font>
	   <table border="1">
			  <tr>
				  <td colspan='3' style="font-weight: bold; background-color: ##D7D7D7; text-decoration: underline;"><font color="##3399CC"> FTA Previous day Over Time. </font></td>
			  </tr>
			  <tr bgcolor="##FFFF66"> 
				  <td><b>Division </b></td> <td><b>Region</b></td>  <td><b>Community</b></td>  <td><b>Department</b></td>  <td><b>Alert Type</b></td>
				  <td><b>From Date</b></td> <td><b>To Date</b>   <td><b>Prev Day</b></td>
			  </tr>
			
			  <cfloop query="days_prev_OT">
				<tr BGCOLOR="###IIF(days_prev_OT.currentrow MOD 2, DE('E6E6E6'), DE('C0C0C0'))#">
					<td>#days_prev_OT.cDivisionName#</td>
					<td>#days_prev_OT.cRegionName# &nbsp;</td>                
					<td>#days_prev_OT.cHouseName# &nbsp;</td>
					<td>#days_prev_OT.cDisplayname# &nbsp;</td>
					<td>#days_prev_OT.cAlertDesc# &nbsp;</td>
					<td>#DateFormat(days_prev_OT.dtFromDate, "yyyy-mm-dd")# &nbsp;</td>
					<td>#DateFormat(days_prev_OT.dttoDate, "yyyy-mm-dd")# &nbsp;</td>
					<td align="center"><font color="##CC0000">#numberformat(days_prev_OT.fActual, "0.00")#</font></td>
				 </tr>
			 </cfloop>			
	  </table> 
	  <hr><br/>
	  <font color="##FF0000"> Do not reply to this email, as this email box is not monitored. </font>
<!---</cfdocument> --->
</cfif>
<!---</cfmail>--->
<!---<cfelse>
<cfif qldap.mail NEQ 0 and qhouses.ihouse_id eq 220>

</cfif>--->
<!---<cfmail to="#qldap.mail#" cc="gthota@enlivant.com" from="FTA@enlivant.com" subject="FTA Labor Alerts." type="html">  <!---  to="gthota@enlivant.com,tbates@enlivant.com"--->
<cfmailparam   file="FTAOvertime.pdf"    type="application/pdf" content="#FTAOvertime#" />
<cfmailparam   file="FTAOverBudget.pdf"    type="application/pdf" content="#FTAOverBudget#" />
<cfmailparam   file="FTApreviousday_OT.pdf"    type="application/pdf" content="#FTApreviousday_OT#" />
<cfmailparam   file="FTAPreviousday_OB.pdf"    type="application/pdf" content="#FTAPreviousday_OB#" />
<br/>
<br/>
  <td colspan='3' style="font-weight: bold; background-color: ##D7D7D7; text-decoration: underline;"><font color="##3399CC"> FTA Labor Alerts Details of Over Time and Over Budget. </font></td>			
<hr><br/>
	 <font color="##FF0000"> Do not reply to this email, as this email box is not monitored. </font>
</cfmail>--->
</cfif>  

</cfloop>


</cfoutput>
