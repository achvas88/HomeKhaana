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
const stripe = require('stripe')(functions.config().stripe.token);
const currency = functions.config().stripe.currency || 'usd';

// create stripe customer when user is created 
exports.createUser = functions.database
    .ref('/Users/{userId}').onCreate((snap, context) => {
      const newUser = snap.val();

      return stripe.customers.create({
        email: newUser.email,
      }).then((customer) => {
       return admin.database().ref(`/Users/${context.params.userId}/customerID`).set(customer.id);
      });
});

//delete stripe customer when user is deleted
exports.deleteUser = functions.database
    .ref('/Users/{userId}').onDelete((snap, context) => {
      const newUser = snap.val();
      return stripe.customers.del(newUser.customerID);
});

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

//charge the customer
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
		admin.database().ref(`/CurrentOrders/${context.params.userId}/${context.params.id}`).set(val);
	    }
            return snap.ref.child('stripeResponse').set(response);
          }).catch((error) => {
	    snap.ref.child('status').set("Error Processing Payment");
            return snap.ref.child('stripeResponse/error').set(userFacingMessage(error));
          });
});

//sanitize error message
function userFacingMessage(error) {
  return error.type ? error.message : 'Oops! Something went wrong. The developers are on it!';
}

//get default payment source
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
