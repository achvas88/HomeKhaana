// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });

'use strict';

const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();
const {Storage} = require('@google-cloud/storage');

const storage = new Storage({projectId: "homekhaanamain"});

exports.updateKitchenRating = functions.database.ref('/KitchenRatings/{kitchenId}/rating')
.onWrite((change, context) => {
    const newRating = change.after.val();
    admin.database().ref(`/Kitchens/ByID/${context.params.kitchenId}/rating`).set(newRating);
});
         
exports.updateKitchenRatingCount = functions.database.ref('/KitchenRatings/{kitchenId}/ratingCount')
.onWrite((change, context) => {
    const newRatingCount = change.after.val();
    admin.database().ref(`/Kitchens/ByID/${context.params.kitchenId}/ratingCount`).set(newRatingCount);
});

exports.deleteKitchen = functions.database.ref('/Kitchens/ByID/{kitchenId}')
.onDelete((snap, context) => {
    const kitchen = snap.val();
    updateCoordinatesNodesForKitchen(context.params.kitchenId, kitchen, true);
});

function updateCoordinatesNodesForKitchen(kitchenId, kitchen, forKilling) {
    const kLat = kitchen.latitude;
    const kLong = kitchen.longitude;
    
    const kLatFloor = Math.floor(kLat);
    const kLatCeil = Math.ceil(kLat);
    const kLongFloor = Math.floor(kLong);
    const kLongCeil = Math.ceil(kLong);
 
    const kCorr1 = kLatFloor + ":" + kLongFloor;
    const kCorr2 = kLatFloor + ":" + kLongCeil;
    const kCorr3 = kLatCeil + ":" + kLongFloor;
    const kCorr4 = kLatCeil + ":" + kLongCeil;
    
    if(forKilling)
    {
        killCoordinateNodesForKitchen(kCorr1, kCorr2, kCorr3, kCorr4, kitchenId)
    }
    else
    {
        setCoordinateNodesForKitchen(kCorr1, kCorr2, kCorr3, kCorr4, kitchenId, kitchen)
    }
}

function killCoordinateNodesForKitchen(kCorr1,kCorr2,kCorr3,kCorr4,kitchenId)
{
    admin.database().ref(`/Kitchens/ByLocation/${kCorr1}/${kitchenId}`).remove();
    admin.database().ref(`/Kitchens/ByLocation/${kCorr2}/${kitchenId}`).remove();
    admin.database().ref(`/Kitchens/ByLocation/${kCorr3}/${kitchenId}`).remove();
    admin.database().ref(`/Kitchens/ByLocation/${kCorr4}/${kitchenId}`).remove();
}

function setCoordinateNodesForKitchen(kCorr1,kCorr2,kCorr3,kCorr4,kitchenId, kitchen)
{
    admin.database().ref(`/Kitchens/ByLocation/${kCorr1}/${kitchenId}`).set(kitchen);
    admin.database().ref(`/Kitchens/ByLocation/${kCorr2}/${kitchenId}`).set(kitchen);
    admin.database().ref(`/Kitchens/ByLocation/${kCorr3}/${kitchenId}`).set(kitchen);
    admin.database().ref(`/Kitchens/ByLocation/${kCorr4}/${kitchenId}`).set(kitchen);
}

