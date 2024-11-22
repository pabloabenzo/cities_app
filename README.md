# cities_app

In this Readme file I'm going to explain how I solved the memory leak charge due of the big amount of data received from the endpoint. I decided to use a method which recharge the list while the user is scrolling down in the view, for avoid unnecessary memory use. Also I have adapted the search logic into it. For data persistence I chose keep it in UserDefaults fot this challenge, but for a bigger and real project I would choose Core Data or Swift Data for data persistence. I liked MVVM as architecture for the project (I would use Viper for giant apps with modules, for example), and XCTest for Unit Test over Swift Testing (only 1 test added because of lack of time). Remaining implementations not completed (half-finished) due to lack of time: Dynamic UI for landscape view. Issues to fix: 1- Empty rows bug in list, 2- Favorites marked from the search view are not saved correctly. I enjoyed developing this app ♥
