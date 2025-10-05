import { onCall } from "firebase-functions/v2/https";
export const run_unit_tests = onCall(async () => ({ ok: true }));
export const deploy_preview = onCall(async () => ({ ok: true }));
export const run_smoke_tests = onCall(async () => ({ ok: true }));
export const promote_to_prod = onCall(async () => ({ ok: true }));
