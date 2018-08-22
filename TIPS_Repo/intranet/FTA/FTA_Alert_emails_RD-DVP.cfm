<!--- -----------------------------------------------------------------------------|
|  2014-04-09  Ganga Thota - created for RCP email alerts                          |
|  2014-06-27  Ganga Thota - Created over budget/ cook/training overtime alerts    |
----------------------------------------------------------------------------------->
<cfset today = now()> 
<cfset date = #DateFormat(now(), "yyyy-mmm-dd")#>
<cfset Lastdate = #DateAdd( 'd', -1, now())#>
<cfset period = #DateFormat(now(), "yyyymm")#>

<cfquery name="FTA_Dvp" datasource="TIPS4">	
	SELECT d.iRegion_ID as regionid, D.CNAME DIVISION, E.LNAME+ ' ' +E.FNAME DVP, e.email as email FROM dbprod01.TIPS4.dbo.REGION D
	 INNER JOIN dbprod01.ALCWEB.DBO.EMPLOYEES E ON D.IVPUSER_ID = E.EMPLOYEE_NDX
	 WHERE d.dtrowdeleted is null
</cfquery> 
<cfquery name="FTA_rd" datasource="TIPS4">	
	SELECT r.iOpsArea_ID, R.CNAME REGION, E.LNAME+ ' ' +E.FNAME RDO, e.email,r.iregion_id FROM dbprod01.TIPS4.dbo.OPSAREA R 
	 INNER JOIN dbprod01.ALCWEB.DBO.EMPLOYEES E ON R.IDIRECTORUSER_ID = E.EMPLOYEE_NDX 
     WHERE r.dtrowdeleted is null and r.iRegion_id in (1,2,4,14) order by r.iregion_id
</cfquery> 

<cfquery name="Overtimealert2" datasource="FTA">
    SELECT  *        
	  FROM  
	       EmailAlertsData
	 WHERE  
	       cAlertDesc = 'OverTime Hours' 
		   AND dtCreated > getdate()-1 
		   AND dtRowDeleted is null AND cflag = 1
	 ORDER BY  
	       cDivisionName, cRegionName,chousename,cAlertDesc,cdisplayname
</cfquery>

<cfquery name="daysOTOB" datasource="FTA">
SELECT  *	        
	  FROM  
	       EmailAlertsData
	 WHERE  cAlertDesc IN('7 Day OverTime Alert','Over Budget','OverTime Hours')	      
	      AND dtRowDeleted is null 
		  AND cflag = 1 
		  AND fovertime60 is not null
	 ORDER BY  
	       cDivisionName, cRegionName,chousename ,cAlertDesc,cdisplayname
</cfquery>

 <cfoutput>  
         <cfloop query="FTA_Dvp"> 
			   <cfif FTA_Dvp.regionid EQ 1> <cfset email_1 =  #FTA_Dvp.email# > </cfif>
			   <cfif FTA_Dvp.regionid EQ 2> <cfset email_2 = #FTA_Dvp.email# > </cfif>
			   <cfif FTA_Dvp.regionid EQ 4> <cfset email_3 = #FTA_Dvp.email# > </cfif>
			   <cfif FTA_Dvp.regionid EQ 14> <cfset email_4 = #FTA_Dvp.email# > </cfif>
		  </cfloop>         
     <cfloop query="FTA_rd">
	        <cfif FTA_rd.iOpsArea_ID EQ 27> <cfset email_11 = #FTA_rd.email# > </cfif>
			<cfif FTA_rd.iOpsArea_ID EQ 44> <cfset email_12 = #FTA_rd.email# > </cfif>
			<cfif FTA_rd.iOpsArea_ID EQ 45> <cfset email_13 = #FTA_rd.email# > </cfif>
			<cfif FTA_rd.iOpsArea_ID EQ 47> <cfset email_14 = #FTA_rd.email# > </cfif>
			
			<cfif FTA_rd.iOpsArea_ID EQ 3> <cfset email_21 = #FTA_rd.email# > </cfif>
			<cfif FTA_rd.iOpsArea_ID EQ 6> <cfset email_22 = #FTA_rd.email# > </cfif>
			<cfif FTA_rd.iOpsArea_ID EQ 37> <cfset email_23 = #FTA_rd.email# > </cfif>
			<cfif FTA_rd.iOpsArea_ID EQ 38> <cfset email_24 = #FTA_rd.email# > </cfif>
			<cfif FTA_rd.iOpsArea_ID EQ 39> <cfset email_25 = #FTA_rd.email# > </cfif>
			
			<cfif FTA_rd.iOpsArea_ID EQ 23> <cfset email_31 = #FTA_rd.email# > </cfif>
			<cfif FTA_rd.iOpsArea_ID EQ 26> <cfset email_32 = #FTA_rd.email# > </cfif>
			<cfif FTA_rd.iOpsArea_ID EQ 41> <cfset email_33 = #FTA_rd.email# > </cfif>
			<cfif FTA_rd.iOpsArea_ID EQ 42> <cfset email_34 = #FTA_rd.email# > </cfif>
			<cfif FTA_rd.iOpsArea_ID EQ 43> <cfset email_35 = #FTA_rd.email# > </cfif>
			<cfif FTA_rd.iOpsArea_ID EQ 48> <cfset email_36 = #FTA_rd.email# > </cfif>
			
			<cfif FTA_rd.iOpsArea_ID EQ 29> <cfset email_41 = #FTA_rd.email# > </cfif>
			<cfif FTA_rd.iOpsArea_ID EQ 31> <cfset email_42 = #FTA_rd.email# > </cfif>
			<cfif FTA_rd.iOpsArea_ID EQ 40> <cfset email_43 = #FTA_rd.email# > </cfif>
	 </cfloop>

 
<!--- <cfmail to="#email_1#"   from="FTA@enlivant.com" subject="FTA Email Alert. " type="html">--->
 <h3> <font color="##0000FF"> FTA Labor Alerts. </font></h3>
		<font color="##3399CC"><b> Today's Date : #date# </b></font>
	  <table border="1">
			  <tr>
				  <td colspan='3' style="font-weight: bold; background-color: ##D7D7D7; text-decoration: underline;"><font color="##3399CC"> FTA Labor Alerts Details. </font></td>
			  </tr>
			  <tr bgcolor="##FFFF66"> 
				  <td><b>Division </b></td> <td><b>Region</b></td>  <td><b>Community</b></td>  <td><b>Department</b></td>  <td><b>Alert Type</b></td>
				  <td><b>From Date</b></td>  <td><b>60 days Avg</b></td> <td><b>30 days Avg</b></td>  <td><b>7 Days Avg</b></td>
			  </tr>
			
			 <cfloop query="daysOTOB"><cfif daysOTOB.cDivisionName eq 'Central'>
				<tr BGCOLOR="###IIF(daysOTOB.currentrow MOD 2, DE('E6E6E6'), DE('C0C0C0'))#">
					<td>#daysOTOB.cDivisionName#</td>
					<td>#daysOTOB.cRegionName# &nbsp;</td>                
					<td>#daysOTOB.cHouseName# &nbsp;</td>
					<td>#daysOTOB.cDisplayname# &nbsp;</td>
					<td>#daysOTOB.cAlertDesc# &nbsp;</td>
					<td>#DateFormat(daysOTOB.dtFromDate, "yyyy-mm-dd")# &nbsp;</td>
					<td align="center">#numberformat(daysOTOB.fovertime60, "0.00")#&nbsp;</td>
					<td align="center">#numberformat(daysOTOB.fovertime30, "0.00")#&nbsp;</td>
					<td align="center"><font color="##CC0000">#numberformat(daysOTOB.fActual, "0.00")#</font></td>
				 </tr></cfif>
			 </cfloop>
			 <!--- FTA OverTime Hours previous day Alert. --->
			  <cfloop query="Overtimealert2"><cfif Overtimealert2.cDivisionName eq 'Central'>
				<tr BGCOLOR="###IIF(Overtimealert2.currentrow MOD 2, DE('E6E6E6'), DE('C0C0C0'))#">
					<td>#Overtimealert2.cDivisionName#</td>
					<td>#Overtimealert2.cRegionName#</td>                
					<td>#Overtimealert2.cHouseName#</td>
					<td>#Overtimealert2.cDisplayname# &nbsp;</td>
					<td>#Overtimealert2.cAlertDesc#</td>
					<td>#DateFormat(Overtimealert2.dtFromDate, "yyyy-mm-dd")# &nbsp;</td>
					<!---<td>#DateFormat(Overtimealert2.dtToDate, "yyyy-mm-dd")# &nbsp;</td>--->
					<td align="center">-</td>
					<td align="center">-</td>
					<td align="center"><font color="##CC0000">#numberformat(Overtimealert2.fActual, "0.00")#</font></td>
				 </tr></cfif>
			 </cfloop>
	  </table> 
	  <br/><br/>
	  <hr><br/>
	 <font color="##FF0000"> Do not reply to this email, as this email box is not monitored. </font>
	<!---</cfmail>--->
	
