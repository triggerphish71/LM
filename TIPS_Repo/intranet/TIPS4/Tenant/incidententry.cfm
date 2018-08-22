<!--- ==============================================================================
Set variable for timestamp to record corresponding times for transactions
=============================================================================== --->
<CFQUERY NAME="GetDate" DATASOURCE="#APPLICATION.datasource#">
	SELECT getDate() as Stamp
</CFQUERY>
<CFSET TimeStamp = CreateODBCDateTime(GetDate.Stamp)>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Incident Entry</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">

<!--- =============================================================================================
Include Intranet Header
============================================================================================= --->
<CFINCLUDE TEMPLATE="../../header.cfm">
<H1 CLASS="PageTitle"> Tips 4 - Incident Entry </H1>

<!--- <CFINCLUDE TEMPLATE="../Shared/HouseHeader.cfm"> --->

</head>

<cfif isDefined("form.subinc")>
	<!--- insert/update incident --->
	<cfset dtIncident = "#form.incidentmonth_ck#/#form.incidentday_ck#/#form.incidentyear_ck#">
	<cfif not isDefined("form.bCat1")><cfset bCat1 = "0"><cfelse><cfset bCat1 = "1"></cfif>
	<cfif not isDefined("form.bCat2")><cfset bCat2 = "0"><cfelse><cfset bCat2 = "1"></cfif>
	<cfif not isDefined("form.bCat3")><cfset bCat3 = "0"><cfelse><cfset bCat3 = "1"></cfif>
	<cfif not isDefined("form.bCat4")><cfset bCat4 = "0"><cfelse><cfset bCat4 = "1"></cfif>
	<cfif not isDefined("form.bCat5")><cfset bCat5 = "0"><cfelse><cfset bCat5 = "1"></cfif>
	<cfif not isDefined("form.bCat6")><cfset bCat6 = "0"><cfelse><cfset bCat6 = "1"></cfif>
	<cfif not isDefined("form.bCat7")><cfset bCat7 = "0"><cfelse><cfset bCat7 = "1"></cfif>
	<cfif not isDefined("form.bCat8")><cfset bCat8 = "0"><cfelse><cfset bCat8 = "1"></cfif>
	<cfif not isDefined("form.bReassessment")><cfset bReassessment = "0"><cfelse><cfset bReassessment = "1"></cfif>
	<cfif not isDefined("form.bCareConf")><cfset bCareConf = "0"><cfelse><cfset bCareConf = "1"></cfif>
	<cfif not isDefined("form.bNSPupdated")><cfset bNSPupdated = "0"><cfelse><cfset bNSPupdated = "1"></cfif>
	
	<cfif not isDefined("form.bCat1") and not isDefined("form.bCat2") and not isDefined("form.bCat3") and not isDefined("form.bCat4") and not isDefined("form.bCat5") and not isDefined("form.bCat6") and not isDefined("form.bCat7") and not isDefined("form.bCat8")><center><h3><font color="red">Sorry, you must select at least ONE Event Type/Category for this Incident to submit.<BR>Go back and try again.</font></h3></center><cfabort></cfif>
	
	<cfif isDefined("form.iTenantIncident_ID")>
		<!--- update incident --->
		<cfquery name="updateIncident" datasource="TIPS4">
			UPDATE TenantIncident SET dtIncident='#dtIncident#', iHouse_ID=#form.iHouse_ID#, iTenant_ID=#form.iTenant_ID#, cDescription='#form.cDescription#', bCat1 =#bCat1#, bCat2=#bCat2#, bCat3=#bCat3#, bCat4=#bCat4#, bCat5=#bCat5#, bCat6=#bCat6#, bCat7=#bCat7#, bCat8=#bCat8#, bReassessment=#bReassessment#, bCareConf=#bCareConf#, bNSPupdated=#bNSPupdated#, cCurrentStatus='#form.cCurrentStatus#', cFinalOutcome='#form.cFinalOutcome#', dtRowStart=#timestamp#, iRowStartUser_ID=#session.userid# WHERE iTenantIncident_ID = #form.iTenantIncident_ID#
		</cfquery>
	
	<cfelse>
		<!--- insert new incident --->
		<cfquery name="insertIncident" datasource="Tips4">
			INSERT INTO TenantIncident (dtIncident, iHouse_ID, iTenant_ID, cDescription, bCat1, bCat2, bCat3, bCat4, bCat5, bCat6, bCat7, bCat8, bReassessment, bCareConf, bNSPupdated, cCurrentStatus, cFinalOutcome, dtRowStart, iRowStartUser_ID) VALUES ('#dtIncident#', #form.iHouse_ID#, #form.iTenant_ID#, '#form.cDescription#', #bCat1#, #bCat2#, #bCat3#, #bCat4#, #bCat5#, #bCat6#, #bCat7#, #bCat8#, #bReassessment#, #bCareConf#, #bNSPupdated#, '#form.cCurrentStatus#', '#form.cFinalOutcome#', #timestamp#, #session.userid#)
		</cfquery>
	</cfif>
<cfelseif isDefined("form.delinc")>
	<!--- delete the incident --->
	<cfquery name="deleteIncident" datasource="TIPS4">
		UPDATE TenantIncident SET dtRowDeleted = #timestamp#, iRowDeletedUser_ID = #session.userid# WHERE iTenantIncident_ID = #form.iTenantIncident_ID#
	</cfquery>
</cfif>

<body>

<SCRIPT LANGUAGE="JavaScript">				
 function doSel(obj)
 {
     for (i = 1; i < obj.length; i++)
        if (obj[i].selected == true)
           eval(obj[i].value);
}

	function hoverdesc(hoverstring){
		document.all['floater'].cursor ="hand";
		l = document.body.scrollLeft + event.x; 
		t = document.body.scrollTop + event.y;
		document.all['floater'].style.position = 'absolute'; 
		document.all['floater'].style.posLeft = l + 10;
		document.all['floater'].style.posTop = t -10; 
		//document.all['floater'].style.zindex = 'above';
		hovero = "<HTML><BODY><TABLE STYLE='font-weight: bold; border: 1px solid black; width:150px;'><TR><TD STYLE='background: lightyellow;'>" + hoverstring + "</TD></TR></TABLE></BODY></HTML>";
		document.frames[0].document.open();
		document.frames[0].document.write(hovero);
		document.frames[0].document.close();
		document.all['floater'].style.width = '150px';
		document.all['floater'].style.height = floaterwindow.document.body.scrollHeight+'px';
		timevar=setTimeout('resetdesc()',2000);
	}

	function resetdesc(){	
		clearTimeout(timevar);
		document.all['floater'].style.posLeft = 0; 
		document.all['floater'].style.posTop =  0; 
		document.all['floater'].style.width = '0px';
		document.all['floater'].style.height = '0px';		
	}
	
function check_form(form)
	{
	return_boolean = true
	 obj = eval(form)
	 for(i=0;i<obj.length;i++)
	 {
	  field_name = obj.elements[i].name;
	  if (field_name.indexOf("_ck") != -1)
	  {
	    if (obj.elements[i].value == "")
	    {
		  alert("You forgot to fill in a required field.  See yellow flag.");
	      obj.elements[i].style.backgroundColor = "yellow";
	      return_boolean = false
	    }
	    else
	    {
	      obj.elements[i].style.backgroundColor = "white";
	    }
	  }
	 } 
	return return_boolean;
	}
	
	
	function redirect() { window.location = "invoiceentry.cfm"; } 

</SCRIPT>

<cfquery name="getHouses" datasource="TIPS4">
select cName, iHouse_ID from HOUSE where dtRowDeleted IS NULL order by cName
</cfquery>

<cfoutput>
<form name="whatever">
	Select House: 
	<select name="iHouse_ID" onchange="doSel(this)">
	<option value=""></option>
	<cfloop query="getHouses">
	<option value="location.href='incidententry.cfm?iHouse_ID=#iHouse_ID#'"<cfif (isDefined("url.iHouse_ID") and url.iHouse_ID is "#getHouses.iHouse_ID#")> SELECTED</cfif>>#cName#</option>
	</cfloop>
	</select>
	
<cfif isDefined("url.iHouse_ID")>
	<cfquery name="getHouse" datasource="TIPS4">
		select cName from House where iHouse_ID = #iHouse_ID#
	</cfquery>
	<cfquery name="getResidents" datasource="TIPS4">
		select T.cFirstName, T.cLastName, T.iTenant_ID, T.cSolomonKey, TS.dtMoveOut from Tenant T
		inner join TenantState TS on T.iTenant_ID = TS.iTenant_ID and TS.dtRowDeleted IS NULL 
		where T.iHouse_ID = #url.iHouse_ID# and T.dtRowDeleted IS NULL order by T.cLastName, T.cFirstName, TS.dtMoveOut
	</cfquery>
	
	Select Resident: 
	<select name="iTenant_ID" onchange="doSel(this)">
	<option value=""></option>
	<cfloop query="getResidents">
	<option value="location.href='incidententry.cfm?iHouse_ID=#iHouse_ID#&iTenant_ID=#iTenant_ID#'"<cfif (isDefined("url.iTenant_ID") and url.iTenant_ID is "#getResidents.iTenant_ID#")> SELECTED</cfif>>#cLastName#, #cFirstName# (#cSolomonKey#)<cfif dtMoveOut is not ""> (#DateFormat(dtMoveOut,'M/D/YY')#)</cfif></option>
	</cfloop>
	</select>
	
	<cfif isDefined("iTenant_ID")>
		</form>
		<form method="post" action="incidententry.cfm" onSubmit="return check_form(this)">
		<cfquery name="getResident" datasource="TIPS4">
			select cFirstName + ' ' + cLastName as FULLNAME from Tenant where iTenant_ID = #iTenant_ID# and dtRowDeleted is null
		</cfquery>
		<cfif isDefined("url.iTenantIncident_ID")>
			<cfquery name="getInfo" datasource="TIPS4">
				select * from TenantIncident where iTenantIncident_ID = #url.iTenantIncident_ID#
			</cfquery>
			<cfset IMonth = #DatePart('m',getInfo.dtIncident)#>
			<cfset IDay = #DatePart('d',getInfo.dtIncident)#>
			<cfset IYear = #DatePart('yyyy',getInfo.dtIncident)#>
		</cfif>
		<p>

		<Table border=1>
		<TH COLSPAN="2"><cfif isDefined("url.iTenantIncident_ID")>Edit<cfelse>Enter</cfif> Incident For #getResident.Fullname#:</TH>
		<TR>
		<td CLASS="required">Date of Incident:</td>
		<td>
			<CFSET MONTH = '#Month(now())#'>
			<CFSET Day = '#Day(now())#'>
			<CFSET Year = '#Year(now())#'>	
			<SELECT NAME = "IncidentMonth_ck">
				<option value="">month</option>	
				<CFLOOP INDEX="I" FROM="1" TO="12" STEP="1">
					<OPTION VALUE="#I#"<cfif isDefined("url.iTenantIncident_ID") and IMonth is #I#> SELECTED<cfelseif not isDefined("url.iTenantIncident_ID") and Month is #I#> SELECTED</cfif>> #I# </OPTION>
				</CFLOOP>
			</SELECT>
			/ 
			<SELECT NAME = "IncidentDay_ck">
				<option value="">day</option>
				<CFLOOP INDEX="D" FROM="1" TO="31" STEP="1"> 					
					<OPTION VALUE="#D#"<cfif isDefined("url.iTenantIncident_ID") and IDay is #D#> SELECTED<cfelseif not isDefined("url.iTenantIncident_ID") and Day is #D#> SELECTED</cfif>> #D# </OPTION>
				</CFLOOP>
			</SELECT>	
			/
			<INPUT TYPE="Text" NAME="IncidentYear_ck" SIZE=3 MAXLENGTH=4 <cfif isDefined("url.iTenantIncident_ID")>value="#IYear#"<cfelse>value="#Year#"</cfif>>(YYYY)
		</td><Tr>
		<td>Event Description:</td><td><textarea name="cDescription" rows=5 cols=40><cfif isDefined("url.iTenantIncident_ID")>#getInfo.cDescription#</cfif></textarea></td><Tr>
		<td CLASS="required">Was this a....<BR>(Event type/category)</td><td>
		<input type="checkbox" name="bCat1"<cfif isDefined("url.iTenantIncident_ID") and getInfo.bCat1 is "1"> CHECKED</cfif>>Fall with Injury/Hospitalization<BR>
		<input type="checkbox" name="bCat2"<cfif isDefined("url.iTenantIncident_ID") and getInfo.bCat2 is "1"> CHECKED</cfif>>Fall with Head Injury/Hospitalization<BR>
		<input type="checkbox" name="bCat3"<cfif isDefined("url.iTenantIncident_ID") and getInfo.bCat3 is "1"> CHECKED</cfif>>Elopment<BR>
		<input type="checkbox" name="bCat4"<cfif isDefined("url.iTenantIncident_ID") and getInfo.bCat4 is "1"> CHECKED</cfif>>Elopment with Injury<BR>
		<input type="checkbox" name="bCat5"<cfif isDefined("url.iTenantIncident_ID") and getInfo.bCat5 is "1"> CHECKED</cfif>>Medication Error<BR>
		<input type="checkbox" name="bCat6"<cfif isDefined("url.iTenantIncident_ID") and getInfo.bCat6 is "1"> CHECKED</cfif>>Weight Loss/Failure to Thrive<BR>
		<input type="checkbox" name="bCat7"<cfif isDefined("url.iTenantIncident_ID") and getInfo.bCat7 is "1"> CHECKED</cfif>>Skin<BR>
		<input type="checkbox" name="bCat8"<cfif isDefined("url.iTenantIncident_ID") and getInfo.bCat8 is "1"> CHECKED</cfif>>Other<BR>
		</td><Tr>
		<td>Re-Assessment?</td><td><input type="checkbox" name="bReAssessment"<cfif isDefined("url.iTenantIncident_ID") and getInfo.bReAssessment is "1"> CHECKED</cfif>></td><Tr>
		<td>Care Conference?</td><td><input type="checkbox" name="bCareConf"<cfif isDefined("url.iTenantIncident_ID") and getInfo.bCareConf is "1"> CHECKED</cfif>></td><Tr>
		<td>NSP updated?</td><td><input type="checkbox" name="bNSPupdated"<cfif isDefined("url.iTenantIncident_ID") and getInfo.bNSPupdated is "1"> CHECKED</cfif>></td><Tr>
		<td>Current Status</td><td><textarea name="cCurrentStatus" rows=5 cols=40><cfif isDefined("url.iTenantIncident_ID")>#getInfo.cCurrentStatus#</cfif></textarea></td><Tr>
		<td>Final Outcome/Resolution:</td><td><textarea name="cFinalOutcome" rows=5 cols=40><cfif isDefined("url.iTenantIncident_ID")>#getInfo.cFinalOutcome#</cfif></textarea></td>
		<tr>
		<td colspan=2>
		<input type="hidden" name="iHouse_ID" value="#url.iHouse_ID#">
		<input type="hidden" name="iTenant_ID" value="#url.iTenant_ID#">
		<cfif isDefined("url.iTenantIncident_ID")><input type="submit" value="Edit Incident" name="subinc"><cfelse><input type="submit" value="Submit Incident" name="subinc"></cfif>
		<cfif isDefined("url.iTenantIncident_ID")>
		<input type="hidden" name="iTenantIncident_ID" value="#url.iTenantIncident_ID#">
		<input type="submit" value="Delete Incident" name="delinc">
		</cfif>  
		<input type="submit" name="cancelinc" value="Cancel" onClick="redirect()">
		</td>
		</tr>
		</Table>
	</cfif>
	
	<HR size=2 width=700 color="##0000AA" align=left>
	Previously Entered Incidents for #getHouse.cName#:<BR>
	<font size=-1>(Move mouse over underlined column title for more information)</font>
	<cfquery name="getIncidents" datasource="TIPS4">
		select TI.*, T.cFirstName + ' ' + T.cLastName as FULLNAME 
		from TenantIncident TI
		inner join Tenant T ON TI.iTenant_ID = T.iTenant_ID
		where TI.iHouse_ID = #iHouse_ID# and TI.dtRowDeleted IS NULL
		order by dtIncident DESC
	</cfquery>
	
	<cfif getIncidents.recordcount is not 0>
		<Table border=1>
		<tr>
		<th rowspan=2>Date</th><th rowspan=2>Resident</th><th rowspan=2>Event Description</th><th colspan=8>Categories</th><th rowspan=2><A HREF="##" STYLE="COLOR: White;" onMouseOver="hoverdesc('Re-Assessment');" onMouseOut="resetdesc();">RA</A></th><th rowspan=2><A HREF="##" STYLE="COLOR: White;" onMouseOver="hoverdesc('Care Conference');" onMouseOut="resetdesc();">CC</A></th><th rowspan=2><A HREF="##" STYLE="COLOR: White;" onMouseOver="hoverdesc('NSP Updated');" onMouseOut="resetdesc();">NU</A></th><th rowspan=2>Current Status</th><th rowspan=2><!--- Final Outcome/  --->Resolution</th><th rowspan=2>Edit</th>
		</tr>
		<tr>
		<th><A HREF="##" STYLE="COLOR: White;" onMouseOver="hoverdesc('Fall with injury/hospitalization');" onMouseOut="resetdesc();">1</A></th><th><A HREF="##" STYLE="COLOR: White;" onMouseOver="hoverdesc('Fall with head injury/hospitalization');" onMouseOut="resetdesc();">2</A></th><th><A HREF="##" STYLE="COLOR: White;" onMouseOver="hoverdesc('Elopment');" onMouseOut="resetdesc();">3</A></th><th><A HREF="##" STYLE="COLOR: White;" onMouseOver="hoverdesc('Elopement with injury');" onMouseOut="resetdesc();">4</A></th><th><A HREF="##" STYLE="COLOR: White;" onMouseOver="hoverdesc('Medication Error');" onMouseOut="resetdesc();">5</A></th><th><A HREF="##" STYLE="COLOR: White;" onMouseOver="hoverdesc('Weight loss/failure to thrive');" onMouseOut="resetdesc();">6</A></th><th><A HREF="##" STYLE="COLOR: White;" onMouseOver="hoverdesc('Skin');" onMouseOut="resetdesc();">7</A></th><th><A HREF="##" STYLE="COLOR: White;" onMouseOver="hoverdesc('Other');" onMouseOut="resetdesc();">8</A></th>
		</tr>
		<cfloop query="getIncidents">
		<Tr>
		<td>#DateFormat(dtIncident,'M/D/YY')#</td><Td>#FullName#</Td><td>#cDescription#</td><td><cfif bCat1 is "1">X</cfif></td><td><cfif bCat2 is "1">X</cfif></td><td><cfif bCat3 is "1">X</cfif></td><td><cfif bCat4 is "1">X</cfif></td><td><cfif bCat5 is "1">X</cfif></td><td><cfif bCat6 is "1">X</cfif></td><td><cfif bCat7 is "1">X</cfif></td><td><cfif bCat8 is "1">X</cfif></td><td><cfif bReassessment is "1">X</cfif></td><td><cfif bCareConf is "1">X</cfif></td><td><cfif bNSPupdated is "1">X</cfif></td><td>#cCurrentStatus#</td><td>#cFinalOutcome#</td><td><A HREF="incidententry.cfm?iHouse_ID=#iHouse_ID#&iTenant_ID=#iTenant_ID#&iTenantIncident_ID=#iTenantIncident_ID#"><img src="Edit.gif" border=0></A></td>
		</Tr>
		</cfloop>
		</Table>
	<cfelse>
	<p><em>&##160; &##160; &##160; &##160; Sorry, no previously entered incidents were found for this house.</em>
	</cfif>
	<HR size=2 width=700 color="##0000AA" align=left>
</cfif>
<p></p>

</cfoutput>
<BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR>
</body>
</html>