exports.updateKitchensAtCoordinates = functions.database.ref('/Kitchens/ByID/{kitchenId}')
.onWrite((change, context) => {
    const kitchenBef = change.before.val();
    const kitchen = change.after.val();
    
    updateCoordinatesNodesForKitchen(context.params.kitchenId, kitchenBef, true); //kill previous kichen coordinate nodes
    updateCoordinatesNodesForKitchen(context.params.kitchenId, kitchen, false); //set new ones
    
//    //get the latitudes/longitudes
//    const kLatBef = kitchenBef.latitude;
//    const kLongBef = kitchenBef.longitude;
//    const kLat = kitchen.latitude;
//    const kLong = kitchen.longitude;
//
//    //get ceil and floor values. This will give a radius of 120 sq km. Okay for now.
//    const kLatFloorBef = Math.floor(kLatBef);
//    const kLatCeilBef = Math.ceil(kLatBef);
//    const kLongFloorBef = Math.floor(kLongBef);
//    const kLongCeilBef = Math.ceil(kLongBef);
//    const kLatFloor = Math.floor(kLat);
//    const kLatCeil = Math.ceil(kLat);
//    const kLongFloor = Math.floor(kLong);
//    const kLongCeil = Math.ceil(kLong);
//
//    //location string to store the kitchen into
//    const kCorr1Bef = kLatFloorBef + ":" + kLongFloorBef;
//    const kCorr2Bef = kLatFloorBef + ":" + kLongCeilBef;
//    const kCorr3Bef = kLatCeilBef + ":" + kLongFloorBef;
//    const kCorr4Bef = kLatCeilBef + ":" + kLongCeilBef;
//    const kCorr1 = kLatFloor + ":" + kLongFloor;
//    const kCorr2 = kLatFloor + ":" + kLongCeil;
//    const kCorr3 = kLatCeil + ":" + kLongFloor;
//    const kCorr4 = kLatCeil + ":" + kLongCeil;
//
//    //kill the kitchen nodes in the previous locations
//    admin.database().ref(`/Kitchens/ByLocation/${kCorr1Bef}/${context.params.kitchenId}`).remove();
//    admin.database().ref(`/Kitchens/ByLocation/${kCorr2Bef}/${context.params.kitchenId}`).remove();
//    admin.database().ref(`/Kitchens/ByLocation/${kCorr3Bef}/${context.params.kitchenId}`).remove();
//    admin.database().ref(`/Kitchens/ByLocation/${kCorr4Bef}/${context.params.kitchenId}`).remove();
//
//
//    //set the kitchen nodes in the new locations
//    admin.database().ref(`/Kitchens/ByLocation/${kCorr1}/${context.params.kitchenId}`).set(kitchen);
//    admin.database().ref(`/Kitchens/ByLocation/${kCorr2}/${context.params.kitchenId}`).set(kitchen);
//    admin.database().ref(`/Kitchens/ByLocation/${kCorr3}/${context.params.kitchenId}`).set(kitchen);
//    admin.database().ref(`/Kitchens/ByLocation/${kCorr4}/${context.params.kitchenId}`).set(kitchen);
});

exports.updateUserRating2 = functions.database.ref('/UserRatings/{userId}/rating')
.onWrite((change, context) => {
    const newRating = change.after.val();
    admin.database().ref(`/Users/${context.params.userId}/rating`).set(newRating);
});
      
exports.updateUserRatingCount = functions.database.ref('/UserRatings/{userId}/ratingCount')
.onWrite((change, context) => {
    const newRatingCount = change.after.val();
    admin.database().ref(`/Users/${context.params.userId}/ratingCount`).set(newRatingCount);
});

exports.sendChat = functions.database.ref('/CurrentOrders/{kitchenId}/{orderingUserID}/{orderID}/Chat/{chatID}')
.onCreate((snap, context) => {
    const chatMessage = snap.val();
    const senderName = chatMessage.name;
    var whoToSendNotificationTo
    
    if(chatMessage.sender_id == context.params.orderingUserID)
    {
        whoToSendNotificationTo = context.params.kitchenId
    }
    else
    {
        whoToSendNotificationTo = context.params.orderingUserID
    }
    return admin.database().ref(`/Users/${whoToSendNotificationTo}/fcmToken`).once('value')
    .then((snapshot) => {
          return snapshot.val();
          }).then((registrationToken) => {
              
              const message = {
                  notification: {
                      title: chatMessage.name,
                      body: chatMessage.text
                  },
                  token: registrationToken
              };
              
              return admin.messaging().send(message)
              .then((response) => {
                    // Response is a message ID string.
                    console.log('Successfully sent message:', response);
                    })
              .catch((error) => {
                     throw new Error('Error sending message:', error);
                     });
          })
});

//update the pickup time
exports.updatePickupTime = functions.database.ref('/CurrentOrders/{kitchenId}/{orderingUserID}/{orderID}/pickupTime')
.onWrite((change, context) => {
        const newPickupTime = change.after.val();
        admin.database().ref(`/Orders/${context.params.orderingUserID}/${context.params.orderID}/pickupTime`).set(newPickupTime);
});

