<CFOUTPUT>
<LINK REL="StyleSheet" TYPE="text/css" HREF="http://#server_name#/intranet/tips4/shared/style3.css">
<TABLE>
	<TR><TH>Inquriy Tracking Reports</TH></TR>
	<TR><TD><A HREF="http://holly/reports/it/InqLabels.rpt">Report 1</A></TD></TR>
</TABLE>

<SCRIPT>report=window.open("loading.htm","InquiryLabelsReport","toolbar=no,resizable=yes");report.moveTo(0,0);</SCRIPT>
<CFSET User="rw">
<CFSET Password="4rwriter">
<CFSCRIPT>if (isDefined("url.scp")) { scope=url.scp; } else { scope=session.qselectedhouse.cname; } </CFSCRIPT>
<form NAME="InquiryLabelsReport" action="//#crserver#/reports/it/InqLabels.rpt" method="POST" TARGET="InquiryLabelsReport">
	<input type=hidden name="init" value="actx">  <!-- actx uses ActiveX viewer, Java uses JVM Java viewer, html_page uses straight HTML -->
	<input type=hidden name="promptOnRefresh" value=0>
	<input type=hidden name="user0" value="#User#">
	<input type=hidden name="password0" value="#Password#">
	<input type=hidden name="prompt0" value="#scope#">
	<SCRIPT>location.href='#HTTP_REFERER#';document.InquiryLabelsReport.submit();</SCRIPT>
	Loading...
</form>
</CFOUTPUT>
	

