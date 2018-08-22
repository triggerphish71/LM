		
var horizontal_offset="9px" //horizontal offset of hint box from anchor link

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


//move back in index.cfm !!!!!!!!!!!!!!!!!!!! see if even needed!
//if (window.addEventListener)
//window.addEventListener("load", createhintbox, false)
//else if (window.attachEvent)
//window.attachEvent("onload", createhintbox)
//else if (document.getElementById)
//window.onload=createhintbox

function validateFields() {

	for (i=0; i<document.invoicesform.Scope.length; i++) { 
		document.invoicesform.Scope.options[i].selected = true; 
	} 
	
	if (document.invoicesform.Scope.value == "") {
		alert("Please select house(s)");
		return false;
	}

    if (document.invoicesform.Period.value == "") {
        alert('Please enter Accounting Period');
        return false;
    }
    if (document.invoicesform.EFTdate.value == "1900-01-01 00:00:00.0" || document.invoicesform.EFTdate.value == " " ) {
        alert('Please enter EFT Date for the selected Accounting Period');
        return false;
    }

	return true;
}

function validateDistributionList() {
    if (document.FTPform.ToMail.value == " " || document.FTPform.CCMail.value == " ") {
        alert('Please enter Distribution List');
        return false;
    }
	return true;
}

function SelectMoveRows(SS1,SS2)
{
    var SelID='';
    var SelText='';
    // Move rows from SS1 to SS2 from bottom to top
    for (i=SS1.options.length - 1; i>=0; i--)
    {
        if (SS1.options[i].selected == true)
        {
            SelID=SS1.options[i].value;
            SelText=SS1.options[i].text;
            var newRow = new Option(SelText,SelID);
            SS2.options[SS2.length]=newRow;
            SS1.options[i]=null;
        }
    }
}

function confirmSubmit(){
	var agree=confirm("Are you sure you wish to continue?");
	if (agree)
		return true ;
	else
		return false ;
}




//function SelectSort(SelList)
//{
//    var ID='';
//    var Text='';
//    for (x=0; x < SelList.length - 1; x++)
//    {
//        for (y=x + 1; y < SelList.length; y++)
//        {
//            if (SelList[x].text > SelList[y].text)
//            {
//                // Swap rows
//                ID=SelList[x].value;
//                Text=SelList[x].text;
//                SelList[x].value=SelList[y].value;
//                SelList[x].text=SelList[y].text;
//                SelList[y].value=ID;
//                SelList[y].text=Text;
//            }
//        }
//    }
//}