//when an order's status is updated by the kitchen.
exports.updateOrderStatus2 = functions.database.ref('/CurrentOrders/{kitchenId}/{orderingUserID}/{orderID}/status')
.onWrite((change, context) => {
		 
		 // Only edit data when it previously existed
		 if (!change.before.exists()) {
		 	return null;
		 }
		 
		 //now update the Orders node and send a notification to the user about the order status update.
		 return admin.database().ref(`/Users/${context.params.orderingUserID}/fcmToken`).once('value')
		 .then((snapshot) => {
			   return snapshot.val();
			   }).then((registrationToken) => {
					   if (!change.after.exists())
					   {
					       // when the data is deleted, mark the corresponding order in the Orders location as complete.
						   console.log('Updating order status to complete in the Orders location');
						   admin.database().ref(`/Orders/${context.params.orderingUserID}/${context.params.orderID}/status`).set("Completed");
					   
						   const message = {
							   notification: {
								   title: 'Order Completed!',
								   body: 'Your order is now complete. Thank you!'
							   },
							   token: registrationToken
						   };
					   
						   return admin.messaging().send(message)
						   .then((response) => {
								 // Response is a message ID string.
								 console.log('Successfully sent message:', response);
								 })
						   .catch((error) => {
								  throw new Error('Error sending message:', error);
								  });
					   }
					   else
					   {
						   // set the new status to the order
						   const newStatus = change.after.val();
						   console.log('Updating order status in the Orders location', context.params.orderID, newStatus);
						   admin.database().ref(`/Orders/${context.params.orderingUserID}/${context.params.orderID}/status`).set(newStatus);
                           
                           var message;
                           if(newStatus != "Confirmed")
                           {
                               message = {
                                   notification: {
                                       title: 'Order Status Update!',
                                       body: 'Your order is now in the status of: ' + change.after.val()
                                   },
                                   token: registrationToken
                               };
                           }
                           else
                           {
                               message = {
                                   notification: {
                                       title: 'Order Confirmed!',
                                       body: 'Check your pickup time in the Orders Screen'
                                   },
                                   token: registrationToken
                               };
                           }
						   return admin.messaging().send(message)
						   .then((response) => {
								 // Response is a message ID string.
								 console.log('Successfully sent message:', response);
								 })
						   .catch((error) => {
								  throw new Error('Error sending message:', error);
								  });
					   }
				})
});


//move to the current orders dictionary
exports.charge2 = functions.database.ref('/Orders/{userId}/{id}')
.onCreate((snap, context) => {
        const val = snap.val();
        snap.ref.child('status').set("Ordered");
        val.status = "Ordered";
        const kitchenId = val.kitchenId;
        admin.database().ref(`/CurrentOrders/${kitchenId}/${context.params.userId}/${context.params.id}`).set(val);
        
        //now send a notification to the kitchen about the new order.
        return admin.database().ref(`/Users/${kitchenId}/fcmToken`).once('value')
        .then((snapshot) => {
            return snapshot.val();
            }).then((registrationToken) => {
                        const message = {
                            notification: {
                                title: 'Order Received!',
                                body: 'You have received a new order. Let\'s get cooking!'
                            },
                            token: registrationToken
                        };
                    
                        return admin.messaging().send(message)
                            .then((response) => {
                                  // Response is a message ID string.
                                  console.log('Successfully sent message:', response);
                                  })
                            .catch((error) => {
                                   throw new Error('Error sending message:', error);
                                   });
                    });
        
});

//when an inventory item is deleted, delete the corresponding image in the google cloud storage
exports.sanitizePhoto = functions.database.ref('MenuItems/{kitchenID}/{sectionID}/items/{itemID}')
.onDelete((snap, context) => {
    
    console.log(`Creating the file path...`)
    const filePath = `${context.params.kitchenID}/MenuItems/${context.params.itemID}/itemPhoto`

    console.log(`Getting the storage bucket...`)
    const bucket = storage.bucket('gs://homekhaanamain.appspot.com')
    const file = bucket.file(filePath)
    
    console.log(`Okay now. trying to delete...`)
    file.delete().then(() => {
        console.log(`Successfully deleted photo`)
      })
      .catch(err => {
        console.log(`Failed to remove photo, error: ${err}`)
      });
});




/////// ----------- payment functions ---------------


//const stripe = require('stripe')(functions.config().stripe.token);
//const currency = functions.config().stripe.currency || 'usd';

