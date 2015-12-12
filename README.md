# On-the-Map
The application posts user-generated location information to a shared map, pulling the locations of fellow Nanodegree students, with custom messages about themselves or their learning experience.

# Features 

* Users can login with their Udacity IDs and passwords in the login screen. 
* If they have Facebook IDs, they can be authenticated through Facebook's website by simply pressing the 'Sign in with Facebook' button.


![OTP Login](ScreenShot/OTM_Login.PNG)  


* Once users log in successfully, they can see a map with pins specifying the last 100 locations posted by students.
* If the user taps a pin, an annotation will pop up and shows a brief description including a student's name and a URL link. 
* When the list tap is selected, the most recent 100 locations posted by students are displayed in a table.


![OTP Main](ScreenShot/OTM_main.PNG)
![OTP Table](ScreenShot/OTM_Table.PNG)



* When users click a bar button shaped like a pin in the top of the view, the app present a new screen.
* Users can type the location where they are studying now, which will be followed by a forward geocoding process after users click the 'Find on the Map' button.
* If the forward geocode succeeds, then the app changes the screen and displays a map showing the entered location. 
* At the final step, users can enter a link of whatever they want to post. 


![OTP Location](ScreenShot/OTM_Location.PNG)
![OTP Link](ScreenShot/OTM_Link.PNG)


# How to build 

1) Clone the repository 
```
$ git clone https://github.com/woogii/On-the-Map.git
$ cd OnTheMap
```
2) Open the workspace in XCode 
```
$ open OnTheMap.xcodeproj/
```
3) Compile and run the app in your simulator 

# Compatibility 
The code of this project works in Swift2.0, Xcode 7.0 and iOS9 
