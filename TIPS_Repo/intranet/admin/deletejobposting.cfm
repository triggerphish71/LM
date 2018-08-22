<!--------------------------------------->
<!--- Programmer: Andy Leontovich     --->
<!--- File: deletejobpost.cfm          --->
<!--- Company: Maxim Group/ALC        --->
<!--- Date: july                       --->
<!--------------------------------------->

<cfset datasource = "DMS">

<cfquery name="getlisting2" datasource="#datasource#" dbtype="ODBC">
Select distinct joblistings.Form_Ndx,jobtoc.heading,joblistings.jobtitle,vw_houses.housename,vw_regions.regionname,joblistings.activedate,joblistings.closedate,joblistings.reviewedby,joblistings.show,joblistings.notes
From joblistings,jobtoc,vw_regions,vw_houses
Where joblistings.nregionnumber = vw_regions.nregionnumber
AND joblistings.nhouse = vw_houses.nhouse
AND joblistings.tocid = jobtoc.toc_ndx
AND vw_regions.nregionnumber = #url.region#
AND joblistings.submittedby = #session.userid#"
</cfquery>


<cfinclude template="/intranet/header.cfm">
<ul>
	<form action="jobaction.cfm" method="post">
		<table width="400" cellspacing="2" cellpadding="2" border="0">
		<tr bgcolor="#663300">
    <td colspan="7"><font color="White" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: medium;">Delete Job Posting</font></td>
</tr>
		<tr bgcolor="#f7f7f7">
		    <td><font color="#cc3300" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Are you sure you want to delete this job posting?</font>
			<BR>
			<BR>
			<ul><cfoutput query="getlisting2" startrow=1 maxrows=1>
				<font color="DimGray" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Region:</font> <font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small;">#getlisting2.regionname#</font><BR>
				<font color="DimGray" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">House:</font> <font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small;">#getlisting2.housename#</font><BR>
				<font color="DimGray" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">HR Approval:</font> <font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small;">#getlisting2.reviewedby#</font><BR>
				<font color="DimGray" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;"><font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small;">View/Hide:</font> </font>
				<cfif getlisting2.show is 1>
					<font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small;">Viewable</font>
				<cfelse>
					<font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small;">Hidden</font>
				</cfif>
				<BR>
				<font color="DimGray" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Active Date:</font><font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small;"> #getlisting2.activedate#</font><BR>
				<font color="DimGray" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Expiration Date: </font><font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small;">#getlisting2.closedate#</font><BR>
				<font color="DimGray" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Notes:</font><BR>
				<font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small;">#getlisting2.notes#</font>
			</cfoutput></ul>
			</td>
		</tr>
		<tr bgcolor="#eaeaea">
		    <td>
			<input type="hidden" name="function" value="3">
			<input type="hidden" name="taskid" value="2">
		<cfoutput>	
			<input type="hidden" name="listingindex" value="#getlisting2.form_ndx#">
			<input type="hidden" name="region" value="#url.region#">
		</cfoutput>
			<input type="submit" name="Submit" value="Delete This Posting">
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			<input type="button" name="back" value="Cancel" onClick="history.back();">
			</td>
			
		</tr>
		</table>
	</form>
</ul>



<cfinclude template="/intranet/Footer.cfm">

