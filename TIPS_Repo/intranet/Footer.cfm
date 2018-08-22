<!--- This is the footer start --->
<CFIF FindNoCase("TIPS",getTemplatePath(),1) GT 0><BR><br><br><br></CFIF><BR>
<HR align="left" width="640" size="1" color="#FF9933" noshade>
<FONT style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: xx-small;">For Support:&nbsp;
	Phone: <!--- 866-311-3853 888-271-3983&nbsp;&nbsp; Fax:&nbsp; 503-252-6597<br> --->
	ALC HelpDesk 888-342-4252 
	<!--- <a href="mailto:mlaw@alcco.com">webmaster@alcco.com</a><br> --->
	<br>E-mail: <a href="mailto:support@alcco.com">support@alcco.com © 2006 ALC
</FONT>
<!--- </DIV> --->
<SCRIPT>
	function resizeframe(){	
		if(parent.frames.length !== 0 && parent.frames[0].name !== 'floaterwindow'){ 
			try { adjustIFrameSize(window);} 
			catch (exception) {
				self.resizeTo(document.body.clientWidth,document.body.clientHeight+150);
			}
			parent.scrollTo(0,0);
		}
		self.scrollTo(0,0); location.href = '#@start';
	}
	setTimeout("resizeframe()",500);
</SCRIPT>
</BODY>
</HTML>
<HEAD>
	<META HTTP-EQUIV="Expires" CONTENT="Mon, December 31, 2001">
	<META HTTP-EQUIV="PRAGMA" CONTENT="no-cache">
	<META HTTP-EQUIV="Cache-Control" CONTENT="no-cache">
</HEAD>
<!--- end --->