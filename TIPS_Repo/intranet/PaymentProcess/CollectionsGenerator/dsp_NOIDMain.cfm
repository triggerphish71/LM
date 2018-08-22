<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<title>Collection Letters/NOID List Maintenance</title>
<style type="text/css">
<!--
.style1 {
	color: #FF0000;
	font-size: 10px;
	font-family: Arial, Helvetica, sans-serif;
}
-->
</style>

<style type="text/css">
<!--
.style2 {
	font-family: Arial, Helvetica, sans-serif;
	font-weight: bold;
}
-->
</style>

<style type="text/css">

#hintbox{ /*CSS for pop up hint box */
position:absolute;
top: 0;
background-color: lightyellow;
width: 150px; /*Default width of hint.*/ 
padding: 3px;
border:1px solid black;
font:normal 11px Verdana;
line-height:18px;
z-index:100;
border-right: 3px solid black;
border-bottom: 3px solid black;
visibility: hidden;
}

.hintanchor{ /*CSS for link that shows hint onmouseover*/
font-weight: bold;
color: navy;
margin: 3px 8px;
}

body,td,th {
	font-family: Arial, Helvetica, sans-serif;
	font-size: 12px;
}
</style>

<script type="text/javascript">

/***********************************************
* Show Hint script- c Dynamic Drive (www.dynamicdrive.com)
* This notice MUST stay intact for legal use
* Visit http://www.dynamicdrive.com/ for this script and 100s more.
***********************************************/
		
var horizontal_offset="9px" //horizontal offset of hint box from anchor link

/////No further editting needed

var vertical_offset="0" //horizontal offset of hint box from anchor link. No need to change.
var ie=document.all
var ns6=document.getElementById&&!document.all

function getposOffset(what, offsettype){
var totaloffset=(offsettype=="left")? what.offsetLeft : what.offsetTop;
var parentEl=what.offsetParent;
while (parentEl!=null){
totaloffset=(offsettype=="left")? totaloffset+parentEl.offsetLeft : totaloffset+parentEl.offsetTop;
parentEl=parentEl.offsetParent;
}
return totaloffset;
}

function iecompattest(){
return (document.compatMode && document.compatMode!="BackCompat")? document.documentElement : document.body
}

function clearbrowseredge(obj, whichedge){
var edgeoffset=(whichedge=="rightedge")? parseInt(horizontal_offset)*-1 : parseInt(vertical_offset)*-1
if (whichedge=="rightedge"){
var windowedge=ie && !window.opera? iecompattest().scrollLeft+iecompattest().clientWidth-30 : window.pageXOffset+window.innerWidth-40
dropmenuobj.contentmeasure=dropmenuobj.offsetWidth
if (windowedge-dropmenuobj.x < dropmenuobj.contentmeasure)
edgeoffset=dropmenuobj.contentmeasure+obj.offsetWidth+parseInt(horizontal_offset)
}
else{
var windowedge=ie && !window.opera? iecompattest().scrollTop+iecompattest().clientHeight-15 : window.pageYOffset+window.innerHeight-18
dropmenuobj.contentmeasure=dropmenuobj.offsetHeight
if (windowedge-dropmenuobj.y < dropmenuobj.contentmeasure)
edgeoffset=dropmenuobj.contentmeasure-obj.offsetHeight
}
return edgeoffset
}

function showhint(menucontents, obj, e, tipwidth){
if ((ie||ns6) && document.getElementById("hintbox")){
dropmenuobj=document.getElementById("hintbox")
dropmenuobj.innerHTML=menucontents
dropmenuobj.style.left=dropmenuobj.style.top=-500
if (tipwidth!=""){
dropmenuobj.widthobj=dropmenuobj.style
dropmenuobj.widthobj.width=tipwidth
}
dropmenuobj.x=getposOffset(obj, "left")
dropmenuobj.y=getposOffset(obj, "top")
dropmenuobj.style.left=dropmenuobj.x-clearbrowseredge(obj, "rightedge")+obj.offsetWidth+"px"
dropmenuobj.style.top=dropmenuobj.y-clearbrowseredge(obj, "bottomedge")+"px"
dropmenuobj.style.visibility="visible"
obj.onmouseout=hidetip
}
}

function hidetip(e){
dropmenuobj.style.visibility="hidden"
dropmenuobj.style.left="-500px"
}