<!--- <cfmail to="#email_2#"   from="FTA@enlivant.com" subject="FTA Email Alert. " type="html">--->
 <h3> <font color="##0000FF"> FTA Labor Alerts. </font></h3>
		<font color="##3399CC"><b> Today's Date : #date# </b></font>
	  <table border="1">
			  <tr>
				  <td colspan='3' style="font-weight: bold; background-color: ##D7D7D7; text-decoration: underline;"><font color="##3399CC"> FTA Labor Alerts Details. </font></td>
			  </tr>
			  <tr bgcolor="##FFFF66"> 
				  <td><b>Division </b></td> <td><b>Region</b></td>  <td><b>Community</b></td>  <td><b>Department</b></td>  <td><b>Alert Type</b></td>
				  <td><b>From Date</b></td>  <td><b>60 days Avg</b></td> <td><b>30 days Avg</b></td>  <td><b>7 Days Avg</b></td>
			  </tr>
			
			 <cfloop query="daysOTOB"><cfif daysOTOB.cDivisionName eq 'East'>
				<tr BGCOLOR="###IIF(daysOTOB.currentrow MOD 2, DE('E6E6E6'), DE('C0C0C0'))#">
					<td>#daysOTOB.cDivisionName#</td>
					<td>#daysOTOB.cRegionName# &nbsp;</td>                
					<td>#daysOTOB.cHouseName# &nbsp;</td>
					<td>#daysOTOB.cDisplayname# &nbsp;</td>
					<td>#daysOTOB.cAlertDesc# &nbsp;</td>
					<td>#DateFormat(daysOTOB.dtFromDate, "yyyy-mm-dd")# &nbsp;</td>
					<td align="center">#numberformat(daysOTOB.fovertime60, "0.00")#&nbsp;</td>
					<td align="center">#numberformat(daysOTOB.fovertime30, "0.00")#&nbsp;</td>
					<td align="center"><font color="##CC0000">#numberformat(daysOTOB.fActual, "0.00")#</font></td>
				 </tr></cfif>
			 </cfloop>
			 <!--- FTA OverTime Hours previous day Alert. --->
			  <cfloop query="Overtimealert2"><cfif Overtimealert2.cDivisionName eq 'East'>
				<tr BGCOLOR="###IIF(Overtimealert2.currentrow MOD 2, DE('E6E6E6'), DE('C0C0C0'))#">
					<td>#Overtimealert2.cDivisionName#</td>
					<td>#Overtimealert2.cRegionName#</td>                
					<td>#Overtimealert2.cHouseName#</td>
					<td>#Overtimealert2.cDisplayname# &nbsp;</td>
					<td>#Overtimealert2.cAlertDesc#</td>
					<td>#DateFormat(Overtimealert2.dtFromDate, "yyyy-mm-dd")# &nbsp;</td>
					<!---<td>#DateFormat(Overtimealert2.dtToDate, "yyyy-mm-dd")# &nbsp;</td>--->
					<td align="center">-</td>
					<td align="center">-</td>
					<td align="center"><font color="##CC0000">#numberformat(Overtimealert2.fActual, "0.00")#</font></td>
				 </tr></cfif>
			 </cfloop>
	  </table> 
	  <br/><br/>
	  <hr><br/>
	 <font color="##FF0000"> Do not reply to this email, as this email box is not monitored. </font>
	<!---</cfmail>--->

<!--- <cfmail to="#email_3#"   from="FTA@enlivant.com" subject="FTA Email Alert. " type="html">--->
 <h3> <font color="##0000FF"> FTA Labor Alerts. </font></h3>
		<font color="##3399CC"><b> Today's Date : #date# </b></font>
	  <table border="1">
			  <tr>
				  <td colspan='3' style="font-weight: bold; background-color: ##D7D7D7; text-decoration: underline;"><font color="##3399CC"> FTA Labor Alerts Details. </font></td>
			  </tr>
			  <tr bgcolor="##FFFF66"> 
				  <td><b>Division </b></td> <td><b>Region</b></td>  <td><b>Community</b></td>  <td><b>Department</b></td>  <td><b>Alert Type</b></td>
				  <td><b>From Date</b></td>  <td><b>60 days Avg</b></td> <td><b>30 days Avg</b></td>  <td><b>7 Days Avg</b></td>
			  </tr>
			
			 <cfloop query="daysOTOB"><cfif daysOTOB.cDivisionName eq 'Midwest'>
				<tr BGCOLOR="###IIF(daysOTOB.currentrow MOD 2, DE('E6E6E6'), DE('C0C0C0'))#">
					<td>#daysOTOB.cDivisionName#</td>
					<td>#daysOTOB.cRegionName# &nbsp;</td>                
					<td>#daysOTOB.cHouseName# &nbsp;</td>
					<td>#daysOTOB.cDisplayname# &nbsp;</td>
					<td>#daysOTOB.cAlertDesc# &nbsp;</td>
					<td>#DateFormat(daysOTOB.dtFromDate, "yyyy-mm-dd")# &nbsp;</td>
					<td align="center">#numberformat(daysOTOB.fovertime60, "0.00")#&nbsp;</td>
					<td align="center">#numberformat(daysOTOB.fovertime30, "0.00")#&nbsp;</td>
					<td align="center"><font color="##CC0000">#numberformat(daysOTOB.fActual, "0.00")#</font></td>
				 </tr></cfif>
			 </cfloop>
			 <!--- FTA OverTime Hours previous day Alert. --->
			  <cfloop query="Overtimealert2"><cfif Overtimealert2.cDivisionName eq 'Midwest'>
				<tr BGCOLOR="###IIF(Overtimealert2.currentrow MOD 2, DE('E6E6E6'), DE('C0C0C0'))#">
					<td>#Overtimealert2.cDivisionName#</td>
					<td>#Overtimealert2.cRegionName#</td>                
					<td>#Overtimealert2.cHouseName#</td>
					<td>#Overtimealert2.cDisplayname# &nbsp;</td>
					<td>#Overtimealert2.cAlertDesc#</td>
					<td>#DateFormat(Overtimealert2.dtFromDate, "yyyy-mm-dd")# &nbsp;</td>
					<!---<td>#DateFormat(Overtimealert2.dtToDate, "yyyy-mm-dd")# &nbsp;</td>--->
					<td align="center">-</td>
					<td align="center">-</td>
					<td align="center"><font color="##CC0000">#numberformat(Overtimealert2.fActual, "0.00")#</font></td>
				 </tr></cfif>
			 </cfloop>
	  </table> 
	  <br/><br/>
	  <hr><br/>
	 <font color="##FF0000"> Do not reply to this email, as this email box is not monitored. </font>
	<!---</cfmail>--->

<!--- <cfmail to="#email_4#"   from="FTA@enlivant.com" subject="FTA Email Alert. " type="html">--->
 <h3> <font color="##0000FF"> FTA Labor Alerts. </font></h3>
		<font color="##3399CC"><b> Today's Date : #date# </b></font>
	  <table border="1">
			  <tr>
				  <td colspan='3' style="font-weight: bold; background-color: ##D7D7D7; text-decoration: underline;"><font color="##3399CC"> FTA Labor Alerts Details. </font></td>
			  </tr>
			  <tr bgcolor="##FFFF66"> 
				  <td><b>Division </b></td> <td><b>Region</b></td>  <td><b>Community</b></td>  <td><b>Department</b></td>  <td><b>Alert Type</b></td>
				  <td><b>From Date</b></td>  <td><b>60 days Avg</b></td> <td><b>30 days Avg</b></td>  <td><b>7 Days Avg</b></td>
			  </tr>
			
			 <cfloop query="daysOTOB"><cfif daysOTOB.cDivisionName eq 'West'>
				<tr BGCOLOR="###IIF(daysOTOB.currentrow MOD 2, DE('E6E6E6'), DE('C0C0C0'))#">
					<td>#daysOTOB.cDivisionName#</td>
					<td>#daysOTOB.cRegionName# &nbsp;</td>                
					<td>#daysOTOB.cHouseName# &nbsp;</td>
					<td>#daysOTOB.cDisplayname# &nbsp;</td>
					<td>#daysOTOB.cAlertDesc# &nbsp;</td>
					<td>#DateFormat(daysOTOB.dtFromDate, "yyyy-mm-dd")# &nbsp;</td>
					<td align="center">#numberformat(daysOTOB.fovertime60, "0.00")#&nbsp;</td>
					<td align="center">#numberformat(daysOTOB.fovertime30, "0.00")#&nbsp;</td>
					<td align="center"><font color="##CC0000">#numberformat(daysOTOB.fActual, "0.00")#</font></td>
				 </tr></cfif>
			 </cfloop>
			 <!--- FTA OverTime Hours previous day Alert. --->
			  <cfloop query="Overtimealert2"><cfif Overtimealert2.cDivisionName eq 'West'>
				<tr BGCOLOR="###IIF(Overtimealert2.currentrow MOD 2, DE('E6E6E6'), DE('C0C0C0'))#">
					<td>#Overtimealert2.cDivisionName#</td>
					<td>#Overtimealert2.cRegionName#</td>                
					<td>#Overtimealert2.cHouseName#</td>
					<td>#Overtimealert2.cDisplayname# &nbsp;</td>
					<td>#Overtimealert2.cAlertDesc#</td>
					<td>#DateFormat(Overtimealert2.dtFromDate, "yyyy-mm-dd")# &nbsp;</td>
					<!---<td>#DateFormat(Overtimealert2.dtToDate, "yyyy-mm-dd")# &nbsp;</td>--->
					<td align="center">-</td>
					<td align="center">-</td>
					<td align="center"><font color="##CC0000">#numberformat(Overtimealert2.fActual, "0.00")#</font></td>
				 </tr></cfif>
			 </cfloop>
	  </table> 
	  <br/><br/>
	  <hr><br/>
	 <font color="##FF0000"> Do not reply to this email, as this email box is not monitored. </font>
	<!---</cfmail>--->

<!--- All regions RD email alerts--->
<!---
<!--- <cfmail to="#email_11#"   from="FTA@enlivant.com" subject="FTA Email Alert. " type="html">--->
 <h3> <font color="##0000FF"> FTA Labor Alerts. </font></h3>
		<font color="##3399CC"><b> Today's Date : #date# </b></font>
	  <table border="1">
			  <tr>
				  <td colspan='3' style="font-weight: bold; background-color: ##D7D7D7; text-decoration: underline;"><font color="##3399CC"> FTA Labor Alerts Details. </font></td>
			  </tr>
			  <tr bgcolor="##FFFF66"> 
				  <td><b>Division </b></td> <td><b>Region</b></td>  <td><b>Community</b></td>  <td><b>Department</b></td>  <td><b>Alert Type</b></td>
				  <td><b>From Date</b></td>  <td><b>60 days Avg</b></td> <td><b>30 days Avg</b></td>  <td><b>7 Days Avg</b></td>
			  </tr>
			
			 <cfloop query="daysOTOB"><cfif daysOTOB.cRegionName eq 'Northwest'>
				<tr BGCOLOR="###IIF(daysOTOB.currentrow MOD 2, DE('E6E6E6'), DE('C0C0C0'))#">
					<td>#daysOTOB.cDivisionName#</td>
					<td>#daysOTOB.cRegionName# &nbsp;</td>                
					<td>#daysOTOB.cHouseName# &nbsp;</td>
					<td>#daysOTOB.cDisplayname# &nbsp;</td>
					<td>#daysOTOB.cAlertDesc# &nbsp;</td>
					<td>#DateFormat(daysOTOB.dtFromDate, "yyyy-mm-dd")# &nbsp;</td>
					<td align="center">#numberformat(daysOTOB.fovertime60, "0.00")#&nbsp;</td>
					<td align="center">#numberformat(daysOTOB.fovertime30, "0.00")#&nbsp;</td>
					<td align="center"><font color="##CC0000">#numberformat(daysOTOB.fActual, "0.00")#</font></td>
				 </tr></cfif>
			 </cfloop>
			 <!--- FTA OverTime Hours previous day Alert. --->
			  <cfloop query="Overtimealert2"><cfif Overtimealert2.cRegionName eq 'Northwest'>
				<tr BGCOLOR="###IIF(Overtimealert2.currentrow MOD 2, DE('E6E6E6'), DE('C0C0C0'))#">
					<td>#Overtimealert2.cDivisionName#</td>
					<td>#Overtimealert2.cRegionName#</td>                
					<td>#Overtimealert2.cHouseName#</td>
					<td>#Overtimealert2.cDisplayname# &nbsp;</td>
					<td>#Overtimealert2.cAlertDesc#</td>
					<td>#DateFormat(Overtimealert2.dtFromDate, "yyyy-mm-dd")# &nbsp;</td>
					<!---<td>#DateFormat(Overtimealert2.dtToDate, "yyyy-mm-dd")# &nbsp;</td>--->
					<td align="center">-</td>
					<td align="center">-</td>
					<td align="center"><font color="##CC0000">#numberformat(Overtimealert2.fActual, "0.00")#</font></td>
				 </tr></cfif>
			 </cfloop>
	  </table> 
	  <br/><br/>
	  <hr><br/>
	 <font color="##FF0000"> Do not reply to this email, as this email box is not monitored. </font>
	<!---</cfmail>--->

