<!----------------------------------------------------------------------------------------------
| DESCRIPTION   RDOClose_Mainpage.cfm                                                          |
|----------------------------------------------------------------------------------------------|
| STORED PROCEDURES                                                                            |
|----------------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                        |
|------------|------------|--------------------------------------------------------------------|
| Gthota     | 09/21/2017 | Create Multiple House closing                                      |
|ganga       |04/05/2018  | Added is not null to isAssetClass                                  |
----------------------------------------------------------------------------------------------->
<CFINCLUDE TEMPLATE="../../header.cfm">
<H1 CLASS="PageTitle"> Tips 4 - Administrative Tasks </H1>

<CFINCLUDE TEMPLATE="../Shared/HouseHeader.cfm">


<CFOUTPUT>
<!--- Retrieve House Month Information--->
<CFQUERY NAME = "HouseLog" DATASOURCE = "#APPLICATION.datasource#">
	SELECT	bIsPDClosed, bIsCentralized,dtActualEffective,dtAcctStamp,dtCurrentTipsMonth FROM HouseLog
    WHERE iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID# AND dtRowDeleted IS NULL
</CFQUERY>
<!--- display houses --->
<CFQUERY NAME="qRegion" DATASOURCE="#APPLICATION.datasource#">
	select iOpsArea_id, cName,iRegion_id from OPSAREA where dtrowdeleted is null
</CFQUERY>
<CFQUERY NAME="qtipsmonth" DATASOURCE="#APPLICATION.datasource#">
	select * from dbo.TIPSInvoiceMonth where dtrowdeleted is null
</CFQUERY>


<cfset now = #now()#>
<cfset month = #MonthAsString(Month(Now()))#> 
<cfset housemonth = #MonthAsString(Month(qtipsmonth.dtacctstamp))# >

<cfif #Month(qtipsmonth.dtCurrentTipsMonth)# EQ 1>    
    <cfset month1 = #MonthAsString(Month(qtipsmonth.dtCurrentTipsMonth)+11)# >
<cfelse>
    <cfset month1 = #MonthAsString(Month(qtipsmonth.dtCurrentTipsMonth)-1)# >
</cfif>



<cfoutput> month - #month# / housemonth - #housemonth#  / month1 - #month1#  </cfoutput>


<cfform name = "HouseMonth" ACTION="Multiple_Month.cfm" METHOD="POST">
<TABLE border ="1">
	<TR><TH COLSPAN="3"> TIPS Current Invoice Month	</TH></TR>
	<TR>	 
	   <TD><P STYLE="color: ##0000FF; font-size: medium;"> Closing the TIPS Invoice month of #DateFormat(qtipsmonth.dtCurrentTipsMonth, "mmmm, yyyy")# - </P></TD>
	 	  	
	<cfif isDefined("Submit")>				
		<cfset  TIclosedate = #DateFormat(DateAdd('m', +1, form.dtCurrentTipsMonth),'yyyy-mm-dd')#>
		<cfset  TImonth = #MonthAsString(Month(TIclosedate))#>	
			
		<CFQUERY NAME="qtipsmonth" DATASOURCE="#APPLICATION.datasource#">
			UPDATE dbo.TIPSInvoiceMonth set dtRowdeleted = getdate() where dtrowdeleted is null			
		</CFQUERY>
		
		<CFQUERY NAME="qmonthvalid" DATASOURCE="#APPLICATION.datasource#">
			SELECT * FROM TIPSInvoiceMonth WHERE dtRowDeleted= (SELECT MAX(dtRowDeleted) FROM TIPSInvoiceMonth)
		</CFQUERY>
		
		<cfset monthtoday = #MonthAsString(Month(Now()))#>
		<cfset monthofInvoice = #MonthAsString(Month(qmonthvalid.DtAcctStamp))#>
		<cfif #monthtoday# NEQ #monthofInvoice#>
		 <CFQUERY NAME="qtipsmonth" DATASOURCE="#APPLICATION.datasource#">
			Insert INTO dbo.TIPSInvoiceMonth(cName,dtCurrentTipsMonth,dtAcctStamp,iRowStartUser)
			  Values('#TImonth#','#TIclosedate#',getdate(),'#SESSION.Username#')			
		</CFQUERY>
		</cfif>
	<cfelse>
		 <cfif #housemonth# EQ #month#>
		  <TD> <P STYLE="color: red; font-size: medium;">TIPS current Invoice month of #DateFormat(qtipsmonth.dtCurrentTipsMonth, "mmm, yyyy")#  </P></TD>
		 <cfelse>
			<form name="invmonth" method="post">
			  <TD> <INPUT TYPE="checkbox" NAME="invmonth" value ="invmonth"> </TD>
			  <TD>		 
			   <input type="hidden" name="dtCurrentTipsMonth" value="#qtipsmonth.dtCurrentTipsMonth#">
			   <input name="submit" value = "SUBMIT" type ="submit" >		  						
			  </TD>
			</form>
		</cfif>	
	</cfif>		
	</TR>