function createhintbox(){
var divblock=document.createElement("div")
divblock.setAttribute("id", "hintbox")
document.body.appendChild(divblock)
}

if (window.addEventListener)
window.addEventListener("load", createhintbox, false)
else if (window.attachEvent)
window.attachEvent("onload", createhintbox)
else if (document.getElementById)
window.onload=createhintbox

</script>
</head>

<body>
	<!--- Get Houses Information for the Drop Down --->
	<cfquery name="GetHouses" datasource="#application.datasource#">
		select 
			cname
		from 
			House 
		where 
			dtrowdeleted is  null
		and 
			bIsSandbox = 0
		order by 
			cname 
	</cfquery>

	<form  name="NOIDform" action="act_GetNOID.cfm" method="post" onSubmit="return validateFields();">
	<table width="34%" height="22%" border="1" cellpadding="1" cellspacing="1" bordercolor="gray" bordercolorlight="#C0C0C0" bordercolordark="#C0C0C0" style="border-collapse: collapse">
		<tr>
			<th height="40" colspan="2">Collection Letters/NOID List Maintenance <b><font face="Arial">
				</font></b></th>
		</tr>
		<tr>
			<td width="45%" height="32" nowrap><font face="Arial" size="2" color="#0000FF">
				<b>Scope</b></font>
			</td>
			<td width="55%" height="32">
				<select name ="Scope">
					<option value="0" selected>All Houses</option>
					<option value="1">West Division</option>
					<option value="11">Pacific</option>
					<option value="14">Greenway</option>
					<option value="17">Northwest</option>
					<option value="2">Central Division</option>
					<option value="22">Central Texas</option>
					<option value="23">West Texas</option>
					<option value="24">Texas/Louisana</option>
					<option value="26">Northern Indiana</option>
					<option value="4">MWA Division</option>
					<option value="41">Ohio</option>
					<option value="43">Western Pennsylvania/Ohio</option>
					<option value="44">South Carolina/New Jersey</option>
					<option value="45">Midwest</option>	
					<option value="6">Heartland</option>	
					<option value="65">Tri-State</option>	
					<option value="68">Gateway</option>
					<option value="67">Southern Indiana/Kentucky</option>
					<cfloop query="GetHouses">
						<cfoutput>
							<option value="#GetHouses.cName#">#GetHouses.cName#</option>
						</cfoutput>
					</cfloop>
				</select><a href="#" class="hintanchor" onMouseover="showhint('Please select Scope (e.g. Tri-State).', this, event, '150px')">[?]</a>
			</td>
		</tr>
		<tr>
			<td width="45%" height="33" nowrap><font face="Arial" size="2" color="#0000FF">
				<b>Accounting Period</b></font>
			</td>
		  <td width="55%" height="33">
				<input name="Period" type="text" size="6" maxlength="6"><a href="#" class="hintanchor" onMouseover="showhint('Please enter Accounting Period (e.g. 200709).', this, event, '150px')">[?]</a>
		  </td>
		</tr>
		<tr>
			<td width="45%" height="32" nowrap><font face="Arial" size="2" color="#0000FF">
				<b>List Type </b></font></td>
			<td width="55%" height="32" bgcolor="#FFFFFF">
				<select name ="LetterType">
				  <!---<option value="3">Letter 3</option>--->
				  <option value="3">NOID List</option>
				  <option value="2">Letter 2</option>
				  <option value="1">Letter 1 </option>
				</select><a href="#" class="hintanchor" onMouseover="showhint('Please select Letter 1 or 2 or NOID List.', this, event, '150px')">[?]</a> 
			</td>
		</tr>
		<tr>
		<td width="65%" height="32" nowrap><font face="Arial" size="2" color="#0000FF">
    		<b>Exclude Deferred Payment Residents?&nbsp;&nbsp;</b></font>
		</td>
		<td>
			<input type= "CheckBox" name= "cboDeferredPayment" Value = "1">
		</td>
	</tr>
		<tr>
			<td height="36" colspan="2"><font size="1" color="#FF0000">
				<div align="center">
					<input name="run" type="submit" value="Submit">        
					<input type="reset" name="Reset" value="Reset">
			  </div>
			</td>
		</tr>
	</table>
	</form>
	<p class="style2">  
		<a href="dsp_Menu.cfm">Back</a>
	</p>	  
</body>
</html>
