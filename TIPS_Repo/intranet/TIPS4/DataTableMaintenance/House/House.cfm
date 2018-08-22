

<!--- =============================================================================================
Retrieve information for all houses
============================================================================================= --->
<CFQUERY NAME = "HOUSE" 	DATASOURCE = "#APPLICATION.datasource#">
	SELECT	H.*, OA.cName as Region, R.cName as Division
	FROM 	HOUSE H
	JOIN	OpsArea OA ON (OA.iOpsArea_ID = H.iOpsArea_ID AND OA.dtRowDeleted IS NULL)
	JOIN	Region R ON (R.iRegion_ID = OA.iRegion_ID AND R.dtRowDeleted IS NULL)
	WHERE	H.dtRowDeleted IS NULL
	<CFIF IsDefined("url.sort") AND url.sort EQ 'Nbr'>
		ORDER BY H.cNumber
	<CFELSEIF IsDefined("url.sort") AND url.sort EQ 'Name'>
		ORDER BY H.cNAME
	<CFELSEIF IsDefined("url.sort") AND url.sort EQ 'City'>
		ORDER BY H.cCity
	<CFELSEIF IsDefined("url.sort") AND url.sort EQ 'State'>
		ORDER BY H.cStateCode
	<CFELSEIF IsDefined("url.sort") AND url.sort EQ 'div'>
		ORDER BY R.cName, H.cName
	<CFELSEIF IsDefined("url.sort") AND url.sort EQ 'reg'>
		ORDER BY OA.cName, H.cName			
	<CFELSE>
		ORDER BY R.cName, H.cNAME
	</CFIF>
</CFQUERY>

<SCRIPT>function microsoftKeyPress() { var key = ('#' +(String.fromCharCode(window.event.keyCode))); location.hash = key; }</SCRIPT>

<!--- =============================================================================================
Include the intranet header
============================================================================================= --->
<CFINCLUDE TEMPLATE = "../../../header.cfm">
<H1	CLASS = "PAGETITLE">House Administration</H1>
<HR>
<CFOUTPUT>
	<A Href="../../Admin/Menu.cfm" style="Font-size: 18;">Click Here to Go Back To Administration Screen.</a>
</CFOUTPUT>
<BR><BR>

<CFIF session.userid IS 3025 OR Session.UserID IS 36>
	<A HREF = "HouseEdit.cfm?Insert=1" CLASS = "Summary">	Create New House	</A>
</CFIF>
<BR>
<BR>

<BODY onKeyPress="microsoftKeyPress();">
<TABLE STYLE="width: 0;">
<TH> <A HREF="House.cfm?sort=div" STYLE="COLOR: WHITE;">	Division	</A> </TH> 
<TH> <A HREF="House.cfm?sort=reg" STYLE="COLOR: WHITE;">	Region		</A> </TH>
<TH> <A HREF="House.cfm?sort=Nbr" STYLE="COLOR: WHITE;">	Number		</A> </TH> 
<TH> <A HREF="House.cfm?sort=Name" STYLE="COLOR: WHITE;">	House Name	</A> </TH>
<TH> <A HREF="House.cfm?sort=City" STYLE="COLOR: WHITE;">	City		</A> </TH>
<TH> <A HREF="House.cfm?sort=State" STYLE="COLOR: WHITE;">	State		</A> </TH>
<TH>	Delete	</TH>	

<CFOUTPUT QUERY="HOUSE" STARTROW="1" MAXROWS="#House.RecordCount#">
	<SCRIPT> function validatedelete#House.iHouse_ID#() { if (confirm('Are you sure you want to delete the #House.cName#')){ self.location.href='DeleteHouse.cfm?typeID=#HOUSE.iHouse_ID#'; } }	</SCRIPT>
	<cf_cttr colorOne="FFFFFF" colorTwo="EEEEEE">	
		<TD><A HREF = "HouseEdit.cfm?HID=#HOUSE.iHouse_ID#" CLASS = "HLINK">#House.Division#</A></TD>
		<TD><A HREF = "HouseEdit.cfm?HID=#HOUSE.iHouse_ID#" CLASS = "HLINK">#House.Region#</A></TD>
		<TD><A HREF = "HouseEdit.cfm?HID=#HOUSE.iHouse_ID#" CLASS = "HLINK">#House.cNumber#</A></TD>
		<TD><A NAME="###Left(House.cName,1)#" HREF = "HouseEdit.cfm?HID=#HOUSE.iHouse_ID#" CLASS = "HLINK">#HOUSE.CNAME#</A></TD>
		<TD><A HREF = "HouseEdit.cfm?HID=#HOUSE.iHouse_ID#" CLASS = "HLINK">#House.cCity#</A></TD>
		<TD><A HREF = "HouseEdit.cfm?HID=#HOUSE.iHouse_ID#" CLASS = "HLINK">#House.cStateCode#</A></TD>
		<TD><INPUT CLASS = "BlendedButton" TYPE="button" NAME="Delete" VALUE="Delete Now" onClick="validatedelete#House.iHouse_ID#();"></TD>
	</cf_ctTR>
</CFOUTPUT>
</TABLE>
<BR>
<BR>

<CFOUTPUT><A Href="../../Admin/Menu.cfm" style="Font-size: 18;">Click Here to Go Back To Administration Screen.</a></CFOUTPUT>

<!--- =============================================================================================
Include the intranet footer
============================================================================================= --->
<CFINCLUDE TEMPLATE = "../../../footer.cfm">