// create stripe customer when user is created
//exports.createUser = functions.database
//.ref('/Users/{userId}').onCreate((snap, context) => {
//								 const newUser = snap.val();
//
//								 return stripe.customers.create({
//																email: newUser.email,
//																}).then((customer) => {
//																		return admin.database().ref(`/Users/${context.params.userId}/customerID`).set(customer.id);
//																		});
//								 });
//

//delete stripe customer when user is deleted
/*exports.deleteUser = functions.database
 .ref('/Users/{userId}').onDelete((snap, context) => {
 const newUser = snap.val();
 return stripe.customers.del(newUser.customerID);
 });*/

/*
 // add payment source
 exports.addPaymentSource = functions.database
 .ref('/PaymentSources/{userId}/{token}').onCreate((snap, context) => {
 return admin.database().ref(`/Users/${context.params.userId}/customerID`)
 .once('value').then((snapshot) => {
 return snapshot.val();
 }).then((customer) => {
 return stripe.customers.createSource(customer, {source: context.params.token});
 }).then((response) => {
 return snap.ref.set(response);
 }, (error) => {
 return snap.ref.child('error').set(userFacingMessage(error));
 });
 });
 
 //remove payment source
 exports.removePaymentSource = functions.database.ref('/PaymentSources/{userId}/{token}').onDelete((snap, context) => {
 const card = snap.val();
 const source = card.id;
 const customer = card.customer;
 return stripe.customers.deleteSource(
 customer,
 source,
 function(err, source) {
 // doing nothing for now
 }
 );
 });
 */

/*
 //charge the customer - credit card charging
 exports.charge = functions.database.ref('/Orders/{userId}/{id}').onCreate((snap, context) => {
 const val = snap.val();
 return admin.database().ref(`/Users/${context.params.userId}/customerID`).once('value').then((snapshot) => {
 return snapshot.val();
 }).then((customer) => {
 const amount = val.amount;
 const chargeID = context.params.id;
 const charge = {amount, currency, customer};
 if (val.source !== null)
 {
 charge.source = val.source;
 }
 return stripe.charges.create(charge, {idempotency_key: chargeID});
 }).then((response) => {
 // write response to database
 if(response.status=="succeeded")
 {
 snap.ref.child('status').set("Ordered");
 val.status = "Ordered";
 const kitchenId = val.kitchenId;
 admin.database().ref(`/CurrentOrders/${kitchenId}/${context.params.userId}/${context.params.id}`).set(val);
 }
 return snap.ref.child('stripeResponse').set(response);
 }).catch((error) => {
 snap.ref.child('status').set("Error Processing Payment");
 //return snap.ref.child('stripeResponse/error').set(error.message);
 return snap.ref.child('stripeResponse/error').set(userFacingMessage(error));
 });
 });*/

//get default payment source
/*
 exports.getDefaultPaymentSource = functions.https.onCall((data, context) => {
 if (!context.auth) {
 throw new functions.https.HttpsError('failed-precondition', 'No authenticated user found.');
 }
 const uid = context.auth.uid;
 
 return admin.database().ref(`/Users/${uid}/customerID`).once('value').then((snapshot) => {
 return snapshot.val();
 }).then((customer) => {
 return stripe.customers.retrieve(customer);
 }).then((response) => {
 var defaultSourceID= response["default_source"];
 return {"defaultSourceID": defaultSourceID};
 });
 });
 
 //get default payment source
 exports.updateDefaultPaymentSource = functions.https.onCall((data, context) => {
 if (!context.auth) {
 throw new functions.https.HttpsError('failed-precondition', 'No authenticated user found.');
 }
 
 //passed on using ["updatedDefaultSourceID": inputField.text]
 const updatedDefaultSourceID = data.updatedDefaultSourceID;
 
 if (updatedDefaultSourceID=="") {
 throw new functions.https.HttpsError('failed-precondition', 'Default source ID is empty.');
 }
 
 const uid = context.auth.uid;
 
 return admin.database().ref(`/Users/${uid}/customerID`).once('value').then((snapshot) => {
 return snapshot.val();
 }).then((customer) => {
 return stripe.customers.update(customer, {"default_source": updatedDefaultSourceID});
 });
 });
 
 
 //sanitize error message
 function userFacingMessage(error) {
 return error.type ? error.message : 'Oops! Something went wrong. The developers are on it!';
 }

 */