<!--- <cfmail to="#email_12#"   from="FTA@enlivant.com" subject="FTA Email Alert. " type="html">--->
 <h3> <font color="##0000FF"> FTA Labor Alerts. </font></h3>
		<font color="##3399CC"><b> Today's Date : #date# </b></font>
	  <table border="1">
			  <tr>
				  <td colspan='3' style="font-weight: bold; background-color: ##D7D7D7; text-decoration: underline;"><font color="##3399CC"> FTA Labor Alerts Details. </font></td>
			  </tr>
			  <tr bgcolor="##FFFF66"> 
				  <td><b>Division </b></td> <td><b>Region</b></td>  <td><b>Community</b></td>  <td><b>Department</b></td>  <td><b>Alert Type</b></td>
				  <td><b>From Date</b></td>  <td><b>60 days Avg</b></td> <td><b>30 days Avg</b></td>  <td><b>7 Days Avg</b></td>
			  </tr>
			
			 <cfloop query="daysOTOB"><cfif daysOTOB.cRegionName eq 'Iowa/Nebraska'>
				<tr BGCOLOR="###IIF(daysOTOB.currentrow MOD 2, DE('E6E6E6'), DE('C0C0C0'))#">
					<td>#daysOTOB.cDivisionName#</td>
					<td>#daysOTOB.cRegionName# &nbsp;</td>                
					<td>#daysOTOB.cHouseName# &nbsp;</td>
					<td>#daysOTOB.cDisplayname# &nbsp;</td>
					<td>#daysOTOB.cAlertDesc# &nbsp;</td>
					<td>#DateFormat(daysOTOB.dtFromDate, "yyyy-mm-dd")# &nbsp;</td>
					<td align="center">#numberformat(daysOTOB.fovertime60, "0.00")#&nbsp;</td>
					<td align="center">#numberformat(daysOTOB.fovertime30, "0.00")#&nbsp;</td>
					<td align="center"><font color="##CC0000">#numberformat(daysOTOB.fActual, "0.00")#</font></td>
				 </tr></cfif>
			 </cfloop>
			 <!--- FTA OverTime Hours previous day Alert. --->
			  <cfloop query="Overtimealert2"><cfif Overtimealert2.cRegionName eq 'Iowa/Nebraska'>
				<tr BGCOLOR="###IIF(Overtimealert2.currentrow MOD 2, DE('E6E6E6'), DE('C0C0C0'))#">
					<td>#Overtimealert2.cDivisionName#</td>
					<td>#Overtimealert2.cRegionName#</td>                
					<td>#Overtimealert2.cHouseName#</td>
					<td>#Overtimealert2.cDisplayname# &nbsp;</td>
					<td>#Overtimealert2.cAlertDesc#</td>
					<td>#DateFormat(Overtimealert2.dtFromDate, "yyyy-mm-dd")# &nbsp;</td>
					<!---<td>#DateFormat(Overtimealert2.dtToDate, "yyyy-mm-dd")# &nbsp;</td>--->
					<td align="center">-</td>
					<td align="center">-</td>
					<td align="center"><font color="##CC0000">#numberformat(Overtimealert2.fActual, "0.00")#</font></td>
				 </tr></cfif>
			 </cfloop>
	  </table> 
	  <br/><br/>
	  <hr><br/>
	 <font color="##FF0000"> Do not reply to this email, as this email box is not monitored. </font>
	<!---</cfmail>--->
	
<!--- <cfmail to="#email_13#"   from="FTA@enlivant.com" subject="FTA Email Alert. " type="html">--->
 <h3> <font color="##0000FF"> FTA Labor Alerts. </font></h3>
		<font color="##3399CC"><b> Today's Date : #date# </b></font>
	  <table border="1">
			  <tr>
				  <td colspan='3' style="font-weight: bold; background-color: ##D7D7D7; text-decoration: underline;"><font color="##3399CC"> FTA Labor Alerts Details. </font></td>
			  </tr>
			  <tr bgcolor="##FFFF66"> 
				  <td><b>Division </b></td> <td><b>Region</b></td>  <td><b>Community</b></td>  <td><b>Department</b></td>  <td><b>Alert Type</b></td>
				  <td><b>From Date</b></td>  <td><b>60 days Avg</b></td> <td><b>30 days Avg</b></td>  <td><b>7 Days Avg</b></td>
			  </tr>
			
			 <cfloop query="daysOTOB"><cfif daysOTOB.cRegionName eq 'Washington'>
				<tr BGCOLOR="###IIF(daysOTOB.currentrow MOD 2, DE('E6E6E6'), DE('C0C0C0'))#">
					<td>#daysOTOB.cDivisionName#</td>
					<td>#daysOTOB.cRegionName# &nbsp;</td>                
					<td>#daysOTOB.cHouseName# &nbsp;</td>
					<td>#daysOTOB.cDisplayname# &nbsp;</td>
					<td>#daysOTOB.cAlertDesc# &nbsp;</td>
					<td>#DateFormat(daysOTOB.dtFromDate, "yyyy-mm-dd")# &nbsp;</td>
					<td align="center">#numberformat(daysOTOB.fovertime60, "0.00")#&nbsp;</td>
					<td align="center">#numberformat(daysOTOB.fovertime30, "0.00")#&nbsp;</td>
					<td align="center"><font color="##CC0000">#numberformat(daysOTOB.fActual, "0.00")#</font></td>
				 </tr></cfif>
			 </cfloop>
			 <!--- FTA OverTime Hours previous day Alert. --->
			  <cfloop query="Overtimealert2"><cfif Overtimealert2.cRegionName eq 'Washington'>
				<tr BGCOLOR="###IIF(Overtimealert2.currentrow MOD 2, DE('E6E6E6'), DE('C0C0C0'))#">
					<td>#Overtimealert2.cDivisionName#</td>
					<td>#Overtimealert2.cRegionName#</td>                
					<td>#Overtimealert2.cHouseName#</td>
					<td>#Overtimealert2.cDisplayname# &nbsp;</td>
					<td>#Overtimealert2.cAlertDesc#</td>
					<td>#DateFormat(Overtimealert2.dtFromDate, "yyyy-mm-dd")# &nbsp;</td>
					<!---<td>#DateFormat(Overtimealert2.dtToDate, "yyyy-mm-dd")# &nbsp;</td>--->
					<td align="center">-</td>
					<td align="center">-</td>
					<td align="center"><font color="##CC0000">#numberformat(Overtimealert2.fActual, "0.00")#</font></td>
				 </tr></cfif>
			 </cfloop>
	  </table> 
	  <br/><br/>
	  <hr><br/>
	 <font color="##FF0000"> Do not reply to this email, as this email box is not monitored. </font>
	<!---</cfmail>--->
	
