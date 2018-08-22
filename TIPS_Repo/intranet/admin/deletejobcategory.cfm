<!--------------------------------------->
<!--- Programmer: Andy Leontovich     --->
<!--- File: deletejobcategory.cfm          --->
<!--- Company: Maxim Group/ALC        --->
<!--- Date: july                       --->
<!--------------------------------------->
<cfset datasource = "DMS">
<cfquery name="getcatagory" datasource="#datasource#" dbtype="ODBC">
Select heading
From jobtoc
Where toc_ndx = #toc_ndx#
</cfquery> 


<cfinclude template="/intranet/header.cfm">
<ul>
	<form action="jobaction.cfm" method="post">
		<table width="400" cellspacing="2" cellpadding="2" border="0">
		<tr bgcolor="#663300">
    <td colspan="7"><font color="White" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: medium;">Delete Job Category</font></td>
</tr>
		<tr bgcolor="#f7f7f7">
		    <td><font color="#cc3300" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Are you sure you want to delete this job category?</font>
			<BR>
			<BR>
			<ul><cfoutput>
				<font color="DimGray" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Heading:</font> <font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small;">#getcatagory.heading#</font><BR>
			</cfoutput></ul>
			</td>
		</tr>
		<tr bgcolor="#eaeaea">
		    <td><input type="submit" name="Submit" value="Delete This Category">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type="button" name="back" value="Cancel" onClick="history.back();"></td>
			
		</tr>
		</table>
		
	<cfoutput>	<input type="hidden" name="function" value="3">
<input type="hidden" name="taskid" value="1">
<input type="hidden" name="toc_ndx" value="#toc_ndx#"></cfoutput>
	</form>
</ul>



<cfinclude template="/intranet/Footer.cfm">

