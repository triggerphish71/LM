 <!--------------------------------------->
<!--- Programmer: Andy Leontovich     --->
<!--- File: admin/usermgmt/bioreport.cfm  --->
<!--- Company: Maxim Group/ALC        --->
<!--- Date: November                  --->
<!--------------------------------------->
<cfset datasource = "DMS">

<cfquery name="getinfo" datasource="#datasource#" dbtype="ODBC">
	Select expires,passexpires,username,password
	From users
	Where employeeid = '#userid#'
</cfquery>

<cfquery name="getemp" datasource="#datasource#" dbtype="ODBC">
	Select fname,lname,jobtitle,email,ndepartmentnumber
	From vw_employees
	Where employee_ndx = '#userid#'
</cfquery>

<cfquery name="getempdept" datasource="#datasource#" dbtype="ODBC">
	Select Department
	From vw_Departments
	Where department_ndx = #getemp.ndepartmentnumber#
</cfquery>

<cfquery name="getusersgroups" datasource="#datasource#" dbtype="ODBC">
	SELECT distinct vw_employees.employee_ndx,vw_employees.fname,vw_employees.lname,users.username,groups.groupname
	FROM vw_employees,users,codeblocks,groupassignments,groups
	WHERE vw_employees.employee_ndx = users.employeeid 
		AND users.employeeid = groupassignments.userid
		AND groupassignments.groupid = groups.groupid 
		AND vw_employees.employee_ndx = #userid#
		Order BY vw_employees.fname
</cfquery>

<!--- comment: The following queries are for the Content Possessions section of this page--->
<!--- comment: query employees--->
<cfquery name="getemployees2" datasource="ALCWeb" dbtype="ODBC">
SELECT fname,lname
FROM employees
WHERE created_by_user_id = #userid#
</cfquery>

<!--- comment: Query users--->
<cfquery name="getusers" datasource="#datasource#" dbtype="ODBC">
SELECT username,fname,lname
FROM users,vw_employees
WHERE created_by_user_id = #userid# AND users.employeeid = vw_employees.employee_ndx
</cfquery>

<!--- comment: Query Groups and assignments--->
<cfquery name="getgroups" datasource="#datasource#" dbtype="ODBC">
SELECT groupname
FROM groups
WHERE user_id = #userid# 
</cfquery>

<!--- comment: Query releases --->
<cfquery name="getreleases" datasource="#datasource#" dbtype="ODBC">
SELECT cHeading
FROM releases
WHERE postedby = #userid# 
</cfquery>

<!--- comment: Query mediainfo--->
<cfquery name="getmedia" datasource="#datasource#" dbtype="ODBC">
SELECT distinct title
FROM mediainfo,medialocation
WHERE uploadedby = #userid# 
</cfquery>

<!--- comment: Query categories--->
<cfquery name="getcategories2" datasource="#datasource#" dbtype="ODBC">
SELECT name
FROM categories
WHERE user_id = #userid#
</cfquery>

<!--- comment: Query Joblistings--->
<cfquery name="getJoblistings" datasource="#datasource#" dbtype="ODBC">
SELECT jobtitle,jobnumber
FROM joblistings
WHERE submittedby = #userid# 
</cfquery>

<!--- comment: Query JobTOC--->
<cfquery name="getjobtoc" datasource="#datasource#" dbtype="ODBC">
SELECT heading
FROM jobtoc
WHERE user_id = #userid# 
</cfquery>

<cfinclude template="/intranet/header.cfm">

	<script language="JavaScript1.2" type="text/javascript">
<!--
		function possession(urlname,hsize,vsize){
	    var tb="width="+hsize+",height="+vsize;
	    //if(tb.indexOf("<undefined>")!=-1)
	     //  Win_1 = window.open("","win1","width=hsize,height=vsize,scrollbars=no,resizable=1");
	       window.open(urlname,"win1","width=300,height=145,scrollbars=no,resizable=1");
	    }

