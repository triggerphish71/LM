<cfset datasource = "DMS">

<!--- employment action --->
<!--- function 1 is add --->
<!--- function 2 is edit --->
<!--- function 3 is delete --->

<!--- empfunction 1 is category --->

<cfparam name="function" default="0">

		<cfif function is 1>
			<cfif taskid is 1>
				<cfquery name="insertcat" datasource="#datasource#" dbtype="ODBC">
				Insert into jobtoc (heading,nregionnumber,user_id,created_date)
				Values('#name#',#region#,#session.userid#,'#DateFormat(Now(),"mm/dd/yy")#')
				</cfquery>
				
				<cflocation url="jobconfirm.cfm?function=1&taskid=2" addtoken="No">
			<cfelse>
			
				<cfquery name="insertjob" datasource="#datasource#" dbtype="ODBC">
				Insert into joblistings (nregionnumber,nhouse,activedate,closedate,jobnumber,jobtitle,show,submittedby,tocid,dDateStamp,notes,location,resumedate,resumeto,hractive)
				Values(#region#,#nhouse#,'#postdate#','#expiredate#','#jobnumber#','#jobtitle#',#view#,#session.userid#,#category#,'#Dateformat(Now())#','#notes#',#location#,'#resumedate#','#resumeto#',1)
				</cfquery>
				
				<cfquery name="getjobid" datasource="DMS" dbtype="ODBC">
					SELECT form_ndx
					FROM joblistings
					WHERE nregionnumber = #region# AND nhouse = #nhouse# AND activedate = '#postdate#' AND closedate = '#expiredate#' AND jobnumber = '#jobnumber#' AND jobtitle = '#jobtitle#' AND show = #view# AND submittedby = #session.userid# AND tocid = #category# AND dDateStamp = '#Dateformat(Now())#'
				</cfquery>
				<!--- dianeschander@ALCCO.com --->
				
				
				<cflocation url="createjobposting.cfm?return=#getjobid.form_ndx#&region=#region#&viewcriteria=1&cat=#category#" addtoken="No">
			</cfif>
			
			
		<cfelseif function is "2">
			<cfif taskid is 1>
				<cfquery name="updatecat" datasource="#datasource#" dbtype="ODBC">
				Update jobtoc
				Set heading = '#name#'
				Where toc_ndx = #toc_ndx#
				</cfquery>
				
				<cflocation url="jobconfirm.cfm?function=2&taskid=2" addtoken="No">
			<cfelse>
				<cfquery name="updatepost" datasource="#datasource#" dbtype="ODBC">
				Update joblistings
				Set 
				nhouse = #nhouse#,
				activedate = '#postdate#',
				closedate = '#expiredate#',
				jobnumber = '#jobnumber#',
				jobtitle = '#jobtitle#',
				show = #view#,
				tocid = #category#,
				revdate = '#Dateformat(Now())#',
				notes = '#notes#',
				resumedate = '#resumedate#',
				resumeto = '#resumeto#',
				location = #location#,
				HRactive = 2
				Where Form_ndx = #form_ndx#
				</cfquery>
				
				
				<cfquery name="getregions2" datasource="#datasource#" dbtype="ODBC">
				Select RegionName,nregionnumber
				From VW_regions
				Where nregionnumber = #url.region#
				</cfquery>
		
			<cfquery name="closejobbuild" datasource="#datasource#" dbtype="ODBC">
				UPDATE jobcriteria
				SET buildid = 0
				WHERE buildid = #session.userid#
			</cfquery>
			
			<cfmail to="dianeschander@alcco.com" from="webmaster@alcco.com" subject="An Edited Job Posting is in the Queue">Please check HR review in the <cfif getregions2.nregionnumber is 0> ALC Home Office<cfelseif getregions2.nregionnumber is 1>Western Region<cfelseif getregions2.nregionnumber is 2>Central Region<cfelseif getregions2.nregionnumber is 3>South East Region<cfelseif getregions2.nregionnumber is 4>Eastern Region</cfif> for the edited posting.</cfmail>
				
				<cflocation url="jobconfirm.cfm?function=2&taskid=1" addtoken="No"> 
			</cfif>
			
			
		<cfelseif function is "3">
			<cfif taskid is 1>
				<cfquery name="delcat" datasource="#datasource#" dbtype="ODBC">
				Delete from jobtoc
				Where toc_ndx = #toc_ndx#
				</cfquery>
				
				<cflocation url="jobconfirm.cfm?function=3&taskid=1" addtoken="No">
				
			<cfelseif taskid is 2><!--- for user delete --->
				<cfquery name="hrdelete" datasource="#datasource#" dbtype="ODBC">
				UPDATE joblistings
				SET hractive = 3
				WHERE form_ndx = #listingindex#
				</cfquery>
				
				<cfquery name="getregions2" datasource="#datasource#" dbtype="ODBC">
				Select RegionName,nregionnumber
				From VW_regions
				Where nregionnumber = #region#
				</cfquery>
				
				<cfmail to="dianeschander@ALCCO.com" from="webmaster@alcco.com" subject="A Deleted Job Posting is in the Queue">
			Please check HR review in the <cfif getregions2.nregionnumber is 0>ALC Home Office<cfelseif getregions2.nregionnumber is 1>Western Region<cfelseif getregions2.nregionnumber is 2>Central Region<cfelseif getregions2.nregionnumber is 3>South East Region<cfelseif getregions2.nregionnumber is 4>Eastern Region </cfif>for the delete posting request.</cfmail>
			
				<cflocation url="jobconfirm.cfm?function=3&taskid=2" addtoken="No">
			</cfif>
			
		<cfelseif function is "4" >
			<cfquery name="insertcriteria" datasource="#datasource#" dbtype="ODBC">
			INSERT INTO jobcriteria(criteriatype,listingid,criteriadesc,buildid,createdate,createtime)
			VALUES(#criteria#,#listingnumber#,'#criteriadesc#',#session.userid#,'#dateformat(Now())#','#timeformat(Now(),"HH:mm:ss")#')
			</cfquery>
			
			<cfif isDefined("edit")>
				<cflocation url="editjobposting.cfm?return=#listingnumber#&region=#region#&viewcriteria=1&cat=#category#" addtoken="No">
			<cfelse>
				<cflocation url="createjobposting.cfm?return=#listingnumber#&region=#region#&viewcriteria=1&cat=#category#" addtoken="No">
			</cfif>

		
		<cfelseif function is "5">
			
		<cfquery name="getregions2" datasource="#datasource#" dbtype="ODBC">
		Select RegionName,nregionnumber
		From VW_regions
		Where nregionnumber = #url.region#
		</cfquery>
		
			<cfquery name="closejobbuild" datasource="#datasource#" dbtype="ODBC">
				UPDATE jobcriteria
				SET buildid = 0
				WHERE buildid = #session.userid#
			</cfquery>
			<cfmail to="dianeschander@ALCCO.com" from="webmaster@alcco.com" subject="A New Job Posting is in the Queue">
			Please check HR review in the <cfif getregions2.nregionnumber is 0>ALC Home Office<cfelseif getregions2.nregionnumber is 1>Western Region<cfelseif getregions2.nregionnumber is 2>Central Region<cfelseif getregions2.nregionnumber is 3>South East Region<cfelseif getregions2.nregionnumber is 4>Eastern Region </cfif>for the new posting.
			</cfmail>
			<cflocation url="jobconfirm.cfm?function=1&taskid=1" addtoken="No">
			
		<cfelseif function is "6">
			<cfquery name="deletecriteria" datasource="#datasource#" dbtype="ODBC">
				DELETE FROM jobcriteria
				Where jobcriteria_id = #url.id#
			</cfquery>
			
		<cfif isDefined("URL.edit")>
			<cflocation url="editjobposting.cfm?return=#url.return#&region=#url.region#&viewcriteria=1&cat=#url.cat#" addtoken="No">
		<cfelse>
			<cflocation url="createjobposting.cfm?return=#url.return#&region=#url.region#&viewcriteria=1&cat=#url.cat#" addtoken="No">
		</cfif>
</cfif>
		