import { test, describe, before, after } from "node:test";
import assert from "node:assert/strict";
import jwt from "jsonwebtoken";
import app from "../src/app.js";
import prisma from "../src/config/db.js";

describe("Database-Backed Guest Authentication API & Role Isolation", () => {
  let server;
  let port;
  const createdUserIds = [];

  before(async () => {
    server = app.listen(0);
    port = server.address().port;
  });

  after(async () => {
    server.close();
    // Cleanup any created guest users & their relations
    if (createdUserIds.length > 0) {
      // Delete products, profiles, then users
      await prisma.product.deleteMany({
        where: { artisan: { userId: { in: createdUserIds } } },
      });
      await prisma.buyerProfile.deleteMany({
        where: { userId: { in: createdUserIds } },
      });
      await prisma.artisanProfile.deleteMany({
        where: { userId: { in: createdUserIds } },
      });
      await prisma.user.deleteMany({
        where: { id: { in: createdUserIds } },
      });
    }
  });

  let buyerToken;
  let buyerUserId;
  let artisanToken;
  let artisanUserId;

  test("1. POST /api/auth/guest BUYER succeeds", async () => {
    const res = await fetch(`http://localhost:${port}/api/auth/guest`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ role: "BUYER" }),
    });
    assert.equal(res.status, 200);
    const data = await res.json();
    assert.equal(data.success, true);
    assert.ok(data.token);
    assert.equal(data.isGuest, true);
    assert.equal(data.role, "BUYER");

    buyerToken = data.token;
    buyerUserId = data.user.id;
    createdUserIds.push(buyerUserId);
  });

  test("2. POST /api/auth/guest ARTISAN succeeds", async () => {
    const res = await fetch(`http://localhost:${port}/api/auth/guest`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ role: "ARTISAN" }),
    });
    assert.equal(res.status, 200);
    const data = await res.json();
    assert.equal(data.success, true);
    assert.ok(data.token);
    assert.equal(data.isGuest, true);
    assert.equal(data.role, "ARTISAN");

    artisanToken = data.token;
    artisanUserId = data.user.id;
    createdUserIds.push(artisanUserId);
  });

  test("3. Invalid role rejected (ADMIN, random) -> 400", async () => {
    const resAdmin = await fetch(`http://localhost:${port}/api/auth/guest`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ role: "ADMIN" }),
    });
    assert.equal(resAdmin.status, 400);

    const resUnknown = await fetch(`http://localhost:${port}/api/auth/guest`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ role: "SUPERUSER" }),
    });
    assert.equal(resUnknown.status, 400);
  });

  test("4. Missing role rejected -> 400", async () => {
    const res = await fetch(`http://localhost:${port}/api/auth/guest`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({}),
    });
    assert.equal(res.status, 400);
  });

  test("5. Guest BUYER creates real User in PostgreSQL", async () => {
    const user = await prisma.user.findUnique({
      where: { id: buyerUserId },
    });
    assert.ok(user);
    assert.equal(user.isGuest, true);
    assert.equal(user.role, "BUYER");
    assert.equal(user.status, "ACTIVE");
    assert.ok(user.mobileNumber.startsWith("guest_"));
  });

  test("6. Guest BUYER creates real BuyerProfile in PostgreSQL", async () => {
    const profile = await prisma.buyerProfile.findUnique({
      where: { userId: buyerUserId },
    });
    assert.ok(profile);
    assert.equal(profile.userId, buyerUserId);
    assert.ok(profile.name);
  });

  test("7. Guest ARTISAN creates real User in PostgreSQL", async () => {
    const user = await prisma.user.findUnique({
      where: { id: artisanUserId },
    });
    assert.ok(user);
    assert.equal(user.isGuest, true);
    assert.equal(user.role, "ARTISAN");
    assert.equal(user.status, "ACTIVE");
    assert.ok(user.mobileNumber.startsWith("guest_"));
  });

  test("8. Guest ARTISAN creates real ArtisanProfile in PostgreSQL", async () => {
    const profile = await prisma.artisanProfile.findUnique({
      where: { userId: artisanUserId },
    });
    assert.ok(profile);
    assert.equal(profile.userId, artisanUserId);
    assert.ok(profile.name);
    assert.ok(profile.craftType);
  });

  test("9. JWT contains correct user identity", () => {
    const decoded = jwt.decode(buyerToken);
    assert.ok(decoded.id || decoded.userId);
    assert.equal(decoded.userId, buyerUserId);
  });

  test("10. JWT contains correct role", () => {
    const decodedBuyer = jwt.decode(buyerToken);
    assert.equal(decodedBuyer.role, "BUYER");

    const decodedArtisan = jwt.decode(artisanToken);
    assert.equal(decodedArtisan.role, "ARTISAN");
  });

  test("11. JWT contains isGuest=true", () => {
    const decoded = jwt.decode(buyerToken);
    assert.equal(decoded.isGuest, true);
  });

  test("12. Guest Buyer cannot access Artisan APIs -> 403 or 404", async () => {
    const res = await fetch(`http://localhost:${port}/api/v1/artisans/me/dashboard`, {
      headers: { Authorization: `Bearer ${buyerToken}` },
    });
    // Artisan dashboard rejects user without artisan profile (404) or role mismatch
    assert.ok(res.status === 403 || res.status === 404);
  });

  test("13. Guest Artisan cannot access Buyer APIs -> 403", async () => {
    const res = await fetch(`http://localhost:${port}/api/v1/buyers/me`, {
      method: "PATCH",
      headers: {
        Authorization: `Bearer ${artisanToken}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ name: "Hacked Buyer" }),
    });
    assert.equal(res.status, 403);
  });

  test("14. Two guest Buyers receive different User IDs", async () => {
    const res2 = await fetch(`http://localhost:${port}/api/auth/guest`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ role: "BUYER" }),
    });
    const data2 = await res2.json();
    createdUserIds.push(data2.user.id);

    assert.notEqual(data2.user.id, buyerUserId);
  });

  test("15. Two guest Artisans receive different User IDs", async () => {
    const res2 = await fetch(`http://localhost:${port}/api/auth/guest`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ role: "ARTISAN" }),
    });
    const data2 = await res2.json();
    createdUserIds.push(data2.user.id);

    assert.notEqual(data2.user.id, artisanUserId);
  });

  test("16. Guest Buyer updates real profile in PostgreSQL via PATCH /api/v1/buyers/me", async () => {
    const res = await fetch(`http://localhost:${port}/api/v1/buyers/me`, {
      method: "PATCH",
      headers: {
        Authorization: `Bearer ${buyerToken}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        name: "Updated Demo Buyer",
        state: "Maharashtra",
      }),
    });
    assert.equal(res.status, 200);

    const profile = await prisma.buyerProfile.findUnique({
      where: { userId: buyerUserId },
    });
    assert.equal(profile.name, "Updated Demo Buyer");
    assert.equal(profile.state, "Maharashtra");
  });

  test("17. Guest Artisan updates real profile in PostgreSQL via PATCH /api/v1/artisans/me", async () => {
    const res = await fetch(`http://localhost:${port}/api/v1/artisans/me`, {
      method: "PATCH",
      headers: {
        Authorization: `Bearer ${artisanToken}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        name: "Updated Master Potter",
        craftType: "Terracotta Pottery",
      }),
    });
    assert.equal(res.status, 200);

    const profile = await prisma.artisanProfile.findUnique({
      where: { userId: artisanUserId },
    });
    assert.equal(profile.name, "Updated Master Potter");
    assert.equal(profile.craftType, "Terracotta Pottery");
  });

  test("18. Guest Artisan ownership check: Artisan B cannot update Artisan A's products", async () => {
    // 1. Create a product as Artisan A
    const resProd = await fetch(`http://localhost:${port}/api/v1/products`, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${artisanToken}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        productName: { en: "Clay Pot", hi: "मिट्टी का बर्तन" },
        category: "Pottery",
        description: { en: "Handmade pot", hi: "हस्तनिर्मित बर्तन" },
      }),
    });
    assert.equal(resProd.status, 201);
    const prodData = await resProd.json();
    const productId = prodData.data.id;

    // 2. Create Artisan B
    const resArtisanB = await fetch(`http://localhost:${port}/api/auth/guest`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ role: "ARTISAN" }),
    });
    const artisanBData = await resArtisanB.json();
    createdUserIds.push(artisanBData.user.id);
    const tokenB = artisanBData.token;

    // 3. Artisan B tries to delete or update Artisan A's product -> must be rejected (403 or 404)
    const resDelete = await fetch(`http://localhost:${port}/api/v1/products/${productId}`, {
      method: "DELETE",
      headers: { Authorization: `Bearer ${tokenB}` },
    });
    assert.ok(resDelete.status === 403 || resDelete.status === 404);
  });
});