<!--- <cfmail to="#email_14#"   from="FTA@enlivant.com" subject="FTA Email Alert. " type="html">--->
 <h3> <font color="##0000FF"> FTA Labor Alerts. </font></h3>
		<font color="##3399CC"><b> Today's Date : #date# </b></font>
	  <table border="1">
			  <tr>
				  <td colspan='3' style="font-weight: bold; background-color: ##D7D7D7; text-decoration: underline;"><font color="##3399CC"> FTA Labor Alerts Details. </font></td>
			  </tr>
			  <tr bgcolor="##FFFF66"> 
				  <td><b>Division </b></td> <td><b>Region</b></td>  <td><b>Community</b></td>  <td><b>Department</b></td>  <td><b>Alert Type</b></td>
				  <td><b>From Date</b></td>  <td><b>60 days Avg</b></td> <td><b>30 days Avg</b></td>  <td><b>7 Days Avg</b></td>
			  </tr>
			
			 <cfloop query="daysOTOB"><cfif daysOTOB.cRegionName eq 'Eastern WA/Idaho'>
				<tr BGCOLOR="###IIF(daysOTOB.currentrow MOD 2, DE('E6E6E6'), DE('C0C0C0'))#">
					<td>#daysOTOB.cDivisionName#</td>
					<td>#daysOTOB.cRegionName# &nbsp;</td>                
					<td>#daysOTOB.cHouseName# &nbsp;</td>
					<td>#daysOTOB.cDisplayname# &nbsp;</td>
					<td>#daysOTOB.cAlertDesc# &nbsp;</td>
					<td>#DateFormat(daysOTOB.dtFromDate, "yyyy-mm-dd")# &nbsp;</td>
					<td align="center">#numberformat(daysOTOB.fovertime60, "0.00")#&nbsp;</td>
					<td align="center">#numberformat(daysOTOB.fovertime30, "0.00")#&nbsp;</td>
					<td align="center"><font color="##CC0000">#numberformat(daysOTOB.fActual, "0.00")#</font></td>
				 </tr></cfif>
			 </cfloop>
			 <!--- FTA OverTime Hours previous day Alert. --->
			  <cfloop query="Overtimealert2"><cfif Overtimealert2.cRegionName eq 'Eastern WA/Idaho'>
				<tr BGCOLOR="###IIF(Overtimealert2.currentrow MOD 2, DE('E6E6E6'), DE('C0C0C0'))#">
					<td>#Overtimealert2.cDivisionName#</td>
					<td>#Overtimealert2.cRegionName#</td>                
					<td>#Overtimealert2.cHouseName#</td>
					<td>#Overtimealert2.cDisplayname# &nbsp;</td>
					<td>#Overtimealert2.cAlertDesc#</td>
					<td>#DateFormat(Overtimealert2.dtFromDate, "yyyy-mm-dd")# &nbsp;</td>
					<!---<td>#DateFormat(Overtimealert2.dtToDate, "yyyy-mm-dd")# &nbsp;</td>--->
					<td align="center">-</td>
					<td align="center">-</td>
					<td align="center"><font color="##CC0000">#numberformat(Overtimealert2.fActual, "0.00")#</font></td>
				 </tr></cfif>
			 </cfloop>
	  </table> 
	  <br/><br/>
	  <hr><br/>
	 <font color="##FF0000"> Do not reply to this email, as this email box is not monitored. </font>
	<!---</cfmail>--->
	
 <!---<cfmail to="#email_21#"  from="FTA@enlivant.com" subject="FTA Email Alert. " type="html">--->
 <h3> <font color="##0000FF"> FTA Labor Alerts. </font></h3>
		<font color="##3399CC"><b> Today's Date : #date# </b></font>
	  <table border="1">
			  <tr>
				  <td colspan='3' style="font-weight: bold; background-color: ##D7D7D7; text-decoration: underline;"><font color="##3399CC"> FTA Labor Alerts Details. </font></td>
			  </tr>
			  <tr bgcolor="##FFFF66"> 
				  <td><b>Division </b></td> <td><b>Region</b></td>  <td><b>Community</b></td>  <td><b>Department</b></td>  <td><b>Alert Type</b></td>
				  <td><b>From Date</b></td>  <td><b>60 days Avg</b></td> <td><b>30 days Avg</b></td>  <td><b>7 Days Avg</b></td>
			  </tr>
			
			 <cfloop query="daysOTOB"><cfif daysOTOB.cRegionName eq 'West Texas'>
				<tr BGCOLOR="###IIF(daysOTOB.currentrow MOD 2, DE('E6E6E6'), DE('C0C0C0'))#">
					<td>#daysOTOB.cDivisionName#</td>
					<td>#daysOTOB.cRegionName# &nbsp;</td>                
					<td>#daysOTOB.cHouseName# &nbsp;</td>
					<td>#daysOTOB.cDisplayname# &nbsp;</td>
					<td>#daysOTOB.cAlertDesc# &nbsp;</td>
					<td>#DateFormat(daysOTOB.dtFromDate, "yyyy-mm-dd")# &nbsp;</td>
					<td align="center">#numberformat(daysOTOB.fovertime60, "0.00")#&nbsp;</td>
					<td align="center">#numberformat(daysOTOB.fovertime30, "0.00")#&nbsp;</td>
					<td align="center"><font color="##CC0000">#numberformat(daysOTOB.fActual, "0.00")#</font></td>
				 </tr></cfif>
			 </cfloop>
			 <!--- FTA OverTime Hours previous day Alert. --->
			  <cfloop query="Overtimealert2"><cfif Overtimealert2.cRegionName eq 'West Texas'>
				<tr BGCOLOR="###IIF(Overtimealert2.currentrow MOD 2, DE('E6E6E6'), DE('C0C0C0'))#">
					<td>#Overtimealert2.cDivisionName#</td>
					<td>#Overtimealert2.cRegionName#</td>                
					<td>#Overtimealert2.cHouseName#</td>
					<td>#Overtimealert2.cDisplayname# &nbsp;</td>
					<td>#Overtimealert2.cAlertDesc#</td>
					<td>#DateFormat(Overtimealert2.dtFromDate, "yyyy-mm-dd")# &nbsp;</td>
					<!---<td>#DateFormat(Overtimealert2.dtToDate, "yyyy-mm-dd")# &nbsp;</td>--->
					<td align="center">-</td>
					<td align="center">-</td>
					<td align="center"><font color="##CC0000">#numberformat(Overtimealert2.fActual, "0.00")#</font></td>
				 </tr></cfif>
			 </cfloop>
	  </table> 
	  <br/><br/>
	  <hr><br/>
	 <font color="##FF0000"> Do not reply to this email, as this email box is not monitored. </font>
	<!---</cfmail>--->	

 <!---<cfmail to="#email_22#"  from="FTA@enlivant.com" subject="FTA Email Alert. " type="html">--->
 <h3> <font color="##0000FF"> FTA Labor Alerts. </font></h3>
		<font color="##3399CC"><b> Today's Date : #date# </b></font>
	  <table border="1">
			  <tr>
				  <td colspan='3' style="font-weight: bold; background-color: ##D7D7D7; text-decoration: underline;"><font color="##3399CC"> FTA Labor Alerts Details. </font></td>
			  </tr>
			  <tr bgcolor="##FFFF66"> 
				  <td><b>Division </b></td> <td><b>Region</b></td>  <td><b>Community</b></td>  <td><b>Department</b></td>  <td><b>Alert Type</b></td>
				  <td><b>From Date</b></td>  <td><b>60 days Avg</b></td> <td><b>30 days Avg</b></td>  <td><b>7 Days Avg</b></td>
			  </tr>
			
			 <cfloop query="daysOTOB"><cfif daysOTOB.cRegionName eq 'Arizona'>
				<tr BGCOLOR="###IIF(daysOTOB.currentrow MOD 2, DE('E6E6E6'), DE('C0C0C0'))#">
					<td>#daysOTOB.cDivisionName#</td>
					<td>#daysOTOB.cRegionName# &nbsp;</td>                
					<td>#daysOTOB.cHouseName# &nbsp;</td>
					<td>#daysOTOB.cDisplayname# &nbsp;</td>
					<td>#daysOTOB.cAlertDesc# &nbsp;</td>
					<td>#DateFormat(daysOTOB.dtFromDate, "yyyy-mm-dd")# &nbsp;</td>
					<td align="center">#numberformat(daysOTOB.fovertime60, "0.00")#&nbsp;</td>
					<td align="center">#numberformat(daysOTOB.fovertime30, "0.00")#&nbsp;</td>
					<td align="center"><font color="##CC0000">#numberformat(daysOTOB.fActual, "0.00")#</font></td>
				 </tr></cfif>
			 </cfloop>
			 <!--- FTA OverTime Hours previous day Alert. --->
			  <cfloop query="Overtimealert2"><cfif Overtimealert2.cRegionName eq 'Arizona'>
				<tr BGCOLOR="###IIF(Overtimealert2.currentrow MOD 2, DE('E6E6E6'), DE('C0C0C0'))#">
					<td>#Overtimealert2.cDivisionName#</td>
					<td>#Overtimealert2.cRegionName#</td>                
					<td>#Overtimealert2.cHouseName#</td>
					<td>#Overtimealert2.cDisplayname# &nbsp;</td>
					<td>#Overtimealert2.cAlertDesc#</td>
					<td>#DateFormat(Overtimealert2.dtFromDate, "yyyy-mm-dd")# &nbsp;</td>
					<!---<td>#DateFormat(Overtimealert2.dtToDate, "yyyy-mm-dd")# &nbsp;</td>--->
					<td align="center">-</td>
					<td align="center">-</td>
					<td align="center"><font color="##CC0000">#numberformat(Overtimealert2.fActual, "0.00")#</font></td>
				 </tr></cfif>
			 </cfloop>
	  </table> 
	  <br/><br/>
	  <hr><br/>
	 <font color="##FF0000"> Do not reply to this email, as this email box is not monitored. </font>
	<!---</cfmail>--->	
	
 <!---<cfmail to="#email_23#"  from="FTA@enlivant.com" subject="FTA Email Alert. " type="html">--->
 <h3> <font color="##0000FF"> FTA Labor Alerts. </font></h3>
		<font color="##3399CC"><b> Today's Date : #date# </b></font>
	  <table border="1">
			  <tr>
				  <td colspan='3' style="font-weight: bold; background-color: ##D7D7D7; text-decoration: underline;"><font color="##3399CC"> FTA Labor Alerts Details. </font></td>
			  </tr>
			  <tr bgcolor="##FFFF66"> 
				  <td><b>Division </b></td> <td><b>Region</b></td>  <td><b>Community</b></td>  <td><b>Department</b></td>  <td><b>Alert Type</b></td>
				  <td><b>From Date</b></td>  <td><b>60 days Avg</b></td> <td><b>30 days Avg</b></td>  <td><b>7 Days Avg</b></td>
			  </tr>
			
			 <cfloop query="daysOTOB"><cfif daysOTOB.cRegionName eq 'DFW'>
				<tr BGCOLOR="###IIF(daysOTOB.currentrow MOD 2, DE('E6E6E6'), DE('C0C0C0'))#">
					<td>#daysOTOB.cDivisionName#</td>
					<td>#daysOTOB.cRegionName# &nbsp;</td>                
					<td>#daysOTOB.cHouseName# &nbsp;</td>
					<td>#daysOTOB.cDisplayname# &nbsp;</td>
					<td>#daysOTOB.cAlertDesc# &nbsp;</td>
					<td>#DateFormat(daysOTOB.dtFromDate, "yyyy-mm-dd")# &nbsp;</td>
					<td align="center">#numberformat(daysOTOB.fovertime60, "0.00")#&nbsp;</td>
					<td align="center">#numberformat(daysOTOB.fovertime30, "0.00")#&nbsp;</td>
					<td align="center"><font color="##CC0000">#numberformat(daysOTOB.fActual, "0.00")#</font></td>
				 </tr></cfif>
			 </cfloop>
			 <!--- FTA OverTime Hours previous day Alert. --->
			  <cfloop query="Overtimealert2"><cfif Overtimealert2.cRegionName eq 'DFW'>
				<tr BGCOLOR="###IIF(Overtimealert2.currentrow MOD 2, DE('E6E6E6'), DE('C0C0C0'))#">
					<td>#Overtimealert2.cDivisionName#</td>
					<td>#Overtimealert2.cRegionName#</td>                
					<td>#Overtimealert2.cHouseName#</td>
					<td>#Overtimealert2.cDisplayname# &nbsp;</td>
					<td>#Overtimealert2.cAlertDesc#</td>
					<td>#DateFormat(Overtimealert2.dtFromDate, "yyyy-mm-dd")# &nbsp;</td>
					<!---<td>#DateFormat(Overtimealert2.dtToDate, "yyyy-mm-dd")# &nbsp;</td>--->
					<td align="center">-</td>
					<td align="center">-</td>
					<td align="center"><font color="##CC0000">#numberformat(Overtimealert2.fActual, "0.00")#</font></td>
				 </tr></cfif>
			 </cfloop>
	  </table> 
	  <br/><br/>
	  <hr><br/>
	 <font color="##FF0000"> Do not reply to this email, as this email box is not monitored. </font>
	<!---</cfmail>--->	

 <!---<cfmail to="#email_24#"  from="FTA@enlivant.com" subject="FTA Email Alert. " type="html">--->
 <h3> <font color="##0000FF"> FTA Labor Alerts. </font></h3>
		<font color="##3399CC"><b> Today's Date : #date# </b></font>
	  <table border="1">
			  <tr>
				  <td colspan='3' style="font-weight: bold; background-color: ##D7D7D7; text-decoration: underline;"><font color="##3399CC"> FTA Labor Alerts Details. </font></td>
			  </tr>
			  <tr bgcolor="##FFFF66"> 
				  <td><b>Division </b></td> <td><b>Region</b></td>  <td><b>Community</b></td>  <td><b>Department</b></td>  <td><b>Alert Type</b></td>
				  <td><b>From Date</b></td>  <td><b>60 days Avg</b></td> <td><b>30 days Avg</b></td>  <td><b>7 Days Avg</b></td>
			  </tr>
			
			 <cfloop query="daysOTOB"><cfif daysOTOB.cRegionName eq 'Northeast Texas'>
				<tr BGCOLOR="###IIF(daysOTOB.currentrow MOD 2, DE('E6E6E6'), DE('C0C0C0'))#">
					<td>#daysOTOB.cDivisionName#</td>
					<td>#daysOTOB.cRegionName# &nbsp;</td>                
					<td>#daysOTOB.cHouseName# &nbsp;</td>
					<td>#daysOTOB.cDisplayname# &nbsp;</td>
					<td>#daysOTOB.cAlertDesc# &nbsp;</td>
					<td>#DateFormat(daysOTOB.dtFromDate, "yyyy-mm-dd")# &nbsp;</td>
					<td align="center">#numberformat(daysOTOB.fovertime60, "0.00")#&nbsp;</td>
					<td align="center">#numberformat(daysOTOB.fovertime30, "0.00")#&nbsp;</td>
					<td align="center"><font color="##CC0000">#numberformat(daysOTOB.fActual, "0.00")#</font></td>
				 </tr></cfif>
			 </cfloop>
			 <!--- FTA OverTime Hours previous day Alert. --->
			  <cfloop query="Overtimealert2"><cfif Overtimealert2.cRegionName eq 'Northeast Texas'>
				<tr BGCOLOR="###IIF(Overtimealert2.currentrow MOD 2, DE('E6E6E6'), DE('C0C0C0'))#">
					<td>#Overtimealert2.cDivisionName#</td>
					<td>#Overtimealert2.cRegionName#</td>                
					<td>#Overtimealert2.cHouseName#</td>
					<td>#Overtimealert2.cDisplayname# &nbsp;</td>
					<td>#Overtimealert2.cAlertDesc#</td>
					<td>#DateFormat(Overtimealert2.dtFromDate, "yyyy-mm-dd")# &nbsp;</td>
					<!---<td>#DateFormat(Overtimealert2.dtToDate, "yyyy-mm-dd")# &nbsp;</td>--->
					<td align="center">-</td>
					<td align="center">-</td>
					<td align="center"><font color="##CC0000">#numberformat(Overtimealert2.fActual, "0.00")#</font></td>
				 </tr></cfif>
			 </cfloop>
	  </table> 
	  <br/><br/>
	  <hr><br/>
	 <font color="##FF0000"> Do not reply to this email, as this email box is not monitored. </font>
	<!---</cfmail>--->	

 <!---<cfmail to="#email_25#"  from="FTA@enlivant.com" subject="FTA Email Alert. " type="html">--->
 <h3> <font color="##0000FF"> FTA Labor Alerts. </font></h3>
		<font color="##3399CC"><b> Today's Date : #date# </b></font>
	  <table border="1">
			  <tr>
				  <td colspan='3' style="font-weight: bold; background-color: ##D7D7D7; text-decoration: underline;"><font color="##3399CC"> FTA Labor Alerts Details. </font></td>
			  </tr>
			  <tr bgcolor="##FFFF66"> 
				  <td><b>Division </b></td> <td><b>Region</b></td>  <td><b>Community</b></td>  <td><b>Department</b></td>  <td><b>Alert Type</b></td>
				  <td><b>From Date</b></td>  <td><b>60 days Avg</b></td> <td><b>30 days Avg</b></td>  <td><b>7 Days Avg</b></td>
			  </tr>
			
			 <cfloop query="daysOTOB"><cfif daysOTOB.cRegionName eq 'Southeast Texas'>
				<tr BGCOLOR="###IIF(daysOTOB.currentrow MOD 2, DE('E6E6E6'), DE('C0C0C0'))#">
					<td>#daysOTOB.cDivisionName#</td>
					<td>#daysOTOB.cRegionName# &nbsp;</td>                
					<td>#daysOTOB.cHouseName# &nbsp;</td>
					<td>#daysOTOB.cDisplayname# &nbsp;</td>
					<td>#daysOTOB.cAlertDesc# &nbsp;</td>
					<td>#DateFormat(daysOTOB.dtFromDate, "yyyy-mm-dd")# &nbsp;</td>
					<td align="center">#numberformat(daysOTOB.fovertime60, "0.00")#&nbsp;</td>
					<td align="center">#numberformat(daysOTOB.fovertime30, "0.00")#&nbsp;</td>
					<td align="center"><font color="##CC0000">#numberformat(daysOTOB.fActual, "0.00")#</font></td>
				 </tr></cfif>
			 </cfloop>
			 <!--- FTA OverTime Hours previous day Alert. --->
			  <cfloop query="Overtimealert2"><cfif Overtimealert2.cRegionName eq 'Southeast Texas'>
				<tr BGCOLOR="###IIF(Overtimealert2.currentrow MOD 2, DE('E6E6E6'), DE('C0C0C0'))#">
					<td>#Overtimealert2.cDivisionName#</td>
					<td>#Overtimealert2.cRegionName#</td>                
					<td>#Overtimealert2.cHouseName#</td>
					<td>#Overtimealert2.cDisplayname# &nbsp;</td>
					<td>#Overtimealert2.cAlertDesc#</td>
					<td>#DateFormat(Overtimealert2.dtFromDate, "yyyy-mm-dd")# &nbsp;</td>
					<!---<td>#DateFormat(Overtimealert2.dtToDate, "yyyy-mm-dd")# &nbsp;</td>--->
					<td align="center">-</td>
					<td align="center">-</td>
					<td align="center"><font color="##CC0000">#numberformat(Overtimealert2.fActual, "0.00")#</font></td>
				 </tr></cfif>
			 </cfloop>
	  </table> 
	  <br/><br/>
	  <hr><br/>
	 <font color="##FF0000"> Do not reply to this email, as this email box is not monitored. </font>
	<!---</cfmail>--->	
	
 <!---<cfmail to="#email_31#"  from="FTA@enlivant.com" subject="FTA Email Alert. " type="html">--->
 <h3> <font color="##0000FF"> FTA Labor Alerts. </font></h3>
		<font color="##3399CC"><b> Today's Date : #date# </b></font>
	  <table border="1">
			  <tr>
				  <td colspan='3' style="font-weight: bold; background-color: ##D7D7D7; text-decoration: underline;"><font color="##3399CC"> FTA Labor Alerts Details. </font></td>
			  </tr>
			  <tr bgcolor="##FFFF66"> 
				  <td><b>Division </b></td> <td><b>Region</b></td>  <td><b>Community</b></td>  <td><b>Department</b></td>  <td><b>Alert Type</b></td>
				  <td><b>From Date</b></td>  <td><b>60 days Avg</b></td> <td><b>30 days Avg</b></td>  <td><b>7 Days Avg</b></td>
			  </tr>
			
			 <cfloop query="daysOTOB"><cfif daysOTOB.cRegionName eq 'Northern Indiana'>
				<tr BGCOLOR="###IIF(daysOTOB.currentrow MOD 2, DE('E6E6E6'), DE('C0C0C0'))#">
					<td>#daysOTOB.cDivisionName#</td>
					<td>#daysOTOB.cRegionName# &nbsp;</td>                
					<td>#daysOTOB.cHouseName# &nbsp;</td>
					<td>#daysOTOB.cDisplayname# &nbsp;</td>
					<td>#daysOTOB.cAlertDesc# &nbsp;</td>
					<td>#DateFormat(daysOTOB.dtFromDate, "yyyy-mm-dd")# &nbsp;</td>
					<td align="center">#numberformat(daysOTOB.fovertime60, "0.00")#&nbsp;</td>
					<td align="center">#numberformat(daysOTOB.fovertime30, "0.00")#&nbsp;</td>
					<td align="center"><font color="##CC0000">#numberformat(daysOTOB.fActual, "0.00")#</font></td>
				 </tr></cfif>
			 </cfloop>
			 <!--- FTA OverTime Hours previous day Alert. --->
			  <cfloop query="Overtimealert2"><cfif Overtimealert2.cRegionName eq 'Northern Indiana'>
				<tr BGCOLOR="###IIF(Overtimealert2.currentrow MOD 2, DE('E6E6E6'), DE('C0C0C0'))#">
					<td>#Overtimealert2.cDivisionName#</td>
					<td>#Overtimealert2.cRegionName#</td>                
					<td>#Overtimealert2.cHouseName#</td>
					<td>#Overtimealert2.cDisplayname# &nbsp;</td>
					<td>#Overtimealert2.cAlertDesc#</td>
					<td>#DateFormat(Overtimealert2.dtFromDate, "yyyy-mm-dd")# &nbsp;</td>
					<!---<td>#DateFormat(Overtimealert2.dtToDate, "yyyy-mm-dd")# &nbsp;</td>--->
					<td align="center">-</td>
					<td align="center">-</td>
					<td align="center"><font color="##CC0000">#numberformat(Overtimealert2.fActual, "0.00")#</font></td>
				 </tr></cfif>
			 </cfloop>
	  </table> 
	  <br/><br/>
	  <hr><br/>
	 <font color="##FF0000"> Do not reply to this email, as this email box is not monitored. </font>
	<!---</cfmail>--->	

 <!---<cfmail to="#email_32#"  from="FTA@enlivant.com" subject="FTA Email Alert. " type="html">--->
 <h3> <font color="##0000FF"> FTA Labor Alerts. </font></h3>
		<font color="##3399CC"><b> Today's Date : #date# </b></font>
	  <table border="1">
			  <tr>
				  <td colspan='3' style="font-weight: bold; background-color: ##D7D7D7; text-decoration: underline;"><font color="##3399CC"> FTA Labor Alerts Details. </font></td>
			  </tr>
			  <tr bgcolor="##FFFF66"> 
				  <td><b>Division </b></td> <td><b>Region</b></td>  <td><b>Community</b></td>  <td><b>Department</b></td>  <td><b>Alert Type</b></td>
				  <td><b>From Date</b></td>  <td><b>60 days Avg</b></td> <td><b>30 days Avg</b></td>  <td><b>7 Days Avg</b></td>
			  </tr>
			
			 <cfloop query="daysOTOB"><cfif daysOTOB.cRegionName eq 'Southern Indiana/Kentucky'>
				<tr BGCOLOR="###IIF(daysOTOB.currentrow MOD 2, DE('E6E6E6'), DE('C0C0C0'))#">
					<td>#daysOTOB.cDivisionName#</td>
					<td>#daysOTOB.cRegionName# &nbsp;</td>                
					<td>#daysOTOB.cHouseName# &nbsp;</td>
					<td>#daysOTOB.cDisplayname# &nbsp;</td>
					<td>#daysOTOB.cAlertDesc# &nbsp;</td>
					<td>#DateFormat(daysOTOB.dtFromDate, "yyyy-mm-dd")# &nbsp;</td>
					<td align="center">#numberformat(daysOTOB.fovertime60, "0.00")#&nbsp;</td>
					<td align="center">#numberformat(daysOTOB.fovertime30, "0.00")#&nbsp;</td>
					<td align="center"><font color="##CC0000">#numberformat(daysOTOB.fActual, "0.00")#</font></td>
				 </tr></cfif>
			 </cfloop>
			 <!--- FTA OverTime Hours previous day Alert. --->
			  <cfloop query="Overtimealert2"><cfif Overtimealert2.cRegionName eq 'Southern Indiana/Kentucky'>
				<tr BGCOLOR="###IIF(Overtimealert2.currentrow MOD 2, DE('E6E6E6'), DE('C0C0C0'))#">
					<td>#Overtimealert2.cDivisionName#</td>
					<td>#Overtimealert2.cRegionName#</td>                
					<td>#Overtimealert2.cHouseName#</td>
					<td>#Overtimealert2.cDisplayname# &nbsp;</td>
					<td>#Overtimealert2.cAlertDesc#</td>
					<td>#DateFormat(Overtimealert2.dtFromDate, "yyyy-mm-dd")# &nbsp;</td>
					<!---<td>#DateFormat(Overtimealert2.dtToDate, "yyyy-mm-dd")# &nbsp;</td>--->
					<td align="center">-</td>
					<td align="center">-</td>
					<td align="center"><font color="##CC0000">#numberformat(Overtimealert2.fActual, "0.00")#</font></td>
				 </tr></cfif>
			 </cfloop>
	  </table> 
	  <br/><br/>
	  <hr><br/>
	 <font color="##FF0000"> Do not reply to this email, as this email box is not monitored. </font>
	<!---</cfmail>--->	

 <!---<cfmail to="#email_33#"  from="FTA@enlivant.com" subject="FTA Email Alert. " type="html">--->
 <h3> <font color="##0000FF"> FTA Labor Alerts. </font></h3>
		<font color="##3399CC"><b> Today's Date : #date# </b></font>
	  <table border="1">
			  <tr>
				  <td colspan='3' style="font-weight: bold; background-color: ##D7D7D7; text-decoration: underline;"><font color="##3399CC"> FTA Labor Alerts Details. </font></td>
			  </tr>
			  <tr bgcolor="##FFFF66"> 
				  <td><b>Division </b></td> <td><b>Region</b></td>  <td><b>Community</b></td>  <td><b>Department</b></td>  <td><b>Alert Type</b></td>
				  <td><b>From Date</b></td>  <td><b>60 days Avg</b></td> <td><b>30 days Avg</b></td>  <td><b>7 Days Avg</b></td>
			  </tr>
			
			 <cfloop query="daysOTOB"><cfif daysOTOB.cRegionName eq 'Greater Wisconsin'>
				<tr BGCOLOR="###IIF(daysOTOB.currentrow MOD 2, DE('E6E6E6'), DE('C0C0C0'))#">
					<td>#daysOTOB.cDivisionName#</td>
					<td>#daysOTOB.cRegionName# &nbsp;</td>                
					<td>#daysOTOB.cHouseName# &nbsp;</td>
					<td>#daysOTOB.cDisplayname# &nbsp;</td>
					<td>#daysOTOB.cAlertDesc# &nbsp;</td>
					<td>#DateFormat(daysOTOB.dtFromDate, "yyyy-mm-dd")# &nbsp;</td>
					<td align="center">#numberformat(daysOTOB.fovertime60, "0.00")#&nbsp;</td>
					<td align="center">#numberformat(daysOTOB.fovertime30, "0.00")#&nbsp;</td>
					<td align="center"><font color="##CC0000">#numberformat(daysOTOB.fActual, "0.00")#</font></td>
				 </tr></cfif>
			 </cfloop>
			 <!--- FTA OverTime Hours previous day Alert. --->
			  <cfloop query="Overtimealert2"><cfif Overtimealert2.cRegionName eq 'Greater Wisconsin'>
				<tr BGCOLOR="###IIF(Overtimealert2.currentrow MOD 2, DE('E6E6E6'), DE('C0C0C0'))#">
					<td>#Overtimealert2.cDivisionName#</td>
					<td>#Overtimealert2.cRegionName#</td>                
					<td>#Overtimealert2.cHouseName#</td>
					<td>#Overtimealert2.cDisplayname# &nbsp;</td>
					<td>#Overtimealert2.cAlertDesc#</td>
					<td>#DateFormat(Overtimealert2.dtFromDate, "yyyy-mm-dd")# &nbsp;</td>
					<!---<td>#DateFormat(Overtimealert2.dtToDate, "yyyy-mm-dd")# &nbsp;</td>--->
					<td align="center">-</td>
					<td align="center">-</td>
					<td align="center"><font color="##CC0000">#numberformat(Overtimealert2.fActual, "0.00")#</font></td>
				 </tr></cfif>
			 </cfloop>
	  </table> 
	  <br/><br/>
	  <hr><br/>
	 <font color="##FF0000"> Do not reply to this email, as this email box is not monitored. </font>
	<!---</cfmail>--->	

 <!---<cfmail to="#email_34#"  from="FTA@enlivant.com" subject="FTA Email Alert. " type="html">--->
 <h3> <font color="##0000FF"> FTA Labor Alerts. </font></h3>
		<font color="##3399CC"><b> Today's Date : #date# </b></font>
	  <table border="1">
			  <tr>
				  <td colspan='3' style="font-weight: bold; background-color: ##D7D7D7; text-decoration: underline;"><font color="##3399CC"> FTA Labor Alerts Details. </font></td>
			  </tr>
			  <tr bgcolor="##FFFF66"> 
				  <td><b>Division </b></td> <td><b>Region</b></td>  <td><b>Community</b></td>  <td><b>Department</b></td>  <td><b>Alert Type</b></td>
				  <td><b>From Date</b></td>  <td><b>60 days Avg</b></td> <td><b>30 days Avg</b></td>  <td><b>7 Days Avg</b></td>
			  </tr>
			
			 <cfloop query="daysOTOB"><cfif daysOTOB.cRegionName eq 'Northern Ohio'>
				<tr BGCOLOR="###IIF(daysOTOB.currentrow MOD 2, DE('E6E6E6'), DE('C0C0C0'))#">
					<td>#daysOTOB.cDivisionName#</td>
					<td>#daysOTOB.cRegionName# &nbsp;</td>                
					<td>#daysOTOB.cHouseName# &nbsp;</td>
					<td>#daysOTOB.cDisplayname# &nbsp;</td>
					<td>#daysOTOB.cAlertDesc# &nbsp;</td>
					<td>#DateFormat(daysOTOB.dtFromDate, "yyyy-mm-dd")# &nbsp;</td>
					<td align="center">#numberformat(daysOTOB.fovertime60, "0.00")#&nbsp;</td>
					<td align="center">#numberformat(daysOTOB.fovertime30, "0.00")#&nbsp;</td>
					<td align="center"><font color="##CC0000">#numberformat(daysOTOB.fActual, "0.00")#</font></td>
				 </tr></cfif>
			 </cfloop>
			 <!--- FTA OverTime Hours previous day Alert. --->
			  <cfloop query="Overtimealert2"><cfif Overtimealert2.cRegionName eq 'Northern Ohio'>
				<tr BGCOLOR="###IIF(Overtimealert2.currentrow MOD 2, DE('E6E6E6'), DE('C0C0C0'))#">
					<td>#Overtimealert2.cDivisionName#</td>
					<td>#Overtimealert2.cRegionName#</td>                
					<td>#Overtimealert2.cHouseName#</td>
					<td>#Overtimealert2.cDisplayname# &nbsp;</td>
					<td>#Overtimealert2.cAlertDesc#</td>
					<td>#DateFormat(Overtimealert2.dtFromDate, "yyyy-mm-dd")# &nbsp;</td>
					<!---<td>#DateFormat(Overtimealert2.dtToDate, "yyyy-mm-dd")# &nbsp;</td>--->
					<td align="center">-</td>
					<td align="center">-</td>
					<td align="center"><font color="##CC0000">#numberformat(Overtimealert2.fActual, "0.00")#</font></td>
				 </tr></cfif>
			 </cfloop>
	  </table> 
	  <br/><br/>
	  <hr><br/>
	 <font color="##FF0000"> Do not reply to this email, as this email box is not monitored. </font>
	<!---</cfmail>--->	
	
 <!---<cfmail to="#email_35#"  from="FTA@enlivant.com" subject="FTA Email Alert. " type="html">--->
 <h3> <font color="##0000FF"> FTA Labor Alerts. </font></h3>
		<font color="##3399CC"><b> Today's Date : #date# </b></font>
	  <table border="1">
			  <tr>
				  <td colspan='3' style="font-weight: bold; background-color: ##D7D7D7; text-decoration: underline;"><font color="##3399CC"> FTA Labor Alerts Details. </font></td>
			  </tr>
			  <tr bgcolor="##FFFF66"> 
				  <td><b>Division </b></td> <td><b>Region</b></td>  <td><b>Community</b></td>  <td><b>Department</b></td>  <td><b>Alert Type</b></td>
				  <td><b>From Date</b></td>  <td><b>60 days Avg</b></td> <td><b>30 days Avg</b></td>  <td><b>7 Days Avg</b></td>
			  </tr>
			
			 <cfloop query="daysOTOB"><cfif daysOTOB.cRegionName eq 'Western Pennsylvania'>
				<tr BGCOLOR="###IIF(daysOTOB.currentrow MOD 2, DE('E6E6E6'), DE('C0C0C0'))#">
					<td>#daysOTOB.cDivisionName#</td>
					<td>#daysOTOB.cRegionName# &nbsp;</td>                
					<td>#daysOTOB.cHouseName# &nbsp;</td>
					<td>#daysOTOB.cDisplayname# &nbsp;</td>
					<td>#daysOTOB.cAlertDesc# &nbsp;</td>
					<td>#DateFormat(daysOTOB.dtFromDate, "yyyy-mm-dd")# &nbsp;</td>
					<td align="center">#numberformat(daysOTOB.fovertime60, "0.00")#&nbsp;</td>
					<td align="center">#numberformat(daysOTOB.fovertime30, "0.00")#&nbsp;</td>
					<td align="center"><font color="##CC0000">#numberformat(daysOTOB.fActual, "0.00")#</font></td>
				 </tr></cfif>
			 </cfloop>
			 <!--- FTA OverTime Hours previous day Alert. --->
			  <cfloop query="Overtimealert2"><cfif Overtimealert2.cRegionName eq 'Western Pennsylvania'>
				<tr BGCOLOR="###IIF(Overtimealert2.currentrow MOD 2, DE('E6E6E6'), DE('C0C0C0'))#">
					<td>#Overtimealert2.cDivisionName#</td>
					<td>#Overtimealert2.cRegionName#</td>                
					<td>#Overtimealert2.cHouseName#</td>
					<td>#Overtimealert2.cDisplayname# &nbsp;</td>
					<td>#Overtimealert2.cAlertDesc#</td>
					<td>#DateFormat(Overtimealert2.dtFromDate, "yyyy-mm-dd")# &nbsp;</td>
					<!---<td>#DateFormat(Overtimealert2.dtToDate, "yyyy-mm-dd")# &nbsp;</td>--->
					<td align="center">-</td>
					<td align="center">-</td>
					<td align="center"><font color="##CC0000">#numberformat(Overtimealert2.fActual, "0.00")#</font></td>
				 </tr></cfif>
			 </cfloop>
	  </table> 
	  <br/><br/>
	  <hr><br/>
	 <font color="##FF0000"> Do not reply to this email, as this email box is not monitored. </font>
	<!---</cfmail>--->	
	
 <!---<cfmail to="#email_36#"  from="FTA@enlivant.com" subject="FTA Email Alert. " type="html">--->
 <h3> <font color="##0000FF"> FTA Labor Alerts. </font></h3>
		<font color="##3399CC"><b> Today's Date : #date# </b></font>
	  <table border="1">
			  <tr>
				  <td colspan='3' style="font-weight: bold; background-color: ##D7D7D7; text-decoration: underline;"><font color="##3399CC"> FTA Labor Alerts Details. </font></td>
			  </tr>
			  <tr bgcolor="##FFFF66"> 
				  <td><b>Division </b></td> <td><b>Region</b></td>  <td><b>Community</b></td>  <td><b>Department</b></td>  <td><b>Alert Type</b></td>
				  <td><b>From Date</b></td>  <td><b>60 days Avg</b></td> <td><b>30 days Avg</b></td>  <td><b>7 Days Avg</b></td>
			  </tr>
			
			 <cfloop query="daysOTOB"><cfif daysOTOB.cRegionName eq 'Southern Ohio'>
				<tr BGCOLOR="###IIF(daysOTOB.currentrow MOD 2, DE('E6E6E6'), DE('C0C0C0'))#">
					<td>#daysOTOB.cDivisionName#</td>
					<td>#daysOTOB.cRegionName# &nbsp;</td>                
					<td>#daysOTOB.cHouseName# &nbsp;</td>
					<td>#daysOTOB.cDisplayname# &nbsp;</td>
					<td>#daysOTOB.cAlertDesc# &nbsp;</td>
					<td>#DateFormat(daysOTOB.dtFromDate, "yyyy-mm-dd")# &nbsp;</td>
					<td align="center">#numberformat(daysOTOB.fovertime60, "0.00")#&nbsp;</td>
					<td align="center">#numberformat(daysOTOB.fovertime30, "0.00")#&nbsp;</td>
					<td align="center"><font color="##CC0000">#numberformat(daysOTOB.fActual, "0.00")#</font></td>
				 </tr></cfif>
			 </cfloop>
			 <!--- FTA OverTime Hours previous day Alert. --->
			  <cfloop query="Overtimealert2"><cfif Overtimealert2.cRegionName eq 'Southern Ohio'>
				<tr BGCOLOR="###IIF(Overtimealert2.currentrow MOD 2, DE('E6E6E6'), DE('C0C0C0'))#">
					<td>#Overtimealert2.cDivisionName#</td>
					<td>#Overtimealert2.cRegionName#</td>                
					<td>#Overtimealert2.cHouseName#</td>
					<td>#Overtimealert2.cDisplayname# &nbsp;</td>
					<td>#Overtimealert2.cAlertDesc#</td>
					<td>#DateFormat(Overtimealert2.dtFromDate, "yyyy-mm-dd")# &nbsp;</td>
					<!---<td>#DateFormat(Overtimealert2.dtToDate, "yyyy-mm-dd")# &nbsp;</td>--->
					<td align="center">-</td>
					<td align="center">-</td>
					<td align="center"><font color="##CC0000">#numberformat(Overtimealert2.fActual, "0.00")#</font></td>
				 </tr></cfif>
			 </cfloop>
	  </table> 
	  <br/><br/>
	  <hr><br/>
	 <font color="##FF0000"> Do not reply to this email, as this email box is not monitored. </font>
	<!---</cfmail>--->	
	
 <!---<cfmail to="#email_41#"  from="FTA@enlivant.com" subject="FTA Email Alert. " type="html">--->
 <h3> <font color="##0000FF"> FTA Labor Alerts. </font></h3>
		<font color="##3399CC"><b> Today's Date : #date# </b></font>
	  <table border="1">
			  <tr>
				  <td colspan='3' style="font-weight: bold; background-color: ##D7D7D7; text-decoration: underline;"><font color="##3399CC"> FTA Labor Alerts Details. </font></td>
			  </tr>
			  <tr bgcolor="##FFFF66"> 
				  <td><b>Division </b></td> <td><b>Region</b></td>  <td><b>Community</b></td>  <td><b>Department</b></td>  <td><b>Alert Type</b></td>
				  <td><b>From Date</b></td>  <td><b>60 days Avg</b></td> <td><b>30 days Avg</b></td>  <td><b>7 Days Avg</b></td>
			  </tr>
			
			 <cfloop query="daysOTOB"><cfif daysOTOB.cRegionName eq 'Southeast'>
				<tr BGCOLOR="###IIF(daysOTOB.currentrow MOD 2, DE('E6E6E6'), DE('C0C0C0'))#">
					<td>#daysOTOB.cDivisionName#</td>
					<td>#daysOTOB.cRegionName# &nbsp;</td>                
					<td>#daysOTOB.cHouseName# &nbsp;</td>
					<td>#daysOTOB.cDisplayname# &nbsp;</td>
					<td>#daysOTOB.cAlertDesc# &nbsp;</td>
					<td>#DateFormat(daysOTOB.dtFromDate, "yyyy-mm-dd")# &nbsp;</td>
					<td align="center">#numberformat(daysOTOB.fovertime60, "0.00")#&nbsp;</td>
					<td align="center">#numberformat(daysOTOB.fovertime30, "0.00")#&nbsp;</td>
					<td align="center"><font color="##CC0000">#numberformat(daysOTOB.fActual, "0.00")#</font></td>
				 </tr></cfif>
			 </cfloop>
			 <!--- FTA OverTime Hours previous day Alert. --->
			  <cfloop query="Overtimealert2"><cfif Overtimealert2.cRegionName eq 'Southeast'>
				<tr BGCOLOR="###IIF(Overtimealert2.currentrow MOD 2, DE('E6E6E6'), DE('C0C0C0'))#">
					<td>#Overtimealert2.cDivisionName#</td>
					<td>#Overtimealert2.cRegionName#</td>                
					<td>#Overtimealert2.cHouseName#</td>
					<td>#Overtimealert2.cDisplayname# &nbsp;</td>
					<td>#Overtimealert2.cAlertDesc#</td>
					<td>#DateFormat(Overtimealert2.dtFromDate, "yyyy-mm-dd")# &nbsp;</td>
					<!---<td>#DateFormat(Overtimealert2.dtToDate, "yyyy-mm-dd")# &nbsp;</td>--->
					<td align="center">-</td>
					<td align="center">-</td>
					<td align="center"><font color="##CC0000">#numberformat(Overtimealert2.fActual, "0.00")#</font></td>
				 </tr></cfif>
			 </cfloop>
	  </table> 
	  <br/><br/>
	  <hr><br/>
	 <font color="##FF0000"> Do not reply to this email, as this email box is not monitored. </font>
	<!---</cfmail>--->	
	
 <!---<cfmail to="#email_42#"  from="FTA@enlivant.com" subject="FTA Email Alert. " type="html">--->
 <h3> <font color="##0000FF"> FTA Labor Alerts. </font></h3>
		<font color="##3399CC"><b> Today's Date : #date# </b></font>
	  <table border="1">
			  <tr>
				  <td colspan='3' style="font-weight: bold; background-color: ##D7D7D7; text-decoration: underline;"><font color="##3399CC"> FTA Labor Alerts Details. </font></td>
			  </tr>
			  <tr bgcolor="##FFFF66"> 
				  <td><b>Division </b></td> <td><b>Region</b></td>  <td><b>Community</b></td>  <td><b>Department</b></td>  <td><b>Alert Type</b></td>
				  <td><b>From Date</b></td>  <td><b>60 days Avg</b></td> <td><b>30 days Avg</b></td>  <td><b>7 Days Avg</b></td>
			  </tr>
			
			 <cfloop query="daysOTOB"><cfif daysOTOB.cRegionName eq 'South Carolina'>
				<tr BGCOLOR="###IIF(daysOTOB.currentrow MOD 2, DE('E6E6E6'), DE('C0C0C0'))#">
					<td>#daysOTOB.cDivisionName#</td>
					<td>#daysOTOB.cRegionName# &nbsp;</td>                
					<td>#daysOTOB.cHouseName# &nbsp;</td>
					<td>#daysOTOB.cDisplayname# &nbsp;</td>
					<td>#daysOTOB.cAlertDesc# &nbsp;</td>
					<td>#DateFormat(daysOTOB.dtFromDate, "yyyy-mm-dd")# &nbsp;</td>
					<td align="center">#numberformat(daysOTOB.fovertime60, "0.00")#&nbsp;</td>
					<td align="center">#numberformat(daysOTOB.fovertime30, "0.00")#&nbsp;</td>
					<td align="center"><font color="##CC0000">#numberformat(daysOTOB.fActual, "0.00")#</font></td>
				 </tr></cfif>
			 </cfloop>
			 <!--- FTA OverTime Hours previous day Alert. --->
			  <cfloop query="Overtimealert2"><cfif Overtimealert2.cRegionName eq 'South Carolina'>
				<tr BGCOLOR="###IIF(Overtimealert2.currentrow MOD 2, DE('E6E6E6'), DE('C0C0C0'))#">
					<td>#Overtimealert2.cDivisionName#</td>
					<td>#Overtimealert2.cRegionName#</td>                
					<td>#Overtimealert2.cHouseName#</td>
					<td>#Overtimealert2.cDisplayname# &nbsp;</td>
					<td>#Overtimealert2.cAlertDesc#</td>
					<td>#DateFormat(Overtimealert2.dtFromDate, "yyyy-mm-dd")# &nbsp;</td>
					<!---<td>#DateFormat(Overtimealert2.dtToDate, "yyyy-mm-dd")# &nbsp;</td>--->
					<td align="center">-</td>
					<td align="center">-</td>
					<td align="center"><font color="##CC0000">#numberformat(Overtimealert2.fActual, "0.00")#</font></td>
				 </tr></cfif>
			 </cfloop>
	  </table> 
	  <br/><br/>
	  <hr><br/>
	 <font color="##FF0000"> Do not reply to this email, as this email box is not monitored. </font>
	<!---</cfmail>--->	

 <!---<cfmail to="#email_43#"  from="FTA@enlivant.com" subject="FTA Email Alert. " type="html">--->
 <h3> <font color="##0000FF"> FTA Labor Alerts. </font></h3>
		<font color="##3399CC"><b> Today's Date : #date# </b></font>
	  <table border="1">
			  <tr>
				  <td colspan='3' style="font-weight: bold; background-color: ##D7D7D7; text-decoration: underline;"><font color="##3399CC"> FTA Labor Alerts Details. </font></td>
			  </tr>
			  <tr bgcolor="##FFFF66"> 
				  <td><b>Division </b></td> <td><b>Region</b></td>  <td><b>Community</b></td>  <td><b>Department</b></td>  <td><b>Alert Type</b></td>
				  <td><b>From Date</b></td>  <td><b>60 days Avg</b></td> <td><b>30 days Avg</b></td>  <td><b>7 Days Avg</b></td>
			  </tr>
			
			 <cfloop query="daysOTOB"><cfif daysOTOB.cRegionName eq 'Greater New Jersey'>
				<tr BGCOLOR="###IIF(daysOTOB.currentrow MOD 2, DE('E6E6E6'), DE('C0C0C0'))#">
					<td>#daysOTOB.cDivisionName#</td>
					<td>#daysOTOB.cRegionName# &nbsp;</td>                
					<td>#daysOTOB.cHouseName# &nbsp;</td>
					<td>#daysOTOB.cDisplayname# &nbsp;</td>
					<td>#daysOTOB.cAlertDesc# &nbsp;</td>
					<td>#DateFormat(daysOTOB.dtFromDate, "yyyy-mm-dd")# &nbsp;</td>
					<td align="center">#numberformat(daysOTOB.fovertime60, "0.00")#&nbsp;</td>
					<td align="center">#numberformat(daysOTOB.fovertime30, "0.00")#&nbsp;</td>
					<td align="center"><font color="##CC0000">#numberformat(daysOTOB.fActual, "0.00")#</font></td>
				 </tr></cfif>
			 </cfloop>
			 <!--- FTA OverTime Hours previous day Alert. --->
			  <cfloop query="Overtimealert2"><cfif Overtimealert2.cRegionName eq 'Greater New Jersey'>
				<tr BGCOLOR="###IIF(Overtimealert2.currentrow MOD 2, DE('E6E6E6'), DE('C0C0C0'))#">
					<td>#Overtimealert2.cDivisionName#</td>
					<td>#Overtimealert2.cRegionName#</td>                
					<td>#Overtimealert2.cHouseName#</td>
					<td>#Overtimealert2.cDisplayname# &nbsp;</td>
					<td>#Overtimealert2.cAlertDesc#</td>
					<td>#DateFormat(Overtimealert2.dtFromDate, "yyyy-mm-dd")# &nbsp;</td>
					<!---<td>#DateFormat(Overtimealert2.dtToDate, "yyyy-mm-dd")# &nbsp;</td>--->
					<td align="center">-</td>
					<td align="center">-</td>
					<td align="center"><font color="##CC0000">#numberformat(Overtimealert2.fActual, "0.00")#</font></td>
				 </tr></cfif>
			 </cfloop>
	  </table> 
	  <br/><br/>
	  <hr><br/>
	 <font color="##FF0000"> Do not reply to this email, as this email box is not monitored. </font>
	<!---</cfmail>--->	
	
