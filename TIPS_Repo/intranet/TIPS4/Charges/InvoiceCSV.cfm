


<CFINCLUDE TEMPLATE="../../header.cfm">

<CFPARAM NAME="Period" TYPE="date" DEFAULT="#SESSION.TIPSMonth#">

<CFOUTPUT>
	<A HREF="#HTTP_REFERER#" STYLE="font-size: 18;">Click Here to Continue.</A>
	<BR>
	<CF_Invoice iHouse_ID=#SESSION.qSelectedHouse.iHouse_ID# TipsMonth=#DateFormat(Period,"yyyy-mm-dd")# DEBUG=1>
	<BR><BR>
	<A HREF="#HTTP_REFERER#" STYLE="font-size: 18;">Click Here to Continue.</A>
</CFOUTPUT>



<CFINCLUDE TEMPLATE="../../footer.cfm">



