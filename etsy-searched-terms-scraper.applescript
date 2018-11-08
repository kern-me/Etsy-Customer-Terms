-- ========================================
-- Properties
-- ========================================
set AppleScript's text item delimiters to ","

property defaultDelayValue : 0.75

property rowHeaders : "Search Terms, Etsy, Google, Total Visits"

property newLine : "\n"



property jsNextButtonDisabled : "document.querySelectorAll('.pagination')[0].querySelectorAll('.btn-group-item:last-child')[0].disabled"

property jsFindNavButtonHome : "document.querySelectorAll('.pagination')[0].querySelectorAll('.btn-group-item')[1].click()"

# For the pagination button
property rowSelector : "#horizontal-chart3 > div > div"

# For the keywords
property selectorPath : "#horizontal-chart3 > div"


on userPrompt(theText)
	activate
	display dialog theText
end userPrompt

on userPrompt2Buttons(theText, buttonText1, buttonText2)
	activate
	display dialog theText buttons {buttonText1, buttonText2}
end userPrompt2Buttons


-- Reading and Writing Params
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


-- Get the keyword
on getKeyword(instance)
	tell application "Safari"
		try
			set a to do JavaScript "document.querySelectorAll(\"#horizontal-chart3 span[data-test-id='unsanitize']\")[" & instance & "].innerText" in document 1
			return a
		on error
			return false
		end try
	end tell
end getKeyword

-- Get the number of Etsy visits
on getEtsyVisits(instance)
	tell application "Safari"
		set a to do JavaScript "document.querySelectorAll(\"#horizontal-chart3 > tr:nth-child(" & instance & ") > td > div > div.col-group.pl-xs-2.pl-md-1.pr-xs-2.pr-md-1.pl-lg-0.pr-lg-0.pt-xs-2 > div.col-xs-8.text-gray-lighter.text-right.pr-md-0 > div\")[0].innerText" in document 1
		return a
	end tell
end getEtsyVisits

-- Get "Google, etc" data
on getGoogleData(instance)
	tell application "Safari"
		set a to do JavaScript "document.querySelectorAll(\"#horizontal-chart3 > tr:nth-child(" & instance & ") > td > div > div.col-group.pl-xs-2.pl-md-1.pr-xs-2.pr-md-1.pl-lg-0.pr-lg-0.pt-xs-2 > div.col-xs-8.text-gray-lighter.text-right.pr-md-0 > div\")[1].innerText" in document 1
		return a
	end tell
end getGoogleData

-- Get Total Visits
on getTotalVisits(instance)
	tell application "Safari"
		set a to do JavaScript "document.querySelectorAll(\"#horizontal-chart3 > tr:nth-child(" & instance & ") > td > div > div.col-group.pl-xs-2.pl-md-1.pr-xs-2.pr-md-1.pl-lg-0.pr-lg-0.pt-xs-2 > div.col-xs-8.text-gray-lighter.text-right.pr-md-0 > div\")[2].innerText" in document 1
		return a
	end tell
end getTotalVisits

################################
# CONSTRUCTOR HANDLERS
################################

# Initialize - click the 1 button
on initialize()
	#log "Clicking the '1' Button to ensure we're on the first page of results."
	set a to "document.querySelectorAll('.pagination .btn')[1].click()"
	findNode(a)
end initialize

# Check "next" button
on checkPaginationButton()
	tell application "Safari"
		set a to do JavaScript "document.querySelectorAll('.pagination')[0].querySelectorAll('.btn-group-item:last-child')[0].disabled" in document 1
		
		return a
	end tell
end checkPaginationButton

# Click Pagination Next Button
on paginationNext()
	# Clicking the '1' Button to ensure we're on the first page of results."
	set a to "document.querySelectorAll('.pagination')[0].querySelectorAll('.btn-group-item:last-child')[0].click()"
	
	findNode(a)
end paginationNext


#################################
# MAIN ROUTINE #
#################################

on getData()
	writeFile(rowHeaders & newLine, false) as string
	
	initialize()
	
	repeat
		set theCount to -1
		set keyword to ""
		
		repeat
			set updatedCount to (theCount + 1)
			delay defaultDelayValue
			
			# Get the Keyword Term
			set keyword to getKeyword(updatedCount)
			
			# End the loop when the keyword query comes back as false
			if keyword is false then
				#log "End of the loop. Exiting this loop."
				exit repeat
			end if
			
			# Set keyword to string
			set keyword to keyword as string
			
			# Find the Etsy Visits data
			set etsyVisits to getEtsyVisits(updatedCount + 2)
			set etsyVisits to etsyVisits as string
			
			# Find the Google, Etc data
			set googleData to getGoogleData(updatedCount + 2)
			set googleData to googleData
			
			# Find the Total Visits
			set totalVisits to getTotalVisits(updatedCount + 2)
			set totalVisits to totalVisits as string
			
			# Update the counter
			set theCount to theCount + 1
			
			# Write to file
			writeFile(keyword & "," & etsyVisits & "," & googleData & "," & totalVisits & newLine, false) as string
		end repeat
		
		# Check to see if the button is disabled
		if checkPaginationButton() is false then
			paginationNext()
		else
			# Next button is disabled. Exiting repeat loop.
			exit repeat
		end if
		
		# Waiting for the new keywords to load...
		delay defaultDelayValue
	end repeat
	userPrompt("Finished!")
end getData

--

getData()