<!--- This FTA email alert is not for DVP / RD --->

<!--- <cfset email = "cPhillips@enlivant.com, dguill@enlivant.com, gthota@enlivant.com, tbates@enlivant.com, skannukkaden@enlivant.com, _ALC5DVPGroup@enlivant.com,_AllRgnlDirofOperations@enlivant.com">
 <cfset email2 = "cPhillips@enlivant.com, dguill@enlivant.com, gthota@enlivant.com, tbates@enlivant.com, skannukkaden@enlivant.com">--->
 
 <!---<cfmail to="#email#"  from="FTA@enlivant.com" subject="FTA Email Alert. " type="html">--->
 <h3> <font color="##0000FF"> FTA Labor Alerts. </font></h3>
		<font color="##3399CC"><b> Today's Date : #date# </b></font>
	  <table border="1">
			  <tr>
				  <td colspan='3' style="font-weight: bold; background-color: ##D7D7D7; text-decoration: underline;"><font color="##3399CC"> FTA Labor Alerts Details. </font></td>
			  </tr>
			  <tr bgcolor="##FFFF66"> 
				  <td><b>Division </b></td> <td><b>Region</b></td>  <td><b>Community</b></td>  <td><b>Department</b></td>  <td><b>Alert Type</b></td>
				  <td><b>From Date</b></td>  <td><b>60 days Avg</b></td> <td><b>30 days Avg</b></td>  <td><b>7 Days Avg</b></td>
			  </tr>
			
			 <cfloop query="daysOTOB">
				<tr BGCOLOR="###IIF(daysOTOB.currentrow MOD 2, DE('E6E6E6'), DE('C0C0C0'))#">
					<td>#daysOTOB.cDivisionName#</td>
					<td>#daysOTOB.cRegionName# &nbsp;</td>                
					<td>#daysOTOB.cHouseName# &nbsp;</td>
					<td>#daysOTOB.cDisplayname# &nbsp;</td>
					<td>#daysOTOB.cAlertDesc# &nbsp;</td>
					<td>#DateFormat(daysOTOB.dtFromDate, "yyyy-mm-dd")# &nbsp;</td>
					<td align="center">#numberformat(daysOTOB.fovertime60, "0.00")#&nbsp;</td>
					<td align="center">#numberformat(daysOTOB.fovertime30, "0.00")#&nbsp;</td>
					<td align="center"><font color="##CC0000">#numberformat(daysOTOB.fActual, "0.00")#</font></td>
				 </tr>
			 </cfloop>
			 <!--- FTA OverTime Hours previous day Alert. --->
			  <cfloop query="Overtimealert2">
				<tr BGCOLOR="###IIF(Overtimealert2.currentrow MOD 2, DE('E6E6E6'), DE('C0C0C0'))#">
					<td>#Overtimealert2.cDivisionName#</td>
					<td>#Overtimealert2.cRegionName#</td>                
					<td>#Overtimealert2.cHouseName#</td>
					<td>#Overtimealert2.cDisplayname# &nbsp;</td>
					<td>#Overtimealert2.cAlertDesc#</td>
					<td>#DateFormat(Overtimealert2.dtFromDate, "yyyy-mm-dd")# &nbsp;</td>
					<!---<td>#DateFormat(Overtimealert2.dtToDate, "yyyy-mm-dd")# &nbsp;</td>--->
					<td align="center">-</td>
					<td align="center">-</td>
					<td align="center"><font color="##CC0000">#numberformat(Overtimealert2.fActual, "0.00")#</font></td>
				 </tr>
			 </cfloop>
	  </table> 
	  <br/><br/>
	  <hr><br/>
	 <font color="##FF0000"> Do not reply to this email, as this email box is not monitored. </font>
	<!---</cfmail>--->	--->

 </cfoutput>
