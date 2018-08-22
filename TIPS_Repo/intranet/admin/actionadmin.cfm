<!--------------------------------------->
<!--- Programmer: Andy Leontovich     --->
<!--- File: admin/actionadmin.cfm     --->
<!--- Company: Maxim Group/ALC        --->
<!--- Date: May                       --->
<!--------------------------------------->

<cfparam name="heading" default="">
<cfparam name="subheading" default="">
<cfparam name="content" default="">
<cfparam name="fileid" default="">
<cfparam name="postdate" default="#Dateformat(Now())#">
<cfparam name="expirationdate" default="">
<cfparam name="editor" default="Andy">
<cfparam name="region" default="">
<cfparam name="department" default="">

<cfset Datasource = "DMS">

<cfif region is not "">
	<cfset section2 = region>
	<cfset sectiontype2 = 1>
	
<cfelseif department is not "">
	<cfset section2 = department>
	<cfset sectiontype2 = 2>
<cfelse>
	<cfset section2 = 0>
	<cfset sectiontype2 = 3>
</cfif>


<!--- Department: <cfoutput>#section2#</cfoutput> --->
<cfif previewcode is 1>

	<cfquery name="insertentry" datasource="#Datasource#" dbtype="ODBC">
		Insert Into	releases
					(
						cHeading,
						nwhatsnew,
						cSubheading,
						content,
						mediainfouniqueid,
						dPostdate,
						dExpirationdate,
						nfilendx,
						postedby,
						created_date,
						bannerexpiresdate
					)
		Values		(
						'#heading#',
						#whatsnew#,
						'#subheading#',
						'#content#',
						'#fileid#',
						'#DateFormat(postdate,"mm/dd/yy")#',
						'#DateFormat(expirationdate,"mm/dd/yy")#',
						#fileassign2#,
						#session.userid#,
						'#DateFormat(Now(),"mm/dd/yy")#',
						'#dateformat(whatsnewexpirationdate,"mm/dd/yy")#'
					)
	</cfquery>
	
	<cfquery name="getreleaseindex" datasource="#datasource#" dbtype="ODBC">
		Select ndx
		From releases
		Where dpostdate = '#postdate#' AND cheading = '#heading#' AND csubheading = '#subheading#'
	</cfquery>
	
	
	<!---Comment: medialocation.locationtypeid is used to track the global location of the content. medialocation.locationtypeid,locationid need to be deprecated in the next release of the content management system.--->
	<cfquery name="insertentry" datasource="#datasource#" dbtype="ODBC">
		Insert into	medialocation
					(	
						mediaid,
						locationid,
						locationtypeid,
						releasecontent
						
						<cfif publishto2 is not "">
							,publishto
						</cfif>
					)
		Values		
					(
						#getreleaseindex.ndx#,
						#section2#,
						'#sectiontype2#',
						1
						<cfif publishto2 is not "">
							,#publishto2#
						</cfif>
						)
	</cfquery>
	
	<!--- needs section and nsectiontype to be put into medialocation --->
	<cflocation url="confirm.cfm?previewcode=1" addtoken="No">

<cfelseif previewcode is 2>
	<cfif unlinkillus is 1><!--- to disassociate media with the release posting --->
		<cfset fileid = 0>
	</cfif>
	
	<cfif unlinklib is 1><!--- to disassociate media with the release posting --->
		<cfset fileassign2 = 0>
	</cfif>

	<cfquery name="updateentry" datasource="#Datasource#" dbtype="ODBC">
		update releases
		Set nwhatsnew = '#whatsnew#',
	      	cheading = '#heading#',
	      	csubheading = '#subheading#',
	      	content = '#content#',
	      	dpostdate = '#postdate#',
		  	nfilendx = #fileassign2#,
		  	bannerexpiresdate = '#Dateformat(whatsnewexpirationdate,"mm/dd/yy")#',
	      	dexpirationdate = '#expirationdate#'
			
			<cfif fileid is not "">
		   		,mediainfouniqueid = #fileid#
			</cfif>
		Where ndx = #ndx#
	</cfquery>
	
	<cfquery name="inserteditor" datasource="#Datasource#" dbtype="ODBC">
		update releases
		Set ceditedby = '#editor#'
		Where ndx = #ndx#
	</cfquery>
	
	<cfif publishto2 is not ""><!--- for training to post elsewhere --->
		<cfquery name="updatepublishto" datasource="#datasource#" dbtype="ODBC">
			Update 	Medialocation
			Set 	publishto = #publishto2#
			Where 	mediaid = #ndx# AND locationid = 14
		</cfquery>
	</cfif>
	
	<cflocation url="confirm.cfm?previewcode=2" addtoken="No">
	
<cfelseif previewcode is 3>
	<cfquery name="deleteentry" datasource="#Datasource#" dbtype="ODBC">
		Delete from releases
		Where ndx = #ndx2#
	</cfquery>
		
	<cfquery name="deletefrommedialocation" datasource="#datasource#" dbtype="ODBC">
		Delete from medialocation
		Where mediaid = #ndx2# AND mediacontent = 1
	</cfquery>
	
	<cflocation url="confirm.cfm?previewcode=3" addtoken="No">
</cfif>
