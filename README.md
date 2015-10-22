To run this, you must have Ruby installed and an Otago evision account. Download the ruby file and type:
ruby GradeCheck.rb <username> <password> <(optional)regular expression>

if you include the regular expression, results for papers that match this expression will be retrieved. Otherwise you will be asked to provide a list of papers you want results for (warning: these are case sensitive - so cosc320 != COSC320).

Output will be written to a file called RESULTS.txt which should be in the same folder as the program. This can be changed by opening the file and changing the value of $path on line 5. Note that this file will be deleted if a regex is used and no results are found.

<h1>Mac Users</h1>
Also included in this repository is a plist for MacOSX launchd. Make sure to change the PROGRAM LOCATION, USERNAME, PASSWORD and regular expression (currently set to selected COSC400 llevel papers) as appropriate. It is set up to check at 7, 8, 9 and 10 o'clock every day since it will not run if the computer is turned off at that time. Alter as you see fit.

This file should be owned by the root user and placed into /Library/LaunchAgents/.

<h1>Linux Users</h1>
I recommend using crond if you want to check for results each morning.

<h1>Windows Users</h1>
There are suggestions here: http://stackoverflow.com/questions/132971/what-is-the-windows-version-of-cron but I no longer have Windows, so I can't be much help sorry.
