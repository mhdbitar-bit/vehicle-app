# Vehicle app

* It's a simple App that fetches a list of points from remote server. After the fetching process has been done a list of items will be presented using **UITableView**, alost displays the points on map.

The app contains one test target for **Unit Tests**, you can run the test by clicking ***⌘ + U***
 
## App Architecture :

I applied clean architecture in all my modules. you can see that the app is including the following modules:
 - API module
 - Feature/Domain module
 - UI and Presentation module

For the ***API module*** I used **URLSession** to handle the HTTP calls, Of course, the app has been implemented in a way that we can use any framework or third parties like **Alamofire**.  

For the ***Presentation module*** I used **MVVM** Design pattern, and I've tried to decouple all my modules using protocols, so you can find that I hide the implementation details by using protocols.

Finally, I composed all the module insdie the **SceneDeelgate**.
