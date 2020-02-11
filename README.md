# flux_garages
Advanced NUI garage system based on netr_garages.


# Description
I know that it can be better optimized but I haven't got time for it right now. Maybe in the future I will do it.

Let's start with config. In Config.Garage you're setting garages for players. 'Marker' is a place where garage is. 'Blip' determines whether the blip is visible on the map. In 'Visible' table you can designate jobs that can use the selected garage.

In Config.Impound you designate place for towing player vehicles on the map - it's marked with red truck.

In Config.PoliceImpound you can set place for police parking which is invisible on map. 

In Config.SetSubowner you designate place for setting co-owners for players vehicles.


# How it all works
Config.Garage isn't even difficult. You can store repaired vehicles -> value you can specify in Config.MinimumHealth. You store and pull vehicles in one marker and that's all what you have to know.

Impound marker is responsible for towing your vehicles which aren't on police parking. It means that, if someone stole your car or you were kicked out of the game and the car disappeared, in this place you will be able to get your vehicle back. Price you can specify in Config. If vehicle is already on map it will be deleted if no-one is inside.

The first of all, if you want Police Impound to work properly you have to do command which is responsible for moving the vehicle to the police parking e.g. https://pastebin.com/f6RLRs8j
Then if you made it useful everything that you need is police job called 'police' - only with this job you can use marker. There you can see vehicles with state = 2 in you database. It's very useful in roleplay.

The last option in my garage system is setting co-owners, subowners or whatever you call it. You're going into marker and you have to enter your vehicle's plate otherwise you won't be able to set or manage subowners. Then when you are owner of this car (owner_type = 1 in owned_vehicles table) you can set new subowner (closest player) or manage current subowners (delete them). Subowners are specified by 0 in owner_type column. Max number or subowner you can specify in Config. If you don't want allow co-owners to sell cars, you must specify it in the parts of the code that contain it.


# Installation
Drag and drop. You also need to have es_extended installed. Don't forget about .sql file!


# License
Please don't sell, reupload or change the name of this resource. Based on netr_garages.


# Videos
https://medal.tv/clips/19162177/d1337nlInqvA - Towing vehicles
https://medal.tv/clips/19162163/d1337biAo8nn - Police parking
https://medal.tv/clips/19162146/d1337tuUd68m - Setting co-owners


If you find a bug or if you get an error please make an issue at the Github page.
