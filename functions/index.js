const admin = require("firebase-admin");
const {onDocumentCreated} = require("firebase-functions/v2/firestore");
const {onSchedule} = require("firebase-functions/v2/scheduler");

admin.initializeApp();

const db = admin.firestore();
const messaging = admin.messaging();

/**
 * Send credit alert notification when transaction is queued
 */
exports.sendCreditAlert = onDocumentCreated(
    "notification_queue/{notificationId}",
    async (event) => {
      const snap = event.data;
      if (!snap) return;

      const notification = snap.data();

      if (notification.type !== "credit_alert" || notification.processed) {
        return;
      }

      try {
        const message = {
          notification: {
            title: notification.title,
            body: notification.body,
          },
          data: notification.data || {},
          token: notification.recipientToken,
          android: {
            priority: "high",
            notification: {
              sound: "default",
              color: "#ED1B2E",
              channelId: "onebank_channel",
            },
          },
          apns: {
            payload: {
              aps: {
                sound: "default",
                badge: 1,
              },
            },
          },
        };

        await messaging.send(message);

        await snap.ref.update({
          processed: true,
          sentAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        console.log("✅ Credit alert sent to:", notification.recipientUserId);
      } catch (error) {
        console.error("❌ Error sending credit alert:", error);
        await snap.ref.update({
          processed: true,
          error: error.message,
        });
      }
    },
);

/**
 * Send weekly insights to all users every Sunday at 8 PM
 */
exports.sendWeeklyInsights = onSchedule(
    {
      schedule: "0 20 * * 0",
      timeZone: "Africa/Lagos",
    },
    async () => {
      console.log("🔔 Starting weekly insights job...");

      try {
        const usersSnapshot = await db.collection("users").get();
        const fcmTokensSnapshot = await db.collection("fcm_tokens").get();

        console.log(`📊 Found ${usersSnapshot.size} users`);
        console.log(`🔑 Found ${fcmTokensSnapshot.size} FCM tokens`);

        const tokenMap = {};
        fcmTokensSnapshot.forEach((doc) => {
          const data = doc.data();
          tokenMap[data.userId] = data.token;
        });

        const promises = [];

        for (const userDoc of usersSnapshot.docs) {
          const userId = userDoc.id;
          const userData = userDoc.data();
          const token = tokenMap[userId];

          if (!token) {
            console.log(`⚠️ No FCM token for user: ${userId}`);
            continue;
          }

          const insights = await calculateWeeklyInsights(userId, userData);

          if (insights) {
            promises.push(
                sendInsightNotification(token, insights, userId),
            );
          }
        }

        await Promise.all(promises);
        console.log(`✅ Sent ${promises.length} weekly insight notifications`);
      } catch (error) {
        console.error("❌ Error in weekly insights job:", error);
      }
    },
);

/**
 * Calculate weekly insights for a user
 * @param {string} userId - User ID
 * @param {object} userData - User document data
 * @return {Promise<object|null>} Weekly insights or null
 */
async function calculateWeeklyInsights(userId, userData) {
  const now = new Date();
  const weekAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);

  try {
    // Query using ISO string format (matching your Dart code)
    const transactionsSnapshot = await db
        .collection("transactions")
        .where("userId", "==", userId)
        .where("timestamp", ">=", weekAgo.toISOString())
        .where("timestamp", "<=", now.toISOString())
        .orderBy("timestamp", "desc")
        .get();

    console.log(
        `📈 User ${userId}: ${transactionsSnapshot.size} transactions`,
    );

    if (transactionsSnapshot.empty) return null;

    const transactions = transactionsSnapshot.docs.map((doc) => doc.data());

    const expenses = transactions.filter((t) => !t.isCredit);
    const income = transactions.filter((t) => t.isCredit);

    const totalExpenses = expenses.reduce((sum, t) => sum + t.amount, 0);
    const totalIncome = income.reduce((sum, t) => sum + t.amount, 0);

    const recipientCounts = {};
    expenses.forEach((t) => {
      const name = t.recipientName || "Unknown";
      recipientCounts[name] = (recipientCounts[name] || 0) + 1;
    });

    const topRecipient = Object.entries(recipientCounts).sort(
        (a, b) => b[1] - a[1],
    )[0];

    const dayTotals = {};
    const days = [
      "Sunday",
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday",
    ];

    expenses.forEach((t) => {
      const date = new Date(t.timestamp);
      const day = date.getDay();
      const dayName = days[day];
      dayTotals[dayName] = (dayTotals[dayName] || 0) + t.amount;
    });

    const mostSpentDay = Object.entries(dayTotals).sort(
        (a, b) => b[1] - a[1],
    )[0];

    const firstName = userData.fullName.split(" ")[0];
    let message = "";

    if (totalExpenses > 100000) {
      message =
        `${firstName}, you spent ₦${formatAmount(totalExpenses)} ` +
        "this week! That's quite high.";
    } else if (totalExpenses > 50000) {
      message =
        `${firstName}, you spent ₦${formatAmount(totalExpenses)} ` +
        "this week. Keep tracking your finances!";
    } else if (totalExpenses > 0 && totalExpenses < 20000) {
      message =
        `${firstName}, great job! You only spent ₦${formatAmount(
            totalExpenses,
        )} this week.`;
    } else if (totalExpenses === 0) {
      message =
        `${firstName}, you had no expenses this week. ` +
        "Perfect saving week!";
    } else {
      // Default message for amounts between 20k-50k
      message =
        `${firstName}, you spent ₦${formatAmount(totalExpenses)} ` +
        "this week.";
    }

    if (topRecipient && topRecipient[1] > 2) {
      message +=
        ` You sent money to ${topRecipient[0]} ` +
        `${topRecipient[1]} times.`;
    }

    if (mostSpentDay && totalExpenses > 0) {
      message +=
        ` ${mostSpentDay[0]} was your highest ` +
        "spending day.";
    }

    return {
      message,
      totalExpenses,
      totalIncome,
      transactionCount: transactions.length,
    };
  } catch (error) {
    console.error(`❌ Error calculating insights for ${userId}:`, error);
    return null;
  }
}

/**
 * Send insight notification to a user
 * @param {string} token - FCM token
 * @param {object} insights - Insight payload
 * @param {string} userId - User ID
 * @return {Promise<void>}
 */
async function sendInsightNotification(token, insights, userId) {
  try {
    const message = {
      notification: {
        title: "📊 Your Weekly Financial Insights",
        body: insights.message,
      },
      data: {
        type: "weekly_insights",
        totalExpenses: insights.totalExpenses.toString(),
        totalIncome: insights.totalIncome.toString(),
        transactionCount: insights.transactionCount.toString(),
      },
      token,
      android: {
        priority: "high",
        notification: {
          sound: "default",
          color: "#ED1B2E",
          channelId: "onebank_channel",
        },
      },
      apns: {
        payload: {
          aps: {
            sound: "default",
            badge: 1,
          },
        },
      },
    };

    await messaging.send(message);
    console.log(`✅ Weekly insight sent to ${userId}`);
  } catch (error) {
    console.error(`❌ Error sending insight to ${userId}:`, error);
  }
}

/**
 * Format amount with thousand separators
 * @param {number} amount - Amount in naira
 * @return {string} Formatted amount
 */
function formatAmount(amount) {
  return amount.toLocaleString("en-NG", {
    minimumFractionDigits: 0,
    maximumFractionDigits: 0,
  });
}
