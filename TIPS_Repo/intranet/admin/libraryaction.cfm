<!--------------------------------------->
<!--- Programmer: Andy Leontovich     --->
<!--- File: admin/libraryaction.cfm   --->
<!--- Company: Maxim Group/ALC        --->
<!--- Date: june                      --->
<!--------------------------------------->
<cfset datasource = "DMS">


<cfif function is 1>
	<cfif Libselectiontype is 1>
	
		<cfquery name="checkcategories" datasource="dms" dbtype="ODBC">
		exec check_categories '#Trim(name)#'
		</cfquery>
		
		<cfif checkcategories.errorflag is 1>
			<cflocation url="error.cfm?errorid=3" addtoken="No">
		</cfif>
	
		<cfquery name="insertcategories" datasource="#datasource#" dbtype="ODBC">
		insert into categories(name,visible,user_id,created_date)
		Values('#Trim(name)#',#visible#,#session.userid#,'#DateFormat(Now(),"mm/dd/yy")#')
		</cfquery>
		
		<cfquery name="getcats" datasource="#datasource#" dbtype="ODBC">
		Select uniqueid
		From categories
		Where name = '#Trim(name)#'
		</cfquery>
		
		<cfquery name="insertcatassign" datasource="#datasource#" dbtype="ODBC">
		insert into cattopicassgn(categoryid)
		Values('#getcats.uniqueid#')
		</cfquery>
		
		<cflocation url="libconfimation.cfm?function=1&Libselectiontype=1" addtoken="No">
		
	<cfelseif Libselectiontype is 2>
	
	<!--- comment: these Topic queries will not be run untill Topics are part of the system. Even though the codes is not commented out, it has no impact upon the system--->
		<cfquery name="inserttopicss" datasource="#datasource#" dbtype="ODBC">
		insert into topics(name,visible)
		Values('#Trim(name)#',#visible#)
		</cfquery>
		
		<cfquery name="gettopicid" datasource="#datasource#" dbtype="ODBC">
		Select uniqueid
		From topics
		Where name = '#Trim(name)#' and visible = #visible#
		</cfquery>
		
		<cfquery name="insertcta" datasource="#datasource#" dbtype="ODBC">
		insert into cattopicassgn(topicid,categoryid)
		Values('#gettopicid.uniqueid#',#categoryid#)
		</cfquery>
		
		<cflocation url="libconfimation.cfm?function=1&Libselectiontype=2" addtoken="No">
	</cfif>
	
<cfelseif function is 2>
	<cfif Libselectiontype is 1>
		<cfquery name="updatecategories" datasource="#datasource#" dbtype="ODBC">
		Update categories
		Set name = '#Trim(name)#',
		visible = #visible#
		Where uniqueid = #categoryid#
		</cfquery>
		<cflocation url="libconfimation.cfm?function=2&Libselectiontype=1" addtoken="No">
	<cfelseif Libselectiontype is 2>
		<cfquery name="updatetopics" datasource="#datasource#" dbtype="ODBC">
		Update topics
		Set name = '#Trim(name)#',
		visible = #visible#
		Where uniqueid = #uniqueid#
		</cfquery>
		
		<cfquery name="updatecta" datasource="#datasource#" dbtype="ODBC">
		Update cattopicassgn
		Set categoryid = '#Trim(categoryid)#'
		Where topicid = #uniqueid#
		</cfquery>
		
		<cflocation url="libconfimation.cfm?function=2&Libselectiontype=2" addtoken="No">
	</cfif>
	
<cfelseif function is 3>
	<cfif Libselectiontype is 1>
		<cfquery name="getcatid" datasource="#datasource#" dbtype="ODBC">
		Select categoryid,name
		From cattopicassgn,categories
		Where cattopicassgn.uniqueid = #categoryid# AND cattopicassgn.categoryid = categories.uniqueid
		</cfquery>
	
		<cfquery name="deletecategories" datasource="#datasource#" dbtype="ODBC">
		Delete from categories
		Where uniqueid = #getcatid.categoryid#
		</cfquery>
		
		<cfquery name="deletecategories" datasource="#datasource#" dbtype="ODBC">
		Delete from cattopicassgn
		Where uniqueid = #categoryid#
		</cfquery>
		
		<!--- delete the directory --->
		<!--- comment: check first to see if there are any directories first--->
		<cfdirectory action="LIST" directory="c:\inetpub\wwwroot\intranet\Library\#getcatid.name#\" name="isDirThere2">
		<cfif isDirThere2.recordcount is not 0>
			<cfdirectory action="DELETE" directory="c:\inetpub\wwwroot\intranet\Library\#getcatid.name#\media">
			<cfdirectory action="DELETE" directory="c:\inetpub\wwwroot\intranet\Library\#getcatid.name#\">
		</cfif>
		
		<cflocation url="libconfimation.cfm?function=3&Libselectiontype=1" addtoken="No">
	<cfelseif Libselectiontype is 2>
		<cfquery name="deletetopics" datasource="#datasource#" dbtype="ODBC">
		Delete from topics
		Where uniqueid = #topicid#
		</cfquery>
		<cflocation url="libconfimation.cfm?function=3&Libselectiontype=2" addtoken="No">
	</cfif>
</cfif>


</body>
</html>