</TABLE>
</cfform>
<font color="red">Note:</font> If you want to close for TIPS invoice month, will be available for 1st of every month period </font>
<!--- <br/>#month#  / month +1 = #month1#    / <br/> tips month -#housemonth#  / tips month -1 = #housemonth1#  --->

<H3 CLASS="PageTitle"> Tips 4 - AR Accounting Close Tasks </H3>
 <!--- <cfform name = "Housinfo" ACTION="RDOClose_landingpage.cfm" METHOD="POST"> --->
 <cfform name = "Housinfo" ACTION="RDOClose_Multiple.cfm" METHOD="POST"> 

 
<TABLE style="width:500" border ="2">	
	<TR bgcolor ="DarkCyan">	
	 <td>&nbsp; Region Id's &nbsp;</td>
	 <td>&nbsp; Region Names &nbsp;</td>
	 <td>&nbsp; House Close &nbsp;</td>
	 <td>&nbsp; Missing Houses &nbsp;</td>
	 </TR>
	 <CFSET Checked = ''>
	<!--- <cfdump var ='#qHouses#'>  --->
	 <cfloop query ='qRegion'> 
	 	<CFQUERY NAME="qHouse" DATASOURCE="#APPLICATION.datasource#">
			Select ihouse_id,cname,iopsarea_id,cNumber 
			from House with (nolock)
				where iOpsArea_id = #iOpsArea_id# 
				and bisSandbox = 0 
				and dtrowdeleted is null
		</CFQUERY>
		<CFQUERY NAME="qHouseCloseing" DATASOURCE="#APPLICATION.datasource#">
			SELECT h.ihouse_id as ihouseid,h.cname,h.iopsarea_id,h.cNumber 
			  FROM House h with (nolock)
			  Join HouseLog hl with (nolock) ON h.ihouse_id = hl.iHouse_id and hl.dtrowdeleted is null
			   WHERE iOpsArea_id = #iOpsArea_id# and h.dtrowdeleted is null
			    AND hl.dtCurrentTipsMonth < '#qtipsmonth.dtCurrentTipsMonth#'
			    AND 	h.ihouse_id <> 200 and h.bisSandbox = 0 
              <!--- ganga 4/5/18 --->
                AND h.AssetClass is not null 
               <!--- end ganga --->
		</CFQUERY>  
		
		<TR>
		<td>#iOpsArea_id# </td>					
		<td> #cName# </td>
		<td align="center">
		   <cfif qHouse.RecordCount GT 0>
		     <cfif qHouseCloseing.RecordCount GT 0>		 
		      <input type ="Radio" id ="radio" name = "iOpsArea_id" value="#iOpsArea_id#">
		     <cfelse>
		        <P STYLE="color: ##0000ff; font-size: medium;">Closed</P>
		     </cfif>  		 
		   <cfelse> 
		      <P STYLE="color: red; font-size: medium;">-None-</P>
		   </cfif> 		   
		  <td align="center"> 
		 <!--- <input type ="Radio" id ="radio" name = "hdemail" value="#iOpsArea_id#" #Variables.Checked# onClick="wait(false,'hdemail.cfm');"> --->
		  <A HREF="../admin/hdemail.cfm?iOpsArea_id=#iOpsArea_id#"> OK </A> 
		</td>
	    </td>		
		</TR>		
	 </cfloop>
	
	</TABLE>
	<table style="width:500">
	 <CFQUERY NAME="qHouseCloseings" DATASOURCE="#APPLICATION.datasource#">
			Select h.ihouse_id as ihouseid, h.iOpsArea_id
				FROM House h
 				JOin HouseLog hl on h.ihouse_id = hl.iHouse_id and hl.dtrowdeleted is null
				Join OPSAREA oa on h.iOpsArea_id = oa.iOpsArea_id and oa.dtrowdeleted is null
				   Where h.dtrowdeleted is null AND hl.dtCurrentTipsMonth = '#qtipsmonth.dtCurrentTipsMonth#'
				   AND 	h.ihouse_id <> 200	and h.bisSandbox = 0 	
				<!--- ganga 4/5/18 --->
				 AND h.AssetClass is not null    
				 <!--- end ganga 4/5/18 --->
		</CFQUERY>  
	 <TR align="right">
	    <TD> 
	<!---  <cfif qHouseCloseings.RecordCount GT 0>  --->
	        <input name="submit" value = "Accounting Close" type ="submit" style="font-size:12pt;color:white;background-color:##8B0000;border:2px solid green;padding:3px;">  
	<!---     <cfelse>
	        <P STYLE="color: red; font-size: medium;">All Regions Closed</P>
	     </cfif>   --->
	    </TD>
	 </TR>
	</table>
</cfform>

Go back to previous screen  <A HREF="javascript:history.go(-2)"> Click Here </a> <br/><br/>
<A Href="../../../intranet/Tips4/MainMenu.cfm" style="Font-size: 18;">Click Here to Go Back To Main Screen</a>



</CFOUTPUT>


