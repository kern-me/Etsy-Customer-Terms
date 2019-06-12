-- ========================================
-- PROPERTIES
-- ========================================
set AppleScript's text item delimiters to ","

property defaultKeyDelay : 0.2
property defaultDelayValue : 0.75

property rowHeaders : "Search Query, Impressions, Position, Visits, Conversion Rate, Revenue, Listings"

property newLine : "\n"

property jsFindNavButton : "document.querySelectorAll('.pagination')[0].querySelectorAll('.btn-group-item:last-child')[0].click()"

property jsNextButtonDisabled : "document.querySelectorAll('.pagination')[0].querySelectorAll('.btn-group-item:last-child')[0].disabled"

property jsFindNavButtonHome : "document.querySelectorAll('.pagination')[0].querySelectorAll('.btn-group-item')[1].click()"

property mainURL : "https://www.etsy.com/your/shops/me/stats/traffic?ref=seller-platform-mcnav"


-- ========================================
-- READ AND WRITE
-- ========================================

on writeTextToFile(theText, theFile, overwriteExistingContent)
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
	set this_Story to theContent
	set theFile to (((path to desktop folder) as string) & "Etsy Searched Terms.csv")
	writeTextToFile(this_Story, theFile, writable)
end writeFile

-- Write Headers
on writeHeaders()
	writeFile(rowHeaders & newLine, false) as text
end writeHeaders


-- ========================================
-- DOM INTERACTIONS
-- ========================================

on getColumnData(theRow, theColumn)
	tell application "Safari"
		set theData to do JavaScript "document.querySelectorAll('table tr:nth-child(" & theRow & ") td')[" & theColumn & "].innerText.trim()" in document 1
		return theData
	end tell
end getColumnData


-- ========================================
-- WRITE HEADERS
-- ========================================

-- Write the Data
on getRowData(theRow)
	set theCount to 0
	
	repeat 7 times
		set updatedCount to (theCount + 1)
		
		delay 0.5
		
		set rowData to getColumnData(theRow, updatedCount - 1)
		set theCount to theCount + 1
		writeFile(rowData & ",", false) as text
	end repeat
	
	writeFile(newLine, false) as text
end getRowData



# Count number of data rows
on countRows()
	tell application "Safari"
		set a to do JavaScript "document.querySelector('tbody').childElementCount" in document 1
		delay 1
		return a
	end tell
end countRows


-- Button Interaction Handler
property pageNext : "#root > div > div:nth-child(3) > div > div > div > button:last-child"
property firstPage : "#root > div > div:nth-child(3) > div > div > div > button:nth-child(2)"




on startPagination()
	tell application "Safari"
		set a to do JavaScript "document.querySelector('" & firstPage & "').click()" in document 1
	end tell
end startPagination




on clickButton(selector)
	tell application "Safari"
		set checkDisabled to do JavaScript "document.querySelector('" & selector & "').disabled" in document 1
		
		if checkDisabled is true then
			return false
		end if
		
		set a to do JavaScript "document.querySelector('" & selector & "').click()" in document 1
		delay 1
		return true
	end tell
end clickButton


# Main Repeat Loop
on mainLoop()
	writeFile(rowHeaders & newLine, false) as text
	
	startPagination()
	
	delay 0.5
	
	repeat
		set theCount to 0
		set rowCount to countRows()
		
		repeat rowCount times
			set updatedCount to (theCount + 1)
			set rowData to getRowData(updatedCount)
			set theCount to theCount + 1
		end repeat
		
		if clickButton(pageNext) is false then
			exit repeat
		end if
	end repeat
end mainLoop

-- ========================================
-- ROUTINES
-- ========================================
mainLoop()
