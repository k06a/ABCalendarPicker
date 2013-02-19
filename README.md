#ABCalendarPicker

Fully configurable iOS calendar UI component with multiple layouts and smooth animations.

##Screenshots of grid layouts

Month, year, 20-years views:

<img src="https://raw.github.com/k06a/ABCalendarPicker/master/month-grid-screenshot.png" width="30%" />&nbsp;&nbsp;&nbsp;&nbsp;<img src="https://raw.github.com/k06a/ABCalendarPicker/master/year2-grid-screenshot.png" width="30%" />&nbsp;&nbsp;&nbsp;&nbsp;<img src="https://raw.github.com/k06a/ABCalendarPicker/master/20years-grid-screenshot.png" width="30%" />

Week view:

<img src="https://raw.github.com/k06a/ABCalendarPicker/master/week-grid-screenshot.png" width="30%" />

Seasoned month view:

<img src="https://raw.github.com/k06a/ABCalendarPicker/master/year-grid-screenshot.png" width="30%" />

##Include framework in your project

###Get compiled framework and bundle

1. Get it from ```/Demo``` subdirectory or goto 2.

2. Compile project _ABCalendarPicker.xcodeproj_

3. Open ```~/Library/Developer/Xcode/DerivedData``` in Finder by pressing ⇧⌘G

4. Find _ABCalendarPicker.framework_ and _ABCalendarPicker.bundle_ in ```.../ABCalendarPicker-xxxxxxxxxxx/Build/Products/```

###Add framework and bundle to your project

1. Add _ABCalendarPicker.framework_ to your project frameworks

2. Add _ABCalendarPicker.bundle_ to your project resources

###Using ABCalendarPicker class to XIB file

1. Create UIView object in your XIB

2. Change UIView class to ABCalendarPicker using Identity Inspector

3. Add this first line to main.m: ```[ABCalendarPicker class];```

4. ```#import <ABCalendarPicker/ABCalendarPicker.h>``` anywhere you need.

##Demo video

[http://youtu.be/d2PGFiO_jk4](http://youtu.be/d2PGFiO_jk4)

##App to try

[Mr.Calendario in AppStore](http://appstore.com/mr.calendario) (not free)