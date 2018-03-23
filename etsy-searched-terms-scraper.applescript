-- ========================================
-- Properties
-- ========================================
property defaultKeyDelay : 0.2
property defaultDelayValue : 0.75

property keyRight : 124
property keyDown : 125
property keyHome : 115
property keyEnter : 36

property jsFindNavButton : "document.querySelectorAll('.pagination')[0].querySelectorAll('.btn-group-item:last-child')[0].click()"

property jsFindNavButtonHome : "document.querySelectorAll('.pagination')[0].querySelectorAll('.btn-group-item')[1].click()"


# For the pagination button
property rowSelector : "#horizontal-chart3 > div > div"

# For the keywords
property selectorPath : "#horizontal-chart3 > div"

-- ========================================
-- Get the Keyword from the DOM
-- ========================================
on selectKeyword(theSelector, theInstance, theSecondInstance)
	tell application "Safari"
		activate
		try
			set theKeyword to do JavaScript "document.querySelectorAll('" & theSelector & "')[" & theInstance & "].getElementsByTagName('span')[" & theSecondInstance & "].innerText; " in document 1
			return theKeyword
		on error
			return "end of the list"
		end try
	end tell
end selectKeyword

-- ========================================
-- Progress Dialog Handler
-- ========================================

on progressDialog(theMessage)
	set progress description to theMessage
end progressDialog

-- ========================================
-- Key Stroke Handlers
-- ========================================

on copyIt()
	tell application "System Events"
		delay defaultKeyDelay
		keystroke "c" using {command down}
		delay defaultKeyDelay
	end tell
end copyIt

on pasteIt()
	tell application "Google Chrome" to activate
	tell application "System Events"
		delay defaultKeyDelay
		keystroke "v" using {shift down, command down}
		delay defaultKeyDelay
	end tell
end pasteIt

on arrowAction(theKeystroke)
	tell application "System Events"
		delay defaultKeyDelay
		key code theKeystroke
		delay defaultKeyDelay
	end tell
end arrowAction

-- =======================================
-- Set the Clipboard
-- =======================================	

on setClipboard(theWord)
	tell application "System Events"
		delay defaultDelayValue
		set the clipboard to theWord
		delay defaultDelayValue
	end tell
end setClipboard

-- ========================================
-- Pagination Button
-- ========================================

on findNode(theJS)
	tell application "Safari"
		activate
		delay 2
		do JavaScript "" & theJS & "" in document 1
		delay 2
	end tell
end findNode

-- =======================================
-- Main Routine
-- =======================================

log "Clicking the '1' Button to ensure we're on the first page of results."
findNode(jsFindNavButtonHome)

repeat
	tell application "Safari" to activate
	delay 2
	log "Finding the keywords in the DOM and storing the values..."
	
	set key1 to selectKeyword(selectorPath, 1, 0)
	set key2 to selectKeyword(selectorPath, 2, 0)
	set key3 to selectKeyword(selectorPath, 3, 0)
	set key4 to selectKeyword(selectorPath, 4, 0)
	set key5 to selectKeyword(selectorPath, 5, 0)
	set key6 to selectKeyword(selectorPath, 6, 0)
	set key7 to selectKeyword(selectorPath, 7, 0)
	set key8 to selectKeyword(selectorPath, 8, 0)
	set key9 to selectKeyword(selectorPath, 9, 0)
	set key10 to selectKeyword(selectorPath, 10, 0)
	
	log "Making a list of the stored values"
	set keywordList to {key1, key2, key3, key4, key5, key6, key7, key8, key9, key10}
	
	tell application "Google Chrome" to activate
	log "Setting the clip board items and pasting them..."
	
	setClipboard(key2)
	pasteIt()
	arrowAction(keyDown)
	
	setClipboard(key3)
	pasteIt()
	arrowAction(keyDown)
	
	setClipboard(key4)
	pasteIt()
	arrowAction(keyDown)
	
	setClipboard(key5)
	pasteIt()
	arrowAction(keyDown)
	
	setClipboard(key6)
	pasteIt()
	arrowAction(keyDown)
	
	setClipboard(key7)
	pasteIt()
	arrowAction(keyDown)
	
	setClipboard(key8)
	pasteIt()
	arrowAction(keyDown)
	
	setClipboard(key9)
	pasteIt()
	arrowAction(keyDown)
	
	setClipboard(key10)
	pasteIt()
	arrowAction(keyDown)
	
	log "Checking if the list contains 'end of the list'"
	
	if keywordList contains "end of the list" then
		log "Contains 'end of the list' so we're returning."
		return
	else
		log "Not the end of the list, keep going!"
	end if
	
	log "Clicking the 'Next' Pagination button..."
	findNode(jsFindNavButton)
	
	log "Waiting for the new keywords to load..."
	
	delay 3
end repeat

