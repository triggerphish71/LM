<!----------------------------------------------------------------------------------------------
| DESCRIPTION   RDOClose_Multiple.cfm                                                              |
|----------------------------------------------------------------------------------------------|
| STORED PROCEDURES                                                                            |
|----------------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                        |
|------------|------------|--------------------------------------------------------------------|
| Gthota     | 09/27/2017 | Create Flower Box                                                  |
----------------------------------------------------------------------------------------------->
<CFINCLUDE TEMPLATE="../../header.cfm">
<H1 CLASS="PageTitle"> Tips 4 - Administrative Tasks </H1>

<cfoutput>


<cfflush interval=10> 
<!--- Delay Loop to make it seem harder. ---> 
<cfloop index="randomindex" from="1" to="200000" step="1"> 
<cfset random=rand()> 
</cfloop>

<cfparam  name="form.iOpsArea_id" default="">
<cfif !isDefined(form.iOpsArea_id)>
	<cfif form.iOpsArea_id is ''>
	Please select a Region to Accounting Close<br />
	<a href="../Admin/RDOClose_mainpage.cfm">Return to AR Accounting close Menu</a>
	<cfabort>
   </cfif>	
</cfif>
 Please wait until all the houses close..!  
<TABLE style="width:500" border ="2">	
	<CFQUERY NAME="qregionname" DATASOURCE="#APPLICATION.datasource#">
		SELECT cname
		  FROM OpsArea
		   WHERE iOpsArea_id = #form.iOpsArea_id# and dtrowdeleted is null	  
	</CFQUERY>
	<TR bgcolor ="DarkCyan">	
	 <td>&nbsp; #qregionname.cname# region Invoice month closing... </br>
	 Please wait..! &nbsp;</td>
	 </TR>	
	</TABLE>
</cfoutput>
<cfabort>
