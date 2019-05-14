-- ========================================
-- PROPERTIES
-- ========================================
set AppleScript's text item delimiters to ","

property defaultKeyDelay : 0.2
property defaultDelayValue : 0.75

property rowHeaders : "Search Terms, Etsy, Google \",\" ETC, Total Visits"

property newLine : "\n"

property jsFindNavButton : "document.querySelectorAll('.pagination')[0].querySelectorAll('.btn-group-item:last-child')[0].click()"

property jsNextButtonDisabled : "document.querySelectorAll('.pagination')[0].querySelectorAll('.btn-group-item:last-child')[0].disabled"

property jsFindNavButtonHome : "document.querySelectorAll('.pagination')[0].querySelectorAll('.btn-group-item')[1].click()"

property mainURL : "https://www.etsy.com/your/shops/me/stats/traffic?ref=seller-platform-mcnav"

-- Log Dividers
on logIt(content)
	log "------------------------------------------------"
	log content
	log "------------------------------------------------"
end logIt


-- ========================================
-- USER PROMPTS
-- ========================================

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

-- Progress Dialog Handler
on progressDialog(theMessage)
	set progress description to theMessage
end progressDialog

-- User Range Choice Dialog
on chooseRange()
	# URL append options
	set last30 to "&date_range=last_30"
	set thisYear to "&date_range=this_year"
	set allTime to "&date_range=all_time"
	
	# Button Displays
	set a to "Last 30 Days (Recommended)"
	set b to "This Year"
	set c to "All Time"
	
	# Dialog Window
	set userDialog to display dialog "Which range do you want to display?" buttons {a, b, c} default button 1
	
	# Return the user's choice
	set userChoice to button returned of userDialog as string
	
	if userChoice is a then
		set theData to last30
	else if userChoice is b then
		set theData to thisYear
	else if userChoice is c then
		set theData to allTime
	end if
	
	return theData
end chooseRange

-- Set url append
on setUserRange()
	set theURL to chooseRange()
	return theURL as string
end setUserRange



-- ========================================
-- READ AND WRITE
-- ========================================

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

-- ========================================
-- BROWSER / URL BEHAVIOR
-- ========================================
on openURL(a)
	tell application "Safari"
		tell window 1
			set current tab to (make new tab with properties {URL:mainURL & a})
		end tell
	end tell
end openURL


-- ========================================
-- DOM INTERACTIONS
-- ========================================

-- Find keyword term
on keywordTerm(a)
	try
		tell application "Safari"
			set theKeyword to do JavaScript "document.querySelector('#horizontal-chart3 tr:nth-child(" & a & ") span').innerText" in document 1
			return theKeyword as text
		end tell
	on error
		return false
	end try
end keywordTerm

-- Find column data
on col(a, b)
	try
		tell application "Safari"
			set theData to do JavaScript "document.querySelector('#horizontal-chart3 > tr:nth-child(" & a & ") > td > div > div > div > div:nth-child(" & b & ")').innerText" in document 1
			return theData as text
		end tell
	on error
		return false
	end try
end col

-- ========================================
-- USER PROMPTS
-- ========================================

-- Pagination Button
on findNode(theJS)
	tell application "Safari"
		do JavaScript "" & theJS & "" in document 1
	end tell
end findNode


-- ========================================
-- WRITE HEADERS
-- ========================================

-- Write Headers
on writeHeaders()
	writeFile(rowHeaders & newLine, false) as text
end writeHeaders

-- Write the Data
on getData()
	set theCount to 2
	set keyword to ""
	
	repeat
		set updatedCount to (theCount + 1)
		log "updatedCount = " & updatedCount & ""
		
		delay defaultDelayValue
		
		set keyword to keywordTerm(theCount)
		
		if keyword is false then
			log "keyword is false. exiting the loop."
			exit repeat
		end if
		
		set col2 to col(updatedCount - 1, 1) as text
		set col3 to col(updatedCount - 1, 2) as text
		set col4 to col(updatedCount - 1, 3) as text
		
		set theCount to theCount + 1
		log "Updating theCount to " & theCount & " "
		
		writeFile(keyword & "," & col2 & "," & col3 & "," & col4 & newLine, false) as text
	end repeat
end getData

-- ========================================
-- BUTTON INTERACTIONS
-- ========================================

-- Check for disabled button
on disabledCheck()
	if findNode(jsNextButtonDisabled) is true then
		return false
	else
		return true
	end if
end disabledCheck

-- Button Interaction Handler
on clickButton(selector)
	tell application "Safari"
		log "Clicking the 'Next' Pagination button..."
		set a to do JavaScript "document.querySelectorAll('.pagination')[0].querySelectorAll('.btn-group-item:" & selector & "')[0].click()" in document 1
		
		log "Waiting for the new keywords to load..."
		delay defaultDelayValue
	end tell
end clickButton

-- Next Button
on nextButton()
	clickButton("last-child")
end nextButton

-- First Button
on firstButton()
	clickButton("first-child")
end firstButton


-- ========================================
-- ROUTINES
-- ========================================

on mainRoutine()
	set urlAppend to setUserRange()
	openURL(urlAppend)
	delay 10
	writeHeaders()
	firstButton()
	
	repeat
		getData()
		if disabledCheck() is false then
			exit repeat
		end if
		nextButton()
	end repeat
	
	userPrompt("Finished!")
end mainRoutine

mainRoutine()

