<h1>RememberIt</h1>
RememberIt is trip organizer. It allows a user to add an entry including a photo collection from existing photo library. Users can also remove photos, remove an entry and view trip location. Specific gestures like swipe in a list allows user to delete an entry. Long press on an added photo allows a user to view that photo in full size.
 
<h2>Important source files</h2>
MapViewController - View Location<br />
PhotosTripViewController - View trip detail and add to it. Select one or more photos and delete. Delete an entry all together. Select to see the map of the trip<br />
TripsTableViewController - Trip list entries. Can swipe to delete trip<br />
TripViewController - Entry point for app. Add new entry. Validation checks in place for required field and dates. Allows for address lookup/validation.<br />
ShowPhotoViewController - View photo (after long press) as full size<br />
