This is the 3rd project from Udacity iOS developer Nanodegree Program.
It display all students enrolled in this course who posted his/her location and link on the map. 
So when you tap on the pin for that student, it will open the link associated with it like linkedin account or company website.
It allows user to post information (pin) on the map by entering the location ( address), and then reverse geo-coding to find the GPS coordinates and then ask for
the link URL.
This app checks to see if there is a network connectivity,if  the URL is valid and if the address is correct before posting.
This app also checks to see if the student also posted before to avoid duplciates using upsert techniques.
It also provides student search capcity. As user key-in the last name of student, any match is displayed in a table.
