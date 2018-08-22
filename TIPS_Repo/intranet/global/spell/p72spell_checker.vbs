//
//-:: pixelseventy2 Spell Checker ::-
//
//requires IE and Word on the client machine.

//
//takes a text string and runs a spell checker on it, returns corrected text
//
//required components: 
//	p72spell_checker.vbs
//	p72sc_results.htm	
//
//notes:
//	if p72sc_results.htm is not in the same folder as the calling script, 
//	change the variable p72path from "" to reflect this
//
//params:
//	p72chkText		- the text string to check
//	
//platforms:
//	IE6+ PC			- works
//	IE5+ PC			- assumed to work
//	
//use:
//	with a textarea <textarea name="mytext"></textarea>
//	and a button <input type="button" onClick="mytext.value=p72spellCheck(mytext.value)">


// ### Change this is the p72sc_results.htm is not in the same place as the calling page
p72path = "http://GUM/intranet/global/spell/"

dim word , wordDocument , p72suggestions , p72range , p72choice

function p72spellCheck(p72chkText)
	spellCheck = p72chkText
	on error resume next

	msgBoxError1 = 	"The spell check cannot be initialised." & chr(10) & chr(10)
	msgBoxError2 = "" // chr(10) & chr(10) & "Would you like to see Help regarding this issue?"


	// ### detect if we can run scripts
	set fso = CreateObject("scripting.filesystemobject")

	// ### intranet security setting must allow active x scripts to run (not marked safe)
	if err.number <> 0 then
		// ###  no we can't
		msgBoxErrorInner = "Your Internet security settings may be preventing the" & chr(10) & "spell checker from running."
		cont = msgbox( msgBoxError1 & msgBoxErrorInner & msgBoxError2 , vbOKOnly , "Error ..." )
//		p72spellCheck = p72chkText
		exit function
	end if
	
	// ### initialise word
	if not isObject(word) then set word = createobject("word.application")

	// ### set cleanUp function
	document.body.onunload = GetRef("p72sc_closeDown")

	// ### was Word initialised?
	if err.number<>0 then
		msgBoxErrorInner = "Word may not be correctly installed on this machine"
		cont = msgbox( msgBoxError1 & msgBoxErrorInner & msgBoxError2 , vbOKOnly , "Error ..." )
		p72sc_closeDown()
//			if cont <>6 then msgbox("Spell Check cancelled")
//			else newwin = open("help.htm" , "help" , "width=300,height=400,scrollbars,resizable")
//			end if
		exit function
	end if
	
	// ### create Document
	//if not isObject(wordDocument) then 
	set wordDocument = word.documents.add
	
	// ## put in text
	word.selection.text = p72chkText
	
	// ### process errors
	set objerrors = wordDocument.spellingErrors
	eCount = objerrors.count
	if eCount > 0 then
		for each strerror in objerrors
			pos = strerror.start

			p72suggestions = ""
			p72range = ""
			p72choice = ""
			X =1 
			
			sPos = pos - 20 : if sPos < 1 then sPos = 1
			p72range = mid(p72chkText,sPos,pos - sPos) 
			p72range = p72range & " <b style=""color:red"">" & strerror.text & "</b> " 
			p72range = p72range & mid( p72chkText , pos + 1 + len( strerror.text ) , 20 )

			with word.getspellingsuggestions(strerror.text)
				for X = 1 to .count
					if X > 1 then p72suggestions = p72suggestions + ","
					p72suggestions = p72suggestions + .item(X)
				next
				r = showModalDialog(p72path & "p72sc_results.htm",window,"dialogWidth:400px;dialogHeight:300px;center:yes;status:no;scrolling:no")
				if r = "end" then p72spellCheck = p72chkText : p72sc_killDoc() : exit function
				selection = p72choice
				if selection<>"" then
					if pos < 1 then pos = 1
					p72chkText = left(p72chkText,pos - 1) & replace(p72chkText,strerror.text,selection,pos,1)
				end if
			end with
		next
	end if
	if err.number<>0 then msgbox ("fatal error" & chr(10) & err.description & err.line)

	// ### kill document
	p72sc_killDoc()

	on error goto 0

	p72spellCheck = p72chkText
	msg = "No spelling mistakes found"
	if eCount > 0 then msg = "Spell check complete"
	call msgbox(msg,64)
	//p72sc_closeDown()
end function

sub p72sc_killDoc()
	// ### kill document
	wordDocument.close(0)
	set wordDocument = nothing
end sub

sub p72sc_closeDown
	// ### kill Word
	// if this doesn't run you're system will run really badly with lots of Word instances open :p
	on error resume next
	word.quit()
	set word = nothing
	on error goto 0
end sub
