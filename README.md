This is the 3rd project from Udacity iOS developer Nanodegree Program.
It display all students enrolled in this course who posted his/her location and link on the map. 
So when you tap on the pin for that student, it will open the link associated with it like linked account or company url.
It allows user to post information on the map by entering the location ( address), and then reverse geo-coding to find the GPS coordinates and then ask for
the link URL.
This app checks to see if is there a network connectivity, the URL is valid and the address is correct before posting.
This app also checks to see if the student also posted before to avoid duplciates using upsert techniques.
