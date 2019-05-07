-- ========================================
-- Properties
-- ========================================
set AppleScript's text item delimiters to ","

property defaultKeyDelay : 0.2
property defaultDelayValue : 0.75

property rowHeaders : "Search Terms, Etsy, Google \",\" ETC, Total Visits"

property newLine : "
"

property jsFindNavButton : "document.querySelectorAll('.pagination')[0].querySelectorAll('.btn-group-item:last-child')[0].click()"

property jsNextButtonDisabled : "document.querySelectorAll('.pagination')[0].querySelectorAll('.btn-group-item:last-child')[0].disabled"

property jsFindNavButtonHome : "document.querySelectorAll('.pagination')[0].querySelectorAll('.btn-group-item')[1].click()"

# For the pagination button
property rowSelector : "#horizontal-chart3 > div > div"

# For the keywords
property selectorPath : "#horizontal-chart3 > div"

-- Log Dividers
on logIt(content)
	log "------------------------------------------------"
	log content
	log "------------------------------------------------"
end logIt


on userPrompt(theText)
	logIt("userPrompt()")
	activate
	display dialog theText
end userPrompt

on userPrompt2Buttons(theText, buttonText1, buttonText2)
	logIt("userPrompt()")
	activate
	display dialog theText buttons {buttonText1, buttonText2}
end userPrompt2Buttons


-- Reading and Writing Params
on writeTextToFile(theText, theFile, overwriteExistingContent)
	logIt("writeTextToFile()")
	try
		
		set theFile to theFile as string
		set theOpenedFile to open for access file theFile with write permission
		
		if overwriteExistingContent is true then set eof of theOpenedFile to 0
		write theText to theOpenedFile starting at eof
		close access theOpenedFile
		
		return true
	on error
		try
			close access file theFile
		end try
		
		return false
	end try
end writeTextToFile


-- Write to file
on writeFile(theContent, writable)
	logIt("writeFile()")
	set this_Story to theContent
	set theFile to (((path to desktop folder) as string) & "Etsy Searched Terms.csv")
	writeTextToFile(this_Story, theFile, writable)
end writeFile



-- Get the Keyword from the DOM
on selectKeyword(theSelector, theInstance, theSecondInstance)
	tell application "Safari"
		try
			set keyword to do JavaScript "document.querySelectorAll('" & theSelector & "')[" & theInstance & "].getElementsByTagName('span')[" & theSecondInstance & "].innerText; " in document 1
			return keyword
		on error
			return false
		end try
	end tell
end selectKeyword


-- Progress Dialog Handler
on progressDialog(theMessage)
	set progress description to theMessage
end progressDialog


-- Pagination Button
on findNode(theJS)
	tell application "Safari"
		do JavaScript "" & theJS & "" in document 1
	end tell
end findNode


-- Main Routine
log "Clicking the '1' Button to ensure we're on the first page of results."
findNode(jsFindNavButtonHome)

on findColumnStat(firstInstance, secondInstance)
	tell application "Safari"
		
		set theSelector to "#horizontal-chart3 > div:nth-child(" & firstInstance & ") > div.col-group.pl-xs-2.pl-md-1.pr-xs-2.pr-md-1.pl-lg-0.pr-lg-0.pt-xs-2 > div.col-xs-8.text-gray-lighter.text-right.pr-md-0 > div:nth-child(" & secondInstance & ")"
		
		set doJS to "document.querySelectorAll('" & theSelector & "')[0].innerText"
		
		set theResult to do JavaScript "" & doJS & "" in document 1
		
		return theResult as text
	end tell
end findColumnStat


on getData()
	writeFile(rowHeaders & newLine, false) as text
	repeat
		set theCount to 0
		set keyword to ""
		
		repeat
			set updatedCount to (theCount + 1)
			log "updatedCount = " & updatedCount & ""
			
			delay defaultDelayValue
			
			set keyword to selectKeyword(selectorPath, updatedCount, 0)
			log "the keyword: " & keyword & ""
			
			if keyword is false then
				log "keyword is false. exiting the loop."
				exit repeat
			end if
			
			set col2 to findColumnStat(updatedCount + 1, 1) as text
			
			set col3 to findColumnStat(updatedCount + 1, 2) as text
			
			set col4 to findColumnStat(updatedCount + 1, 3) as text
			
			set theCount to theCount + 1
			log "Updating theCount to " & theCount & " "
			
			writeFile(keyword & "," & col2 & "," & col3 & "," & col4 & newLine, false) as text
		end repeat
		
		log "Check to see if the button is disabled."
		
		if findNode(jsNextButtonDisabled) is true then
			log "Next button is disabled. Exiting repeat loop."
			exit repeat
		end if
		
		log "Clicking the 'Next' Pagination button..."
		findNode(jsFindNavButton)
		
		log "Waiting for the new keywords to load..."
		delay defaultDelayValue
	end repeat
	userPrompt("Finished!")
end getData

getData()
