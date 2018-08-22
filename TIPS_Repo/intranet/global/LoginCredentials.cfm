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

<cfset xml = "<?xml version=""1.0"" encoding=""UTF-8"" standalone=""yes"" ?><data><employeeId>#session.eid#</employeeId></data>">
