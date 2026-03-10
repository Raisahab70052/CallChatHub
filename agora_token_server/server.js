const express = require('express');
const cors = require('cors');
const admin = require('firebase-admin');
require('dotenv').config();

const { RtcTokenBuilder, RtcRole } = require('agora-token');

const app = express();
app.use(cors());
app.use(express.json());

app.get('/health', (_req, res) => {
  res.json({ ok: true });
});

const APP_ID = process.env.AGORA_APP_ID;
const APP_CERTIFICATE = process.env.AGORA_APP_CERTIFICATE;
const EXPIRE_SECONDS = parseInt(process.env.TOKEN_EXPIRE_SECONDS || '3600', 10);
const SERVICE_ACCOUNT_PATH = process.env.FIREBASE_SERVICE_ACCOUNT || './firebase-service-account.json';

if (!APP_ID || !APP_CERTIFICATE) {
  console.error('Missing AGORA_APP_ID or AGORA_APP_CERTIFICATE in .env');
  process.exit(1);
}

// Initialise Firebase Admin SDK for sending FCM notifications.
try {
  const serviceAccount = require(SERVICE_ACCOUNT_PATH);
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });
  console.log('Firebase Admin initialised.');
} catch (err) {
  console.error(
    `[Firebase Admin] Could not load service account from "${SERVICE_ACCOUNT_PATH}".`,
    '\nDownload it from Firebase Console → Project Settings → Service accounts → Generate new private key.',
    '\nFCM notifications will NOT work until this is fixed.'
  );
}

app.get('/rtc-token', (req, res) => {
  const channelName = req.query.channelName;
  const uid = parseInt(req.query.uid || '0', 10);

  if (!channelName) {
    return res.status(400).json({ error: 'channelName is required' });
  }

  const currentTimestamp = Math.floor(Date.now() / 1000);
  const privilegeExpiredTs = currentTimestamp + EXPIRE_SECONDS;

  const token = RtcTokenBuilder.buildTokenWithUid(
    APP_ID,
    APP_CERTIFICATE,
    channelName,
    uid,
    RtcRole.PUBLISHER,
    privilegeExpiredTs,
  );

  return res.json({
    appId: APP_ID,
    channelName,
    uid,
    token,
    expiresIn: EXPIRE_SECONDS,
    expiresAt: privilegeExpiredTs,
  });
});

// ── Send incoming-call push notification via FCM ──────────────────────────────
app.post('/send-call-notification', async (req, res) => {
  const { toFcmToken, callerName, callerEmail, callerId, channelId } = req.body;

  if (!toFcmToken || !channelId) {
    return res.status(400).json({ error: 'toFcmToken and channelId are required' });
  }

  try {
    await admin.messaging().send({
      token: toFcmToken,
      notification: {
        title: `\uD83D\uDCDE Incoming call from ${callerName || 'Unknown'}`,
        body: 'Tap to answer',
      },
      data: {
        type: 'incoming_call',
        callerName: callerName || 'Unknown',
        callerEmail: callerEmail || '',
        callerId: callerId || '',
        channelId,
      },
      android: {
        priority: 'high',
        notification: {
          priority: 'max',
          defaultSound: true,
          defaultVibrateTimings: true,
        },
      },
    });
    return res.json({ success: true });
  } catch (err) {
    console.error('[FCM] send error:', err.message);
    return res.status(500).json({ error: err.message });
  }
});

const port = parseInt(process.env.PORT || '4000', 10);
const host = process.env.HOST || '0.0.0.0';
app.listen(port, host, () => {
  console.log(`Agora token server running on http://${host}:${port}`);
  console.log(`RTC token endpoint: http://localhost:${port}/rtc-token`);
});
