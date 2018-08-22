<cfsetting enablecfoutputonly="YES">
<cfoutput>
<cfset bError = false>
<!--- Default names for left and right select object --->
<cfparam name="attributes.left_name" default="left_select">
<cfparam name="attributes.right_name" default="right_select">
<!--- Default text list for each select object --->
<cfparam name="attributes.textleft" default="">
<cfset tl_left = #listlen("#attributes.textleft#", ",")#>
<cfparam name="attributes.textright" default="">
<cfset tl_right = #listlen("#attributes.textright#", ",")#>
<!--- Default value list for each select object --->
<cfparam name="attributes.valuesleft" default="">
<cfset vl_left = #listlen("#attributes.valuesleft#", ",")#>
<cfparam name="attributes.valuesright" default="">
<cfset vl_right = #listlen("#attributes.valuesright#", ",")#>
<!--- Size parameter --->
<cfparam name="attributes.sizeleft" default="10">
<cfparam name="attributes.sizeright" default="#attributes.sizeleft#">
<!--- Heading parameters --->
<cfparam name="attributes.headleft" default="">
<cfparam name="attributes.headright" default="">
<cfparam name="attributes.headfont" default="ms sans serif,arial">
<cfparam name="attributes.headsize" default="1">
<cfparam name="attributes.headbold" default="yes">
<!--- CrossButton parameters --->
<cfparam name="attributes.cross_buttonwidth" default="25">
<cfparam name="attributes.button_moveright" default=">">
<cfparam name="attributes.button_moveleft" default="<">
<cfparam name="attributes.button_moveright_all" default=">>">
<cfparam name="attributes.button_moveleft_all" default="<<">
<!--- Quote returns? --->
<cfparam name="attributes.quotedlist" default="no">
<!--- Returns text items? --->
<cfparam name="attributes.returntext" default="yes">
<!--- FormName is required --->
<cfif not isdefined("attributes.formname")>
	<p><font face="ms sans serif" size="1">
	<b>Error! FORMNAME is a required attribute.</b>
	</font></p>
	<cfset berror = true>
</cfif>

<!--- Make sure each select's values list has the same number of 
	  elements as it's text list --->
<cfif #tl_left# neq #vl_left#>
	<p><font face="ms sans serif" size="1">
	<b>Error! #attributes.left_name#'s text list contains #tl_left# item(s),
	but it's value list contains #vl_left# item(s).</b>
	</font></p>
	<cfset berror = true>
</cfif>
<cfif #tl_right# neq #vl_right#>
	<p><font face="ms sans serif" size="1">
	<b>Error! #attributes.right_name#'s text list contains #tl_right# item(s),
	but it's value list contains #vl_right# item(s).</b>
	</font></p>
	<cfset berror = true>
</cfif>
<cfif berror><cfabort></cfif>

