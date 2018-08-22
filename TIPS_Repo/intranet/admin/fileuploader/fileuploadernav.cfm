<!--------------------------------------->
<!--- Programmer: Andy Leontovich     --->
<!--- File: admin/container.cfm          --->
<!--- Company: Maxim Group/ALC        --->
<!--- Date: May                       --->
<!--------------------------------------->
<cfparam name="url.index" default="0">
<cfif url.index is 1>
	<cflocation url="editfilemenu.cfm" addtoken="No">
<cfelseif url.index is 2>
	<cflocation url="uploadfile.cfm" addtoken="No">
	<cfelseif url.index is 3>
	<cflocation url="deletefilemenu.cfm" addtoken="No">
</cfif>

<font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: xx-small; font-weight: bold;">
<A HREF="uploadfile.cfm">Upload File</a>
&nbsp;&nbsp;
<A HREF="editfilemenu.cfm">Edit File</a>
&nbsp;&nbsp;
<A HREF="deletefilemenu.cfm">Delete File</a></font>
<hr align="left" width="680" size="1" noshade>



