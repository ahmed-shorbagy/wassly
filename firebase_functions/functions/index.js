const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

// 1. Notify Restaurant & Admin when a new order is placed
exports.onOrderCreated = functions.firestore
    .document("orders/{orderId}")
    .onCreate(async (snapshot, context) => {
        const order = snapshot.data();
        const orderId = context.params.orderId;
        const restaurantId = order.restaurantId;
        const restaurantName = order.restaurantName || "Restaurant";

        // Notification for the Restaurant (Partner App)
        const partnerMessage = {
            notification: {
                title: "New Order Received! 🔔",
                body: `You have separate new order #${orderId} from ${order.customerName}.`,
            },
            topic: `restaurant_${restaurantId}`,
            data: {
                orderId: orderId,
                type: "new_order",
                click_action: "FLUTTER_NOTIFICATION_CLICK",
            },
        };

        // Notification for Admins
        const adminMessage = {
            notification: {
                title: "New Order Placed 📦",
                body: `Order #${orderId} placed at ${restaurantName}.`,
            },
            topic: "admin_notifications",
            data: {
                orderId: orderId,
                type: "admin_new_order",
                click_action: "FLUTTER_NOTIFICATION_CLICK",
            },
        };

        const promises = [];
        promises.push(admin.messaging().send(partnerMessage));
        promises.push(admin.messaging().send(adminMessage));

        try {
            await Promise.all(promises);
            console.log(`Notifications sent for new order ${orderId}`);
        } catch (error) {
            console.error("Error sending new order notifications:", error);
        }
    });

// 2. Notify Customer when order status changes
exports.onOrderStatusChanged = functions.firestore
    .document("orders/{orderId}")
    .onUpdate(async (change, context) => {
        const before = change.before.data();
        const after = change.after.data();

        // Only run if status changed
        if (before.status === after.status) return null;

        const customerId = after.customerId;
        const newStatus = after.status;
        const orderId = context.params.orderId;

        // Get mapped message
        let title = "Order Update";
        let body = `Your order status has changed to ${newStatus}.`;

        switch (newStatus) {
            case "accepted":
                title = "Order Accepted ✅";
                body = "The restaurant has accepted your order and is preparing it.";
                break;
            case "preparing":
                title = "Preparing your food 🍳";
                body = "Your delicious food is being prepared right now!";
                break;
            case "ready":
                title = "Order Ready 🥡";
                body = "Your order is ready for pickup or delivery.";
                break;
            case "pickedUp":
                title = "Order Picked Up 🛵";
                body = "The driver has picked up your order and is on the way.";
                break;
            case "delivered":
                title = "Order Delivered 🎉";
                body = "Enjoy your meal! Your order has been delivered.";
                break;
            case "cancelled":
                title = "Order Cancelled ❌";
                body = "We're sorry, your order has been cancelled.";
                break;
        }

        try {
            // Get User's FCM Token from Firestore
            const userSnap = await admin.firestore().collection("users").doc(customerId).get();
            if (!userSnap.exists) {
                console.log(`User ${customerId} not found`);
                return null;
            }

            const userData = userSnap.data();
            const fcmToken = userData.fcmToken;

            if (!fcmToken) {
                console.log(`No FCM token for user ${customerId}`);
                return null;
            }

            const message = {
                notification: {
                    title: title,
                    body: body,
                },
                token: fcmToken,
                data: {
                    orderId: orderId,
                    status: newStatus,
                    type: "order_update",
                    click_action: "FLUTTER_NOTIFICATION_CLICK",
                },
            };

            await admin.messaging().send(message);
            console.log(`Status update notification sent to customer ${customerId}`);
        } catch (error) {
            console.error("Error sending status notification:", error);
        }
    });
