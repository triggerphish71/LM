<!----------------------------------------------------------------------------------------------
| DESCRIPTION: 											                                       |
|----------------------------------------------------------------------------------------------|
| act_centralizereport.cfm                                                                     |
|----------------------------------------------------------------------------------------------|
| STORED PROCEDURES                                                                            |
|----------------------------------------------------------------------------------------------|
|  none                                                                                        |
|----------------------------------------------------------------------------------------------|
| INCLUDES                                                                                     |
|----------------------------------------------------------------------------------------------|
| Called by:  Admin/Menu.cfm																   |
| Calls/Submits:																			   |
|----------------------------------------------------------------------------------------------|
| HISTORY                                                                                      |
|----------------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                        |
|------------|------------|--------------------------------------------------------------------|
|MLAW        | 03/19/2007 | Project 0906: Centralized Invoice Reports                          |
----------------------------------------------------------------------------------------------->

<cfparam name="houseid" default="">
<cfparam name="checked" default="">
<cfparam name="db" default="">

<cfif checked eq 'true'>
	<cfset checked = 1>
<cfelse>
	<Cfset checked = 0>
</cfif>

<!--- no cache --->
<cfheader name="Expires" value="Sun, 01 Jan 2005 05:00:00 GMT"> 
<cfheader name="Cache-Control" value="no-cache, must-revalidate">
<cfprocessingdirective suppresswhitespace="true">
<!--- Hide the debug output --->
<cfsetting showdebugoutput="false">
<!--- make sure that the only thing outputted is the xml --->
<cfsetting enablecfoutputonly="true">
<!--- change the mime type to xml for this page --->
<cfcontent type="text/xml">
<cfset xml = "<?xml version=""1.0"" encoding=""UTF-8"" standalone=""yes"" ?><data>">

<cftry> 
	<cfquery name="updateHouseLog" Datasource="#db#">
		Update HouseLog
		SET 
			bIsCentralized = #checked#
		WHERE
			ihouse_ID = #houseid#
	</cfquery>
	
	<cfset xml=xml & "<success>Submitted</success></data>">
<cfcatch>
	<cfset xml=xml & "<fail>false</fail></data>">
</cfcatch>
</cftry>

<cfoutput>
  #xml#
</cfoutput>

</cfprocessingdirective>
<cfabort>

