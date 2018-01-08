global currentApplication

-- very hacky, couldn't think of a better way to do it
-- todo: use node to parse everything

if application "iTunes" is running then
	set currentApplication to "itunes"
	
	tell application "iTunes"
		if player state is playing then
			set currentTrack to current track
			
			tell currentTrack
				set songTitle to name
				set songArtist to album artist
			end tell
			
			return {application:currentApplication, title:songTitle, artist:songArtist}
		end if
	end tell
end if

if application "Safari" is running then
	tell application "Safari"
		repeat with x from 1 to number of windows
			repeat with y from 1 to number of tabs in window x
				set windowTitle to name of tab y of window x
				
				if "youtube.com" is in URL of tab y of window x then
					set currentApplication to "youtube"
					
					return my parseTitle(windowTitle)
					
					exit repeat
				end if
				
				if "soundcloud.com" is in URL of tab y of window x then
					set currentApplication to "soundcloud"
					
					return my parseTitle(windowTitle)
					
					exit repeat
				end if
			end repeat
		end repeat
	end tell
end if

if application "Google Chrome" is running then
	tell application "Google Chrome"
		repeat with x from 1 to number of windows
			repeat with y from 1 to number of tabs in window x
				set windowTitle to title of tab y of window x
				
				if "youtube.com" is in URL of tab y of window x then
					set currentApplication to "youtube"
					
					return my parseTitle(windowTitle)
					
					exit repeat
				end if
				
				if "soundcloud.com" is in URL of tab y of window x then
					set currentApplication to "soundcloud"
					
					return my parseTitle(windowTitle)
					
					exit repeat
				end if
			end repeat
		end repeat
	end tell
end if

on parseTitle(windowTitle)
	if windowTitle contains " - YouTube" then
		set songData to my split(windowTitle, " - YouTube")
		set songTitle to item 1 of songData
		
		return {application:currentApplication, title:songTitle, artist:""}
	else if windowTitle contains " by " then
		set songData to my split(windowTitle, " by ")
		
		set songTitle to item 1 of songData
		set songArtist to item 2 of songData
		
		return {application:currentApplication, title:songTitle, artist:songArtist}
	else if windowTitle contains " in " then
		set songData to my split(windowTitle, " in ")
		set songTitle to item 1 of songData
		
		return {application:currentApplication, title:songTitle, artist:""}
	end if
	
	return "none"
end parseTitle

on split(theString, theDelimiter)
	set oldDelimiters to AppleScript's text item delimiters
	set AppleScript's text item delimiters to theDelimiter
	set theArray to every text item of theString
	set AppleScript's text item delimiters to oldDelimiters
	
	return theArray
end split

"none"