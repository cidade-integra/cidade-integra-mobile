const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { initializeApp } = require("firebase-admin/app");
const { getAuth } = require("firebase-admin/auth");
const { getFirestore, FieldValue } = require("firebase-admin/firestore");

initializeApp();

const db = getFirestore();

// Set admin custom claim — only callable by existing admins
exports.setAdminClaim = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Autenticação obrigatória.");
  }

  const callerClaims = request.auth.token;
  if (!callerClaims.admin) {
    throw new HttpsError("permission-denied", "Apenas admins podem conceder admin.");
  }

  const { uid, admin } = request.data;
  if (!uid || typeof admin !== "boolean") {
    throw new HttpsError("invalid-argument", "uid e admin são obrigatórios.");
  }

  await getAuth().setCustomUserClaims(uid, { admin });
  await db.collection("users").doc(uid).update({ role: admin ? "admin" : "user" });

  await db.collection("audit_logs").add({
    event: "user_role_changed",
    targetUid: uid,
    newRole: admin ? "admin" : "user",
    performedBy: request.auth.uid,
    timestamp: FieldValue.serverTimestamp(),
    ip: request.rawRequest?.ip || "unknown",
  });

  return { success: true };
});

// Log audit event — callable by any authenticated user
exports.logAuditEvent = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Autenticação obrigatória.");
  }

  const { event, payload } = request.data;
  if (!event) {
    throw new HttpsError("invalid-argument", "event é obrigatório.");
  }

  await db.collection("audit_logs").add({
    event,
    payload: payload || {},
    uid: request.auth.uid,
    timestamp: FieldValue.serverTimestamp(),
    ip: request.rawRequest?.ip || "unknown",
  });

  return { success: true };
});