//-->
</script>
<style type="text/css">
<!--
.labels {  font-family: Verdana, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold; color: DimGray}
.titles {  font-family: Verdana, Arial, Helvetica, sans-serif; font-size: medium}
.headings {  font-family: Verdana, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold; color: #006699}
.data {  font-family: Verdana, Arial, Helvetica, sans-serif; font-size: x-small; color: #336699}
.change {  font-family: Verdana, Arial, Helvetica, sans-serif; font-size: xx-small; font-weight: bold; color: #0099CC}
-->
</style>


<table width="650" border="0" cellspacing="2" cellpadding="2">
  <tr bgcolor="#9999CC"> 
    <td colspan="3"><font color="#FFFFFF" face="Verdana, Arial, Helvetica, sans-serif" size="3" class="titles">User 
      Management Summary</font></td>
  </tr>
  <tr> 
    <td valign="top" bgcolor="#f7f7f7"><span class="headings">Demographic</span>
      <BR>
      <table width="283" border="0" cellspacing="2" cellpadding="2">
	 <cfoutput query="getemp"> 
        <tr bgcolor="##FFFFFF"> 
          <td width="92" class="labels">First Name:</td>
          <td width="177" class="data">#fname#</td>
        </tr>
        <tr bgcolor="##FFFFFF"> 
          <td width="92" class="labels">Last Name:</td>
          <td width="177" class="data">#lname#</td>
        </tr>
        <tr bgcolor="##FFFFFF"> 
          <td width="92" class="labels">Title:</td>
          <td width="177" class="data">#jobtitle#</td>
        </tr>
        <tr bgcolor="##FFFFFF"> 
          <td width="92" class="labels">Email:</td>
          <td width="177" class="data">#email#</td>
        </tr>
	</cfoutput>
	<cfoutput query="getempdept">
		 <tr bgcolor="##FFFFFF"> 
          <td width="92" class="labels">Department:</td>
          <td width="177" class="data">#department#</td>
        </tr>
	</cfoutput>
      </table>
      <p align="right" class="headings"><cfoutput><a href="/intranet/admin/usermgmt/updateview.cfm?userid=#userid#" class="change">Change</a></cfoutput></p>
    </td>
    <td rowspan="2" valign="top" bgcolor="#eaeaea">
      <p align="center">
	  <span class="headings">Group Assignments</span>
	  <br><font color="Maroon" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: xx-small;">For viewing only.</font><br>
        <select name="grouplisting" size="15">
		<cfoutput query="getusersgroups"><option>#groupname#</option></cfoutput>
        </select>
      </p>
<cfoutput><p align="right" class="headings"><a href="/intranet/admin/securityassignment.cfm?userid=#userid#&function=1" class="change">Change</a></p></cfoutput>
    </td>
    <td rowspan="2" valign="top" bgcolor="#CCCCCC">
      <p align="center"><span class="headings">Content Possessions</span>
	  <br><font color="Maroon" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: xx-small;">For viewing only.</font><br>
        <cfif getemployees2.recordcount is 0 AND getusers.recordcount is 0 AND getgroups.recordcount is 0 AND getreleases.recordcount is 0 AND getmedia.recordcount is 0 AND getcategories2.recordcount is 0 AND getjoblistings.recordcount is 0 AND getjobtoc.recordcount is 0>
			<br><br>
			<font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">None Found</font>
		<cfelse>

		<select name="possesions" size="15" multiple>
		
			<cfif getemployees2.recordcount is not 0>
			<option Selected>
	  			Employees
			</option>
			<cfoutput query="getemployees2">
			<option>
	  			&nbsp;#fname# #lname#
			</option>
			</cfoutput>
			</cfif>
		
	
			<cfif getgroups.recordcount is not 0>
			<option>
	  			
			</option>
			<option Selected>
	  			Groups
			</option>
			<cfoutput query="getgroups">
			<option>
	  			&nbsp;#groupname#
			</option>
			</cfoutput>
			</cfif>
		
		
			<cfif getreleases.recordcount is not 0>
			<option>
	  			
			</option>
			<option Selected>
	  			Releases
			</option>
			<cfoutput query="getreleases">
			<option>
	  			&nbsp;#cHeading#
			</option>
			</cfoutput>
			</cfif>
		
		
			<cfif getmedia.recordcount is not 0>
			<option>
	  			
			</option>
			<option Selected>
	  			Files
			</option>
			<cfoutput query="getmedia">
			<option>
	  			&nbsp;#title#
			</option>
			</cfoutput>
			</cfif>
		
		
			<cfif getJoblistings.recordcount is not 0>
			<option>
	  			
			</option>
			<option Selected>
	  			Job Listings
			</option>
			<cfoutput query="getJoblistings">
			<option>
	  			&nbsp;#jobtitle# #jobnumber#
			</option>
			</cfoutput>
			</cfif>
		
		
			<cfif getjobtoc.recordcount is not 0>
			<option>
	  			
			</option>
			<option Selected>
	  			Job Categories
			</option>
			<cfoutput query="getjobtoc">
			<option>
	  			&nbsp;#heading#
			</option>
			</cfoutput>
			</cfif>
		
		
			<cfif getusers.recordcount is not 0>
			<option>
	  			
			</option>
			<option Selected>
	  			Users
			</option>
			<cfoutput query="getusers">
			<option>
	  			&nbsp;#username#...#fname# #lname#<br>
			</option>
			</cfoutput>
			</cfif>
		
			<cfif getcategories2.recordcount is not 0>
			<option>
	  			
			</option>
			<option Selected>
	  			Library Categories
			</option>
			<cfoutput query="getcategories2">
			<option>
	  			&nbsp;#name#
			</option>
			</cfoutput>
			</cfif>
        </select>
		</cfif>
      </p>
	 <cfif getemployees2.recordcount is not 0 OR getusers.recordcount is not 0 OR getgroups.recordcount is not 0 OR getreleases.recordcount is not 0 OR getmedia.recordcount is not 0 OR getcategories2.recordcount is not 0 OR getjoblistings.recordcount is not 0 OR getjobtoc.recordcount is not 0>
	<cfoutput>
		<p align="right" class="headings"><a href="##" class="change" onClick="possession('/intranet/admin/usermgmt/possesionreassignment.cfm?userid=#userid#',300,400)">Change</a></p>
	</cfoutput>
	 </cfif>
	 </td>
  </tr>
<cfoutput query="getinfo">  
  <tr> 
    <td valign="top" bgcolor="##f7f7f7"><span class="headings">Log 
      In</span><br>
      <table width="283" border="0" cellspacing="2" cellpadding="2">
        <tr bgcolor="##FFFFFF"> 
          <td width="135" class="labels">Username:</td>
          <td width="134" class="data">#username#</td>
        </tr>
        <tr bgcolor="##FFFFFF"> 
          <td width="135" class="labels">Password:</td>
          <td width="134" class="data">#password#</td>
        </tr>
        <tr bgcolor="##FFFFFF"> 
          <td width="135" class="labels">Password Expires:</td>
          <td width="134" class="data">#dateFormat(passexpires,"mm/dd/yy")#</td>
        </tr>
        <tr bgcolor="##FFFFFF"> 
          <td width="135" class="labels">User Expires:</td>
          <td width="134" class="data">#DateFormat(expires,"mm/dd/yy")#</td>
        </tr>
</cfoutput>
     </table>
<cfoutput><p align="right" class="headings"><a href="/intranet/admin/usermgmt/updateview.cfm?userid=#userid#" class="change">Change</a></p></cfoutput>
    </td>
  </tr>
</table>

<cfinclude template="/intranet/Footer.cfm">