<!--- Start building the selects --->
<!-- CF_DualSelect -->
<table cellpadding=5 cellspacing=0 border=0>
<cfif (#attributes.headleft# is not "") and (#attributes.headright# is not "")>
<tr>
	<td align=center>
		<cfset lh = "#iif(attributes.headleft is not "", de("#attributes.headleft#"), de("&nbsp;"))#">
		<font face="#attributes.headfont#" size="#attributes.headsize#">
			<cfif #attributes.headbold# is "yes"><b></cfif>
			#lh#
			<cfif #attributes.headbold# is "yes"></b></cfif>
		</font>
	</td>
	<td>&nbsp;</td>
	<td align=center>
		<cfset rh = "#iif(attributes.headright is not "", de("#attributes.headright#"), de("&nbsp;"))#">
		<font face="#attributes.headfont#" size="#attributes.headsize#">
			<cfif #attributes.headbold# is "yes"><b></cfif>
			#rh#
			<cfif #attributes.headbold# is "yes"></b></cfif>
		</font>
	</td>
</tr>
</cfif>
<cfif isdefined("attributes.width")>
	<cfset sw = "style='width:#attributes.width#px;' width='#attributes.width#'">
<cfelse>
	<cfset sw = "">
</cfif>
<tr>
	<td align=center valign=top>
	<!-- Left Select -->
	<select name="sel_left" size="#attributes.sizeleft#" #sw# multiple>
		<cfset x = "1">
		<cfloop list="#attributes.textleft#" index="l">
			<option value="#listgetat("#attributes.valuesleft#", "#x#")#">#l#</option>
			<cfset x = #incrementvalue(x)#>
		</cfloop>
	</select>
	</td>
	<td align=center valign=middle>
	<!-- Center controls -->
	<cfset w = "width='#attributes.cross_buttonwidth#' style='width:#attributes.cross_buttonwidth#px;'">
	<cfif #attributes.button_moveright# is not "">
	<input type="button" value="#attributes.button_moveright#" 
	onClick="MoveSelected(this.form,'sel_left','sel_right');" #w#><br>
	</cfif>
	<cfif #attributes.button_moveright_all# is not "">
	<input type="button" value="#attributes.button_moveright_all#" 
	onClick="MoveAll(this.form,'sel_left','sel_right');" #w#><br>
	</cfif>
	<cfif #attributes.button_moveleft# is not "">
	<input type="button" value="#attributes.button_moveleft#" 
	onClick="MoveSelected(this.form,'sel_right','sel_left');" #w#><br>
	</cfif>
	<cfif #attributes.button_moveleft_all# is not "">
	<input type="button" value="#attributes.button_moveleft_all#" 
	onClick="MoveAll(this.form,'sel_right', 'sel_left');" #w#>
	</cfif>
	</td>
	<td align=center valign=top>
	<!-- Right Select -->
	<select name="sel_right" size="#attributes.sizeright#" #sw# multiple>
		<cfset x = "1">
		<cfloop list="#attributes.textright#" index="l">
			<option value="#listgetat("#attributes.valuesright#", "#x#")#">#l#</option>
			<cfset x = #incrementvalue(x)#>
		</cfloop>
	</select>
	</td>
</tr>
<input type="hidden" name="#attributes.left_name#" value="">
<input type="hidden" name="#attributes.right_name#" value="">
<cfif #attributes.returntext# is "yes">
<input type="hidden" name="#attributes.left_name#_text" value="">
<input type="hidden" name="#attributes.right_name#_text" value="">
</cfif>
</table>
<script language="JavaScript">
SetValues(document.forms.myForm);
function MoveSelected(frmObj,src,tgt){
	var source = frmObj.elements[src].options.length;
	var target = frmObj.elements[tgt].options.length;
	for(i=0;i<source;i++){
		if(frmObj.elements[src].options[i].selected){
			t = frmObj.elements[src].options[i].text;
			v = frmObj.elements[src].options[i].value;
			newOpt = new Option(t, v, false, false);
			frmObj.elements[tgt].options[target]=newOpt;
			frmObj.elements[src].options[i] = null;
			source = source -1;
			target = target + 1;
			i = i -1;
			SetValues(frmObj)
			<cfif isdefined("attributes.onchange")>
			#attributes.onchange#
			</cfif>
		}
	}
}
function MoveAll(frmObj,src,tgt){
	var source = frmObj.elements[src].options.length;
	var target = frmObj.elements[tgt].options.length;
	for(l=0;l<source;l++){
		vl = frmObj.elements[src].options[0].value;
		tl = frmObj.elements[src].options[0].text;
		newOpt = new Option(tl, vl, false, false);
		frmObj.elements[tgt].options[target + l]=newOpt;
		frmObj.elements[src].options[0] = null;
	}
	SetValues(frmObj)
	<cfif isdefined("attributes.onchange")>
	#attributes.onchange#
	</cfif>
}
function SetValues(frmObj){
	var quotes = <cfif #attributes.quotedlist# is "yes">"true"<cfelse>"false"</cfif>
	var right = frmObj.sel_right.options.length;
	var left = frmObj.sel_left.options.length;
	vr = "";
	tr = "";
	for(r=0;r<right;r++){
		if(quotes){
			vr += "";
		}
		vr += frmObj.sel_right.options[r].value;
		if(quotes){
			vr += "";
		}
		tr += frmObj.sel_right.options[r].text;
		if(r < right -1){
			vr += ",";
			tr += ",";
		}
	}
	vl = "";
	tl = "";
	for(l=0;l<left;l++){
		if(quotes){
			vl += "";
		}
		vl += frmObj.sel_left.options[l].value;
		if(quotes){
			vl += "";
		}
		tl += frmObj.sel_left.options[l].text;
		if(l < left -1){
			vl += ",";
			tl += ",";
		}
	}
	frmObj.#attributes.right_name#.value = vr;
	frmObj.#attributes.left_name#.value = vl;
	<cfif #attributes.returntext# is "yes">
	frmObj.#attributes.right_name#_text.value = tr;
	frmObj.#attributes.left_name#_text.value = tl;
	</cfif>
}
</script>
<!-- End CF_DualSelect -->
</cfoutput>	
<cfsetting enablecfoutputonly="NO">
	

