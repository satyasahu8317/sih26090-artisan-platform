import { test, describe, before, after, afterEach } from "node:test";
import assert from "node:assert/strict";
import app from "../src/app.js";
import prisma from "../src/config/db.js";

describe("MSG91 Auth Endpoint API", () => {
  let server;
  let port;

  const TEST_PHONE = "+19998889999";
  const TEST_NEW_PHONE = "+19998880000";

  before(async () => {
    server = app.listen(0);
    port = server.address().port;

    await prisma.user.deleteMany({
      where: { mobileNumber: { in: [TEST_PHONE, TEST_NEW_PHONE] } }
    });

    await prisma.user.create({
      data: {
        mobileNumber: TEST_PHONE,
        role: "BUYER",
        status: "ACTIVE",
      }
    });
  });

  after(async () => {
    server.close();
    await prisma.user.deleteMany({
      where: { mobileNumber: { in: [TEST_PHONE, TEST_NEW_PHONE] } }
    });
  });

  const originalFetch = global.fetch;
  const originalEnv = process.env.MSG91_AUTHKEY;

  afterEach(() => {
    global.fetch = originalFetch;
    process.env.MSG91_AUTHKEY = originalEnv;
  });

  test("1. Missing accessToken -> 401", async () => {
    const res = await originalFetch(`http://localhost:${port}/api/auth/msg91/verify`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ role: "BUYER" })
    });
    assert.equal(res.status, 401);
  });

  test("2. Invalid MSG91 access token -> 401", async () => {
    process.env.MSG91_AUTHKEY = 'test_authkey';
    global.fetch = async (url, options) => ({
      ok: true,
      json: async () => ({ type: 'error', message: 'Invalid token' }),
    });

    const res = await originalFetch(`http://localhost:${port}/api/auth/msg91/verify`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ accessToken: "invalid-token" })
    });
    assert.equal(res.status, 401);
  });

  test("3. MSG91 verification failure -> safe error", async () => {
    process.env.MSG91_AUTHKEY = 'test_authkey';
    global.fetch = async (url, options) => { throw new Error("fetch failed"); };

    const res = await originalFetch(`http://localhost:${port}/api/auth/msg91/verify`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ accessToken: "token" })
    });
    const data = await res.json();
    assert.equal(res.status, 401); 
    assert.ok(!data.message.includes('test_authkey'));
  });

  test("4, 5, 7, 8, 9, 10. Valid MSG91 token -> Existing user -> application JWT returned", async () => {
    process.env.MSG91_AUTHKEY = 'SECRET_AUTHKEY_123';
    global.fetch = async (url, options) => ({
      ok: true,
      json: async () => ({ type: 'success', messageData: { mobile: TEST_PHONE.replace('+', '') } }),
    });

    const res = await originalFetch(`http://localhost:${port}/api/auth/msg91/verify`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ accessToken: "valid-token", role: "ARTISAN" }) 
    });
    
    const body = await res.json();
    assert.equal(res.status, 200);
    assert.ok(body.token); 
    assert.equal(body.redirect, '/buyer/home'); 
    assert.equal(body.isNewUser, false);
    assert.ok(!JSON.stringify(body).includes('SECRET_AUTHKEY'));
  });

  test("6. Valid MSG91 token -> New user -> correct existing pending behavior", async () => {
    process.env.MSG91_AUTHKEY = 'test_authkey';
    global.fetch = async (url, options) => ({
      ok: true,
      json: async () => ({ type: 'success', messageData: { mobile: TEST_NEW_PHONE.replace('+', '') } }),
    });

    const res = await originalFetch(`http://localhost:${port}/api/auth/msg91/verify`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ accessToken: "valid-token", role: "ARTISAN" }) 
    });
    
    const body = await res.json();
    assert.equal(res.status, 200);
    assert.ok(body.token);
    assert.equal(body.redirect, '/artisan/register'); 
    assert.equal(body.isNewUser, true);
  });
});
