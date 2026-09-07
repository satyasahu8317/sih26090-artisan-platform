import { test, describe, before, after } from "node:test";
import assert from "node:assert/strict";
import app from "../src/app.js";
import prisma from "../src/config/db.js";
import jwt from "jsonwebtoken";

describe("Order API", () => {
  let server;
  let port;
  let buyerToken, artisanToken, unrelatedArtisanToken, unrelatedBuyerToken;
  let buyerUserId, artisanUserId, unrelatedArtisanUserId, unrelatedBuyerUserId;
  let buyerProfileId, artisanProfileId, unrelatedArtisanProfileId, unrelatedBuyerProfileId;
  let productId, unrelatedProductId;

  const generateToken = (id) => jwt.sign({ id }, process.env.JWT_SECRET || 'secret', { expiresIn: '30d' });

  before(async () => {
    server = app.listen(0);
    port = server.address().port;

    const testPhones = ['+9990001111', '+9990002222', '+9990003333', '+9990004444'];
    await prisma.notification.deleteMany({ where: { user: { mobileNumber: { in: testPhones } } } });
    await prisma.order.deleteMany({ where: { buyer: { user: { mobileNumber: { in: testPhones } } } } });
    await prisma.product.deleteMany({ where: { artisan: { user: { mobileNumber: { in: testPhones } } } } });
    await prisma.artisanProfile.deleteMany({ where: { user: { mobileNumber: { in: testPhones } } } });
    await prisma.buyerProfile.deleteMany({ where: { user: { mobileNumber: { in: testPhones } } } });
    await prisma.user.deleteMany({ where: { mobileNumber: { in: testPhones } } });

    // Create 2 artisans and 2 buyers
    const artisanUser = await prisma.user.create({ data: { mobileNumber: '+9990001111', role: 'ARTISAN', status: 'ACTIVE' } });
    artisanUserId = artisanUser.id;
    const artisanProfile = await prisma.artisanProfile.create({ data: { userId: artisanUserId, name: 'Artisan 1', craftType: 'Craft 1', state: 'State', district: 'District', preferredLanguage: 'EN' } });
    artisanProfileId = artisanProfile.id;
    artisanToken = generateToken(artisanUserId);

    const unrelatedArtisanUser = await prisma.user.create({ data: { mobileNumber: '+9990002222', role: 'ARTISAN', status: 'ACTIVE' } });
    unrelatedArtisanUserId = unrelatedArtisanUser.id;
    const unrelatedArtisanProfile = await prisma.artisanProfile.create({ data: { userId: unrelatedArtisanUserId, name: 'Artisan 2', craftType: 'Craft 2', state: 'State', district: 'District', preferredLanguage: 'EN' } });
    unrelatedArtisanProfileId = unrelatedArtisanProfile.id;
    unrelatedArtisanToken = generateToken(unrelatedArtisanUserId);

    const buyerUser = await prisma.user.create({ data: { mobileNumber: '+9990003333', role: 'BUYER', status: 'ACTIVE' } });
    buyerUserId = buyerUser.id;
    const buyerProfile = await prisma.buyerProfile.create({ data: { userId: buyerUserId, name: 'Buyer 1', businessName: 'Biz 1', businessType: 'Type', state: 'State', district: 'District' } });
    buyerProfileId = buyerProfile.id;
    buyerToken = generateToken(buyerUserId);

    const unrelatedBuyerUser = await prisma.user.create({ data: { mobileNumber: '+9990004444', role: 'BUYER', status: 'ACTIVE' } });
    unrelatedBuyerUserId = unrelatedBuyerUser.id;
    const unrelatedBuyerProfile = await prisma.buyerProfile.create({ data: { userId: unrelatedBuyerUserId, name: 'Buyer 2', businessName: 'Biz 2', businessType: 'Type', state: 'State', district: 'District' } });
    unrelatedBuyerProfileId = unrelatedBuyerProfile.id;
    unrelatedBuyerToken = generateToken(unrelatedBuyerUserId);

    // Create Products
    const product = await prisma.product.create({
      data: { artisanId: artisanProfileId, productName: { en: "Product 1" }, category: "Cat 1", description: { en: "Desc 1" } }
    });
    productId = product.id;

    const unrelatedProduct = await prisma.product.create({
      data: { artisanId: unrelatedArtisanProfileId, productName: { en: "Product 2" }, category: "Cat 2", description: { en: "Desc 2" } }
    });
    unrelatedProductId = unrelatedProduct.id;
  });

  after(async () => {
    server.close();
    await prisma.notification.deleteMany({
      where: { userId: { in: [buyerUserId, artisanUserId, unrelatedArtisanUserId, unrelatedBuyerUserId] } }
    });
    await prisma.order.deleteMany({
      where: { artisanId: { in: [artisanProfileId, unrelatedArtisanProfileId] } }
    });
    await prisma.product.deleteMany({
      where: { artisanId: { in: [artisanProfileId, unrelatedArtisanProfileId] } }
    });
    await prisma.artisanProfile.deleteMany({
      where: { id: { in: [artisanProfileId, unrelatedArtisanProfileId] } }
    });
    await prisma.buyerProfile.deleteMany({
      where: { id: { in: [buyerProfileId, unrelatedBuyerProfileId] } }
    });
    await prisma.user.deleteMany({
      where: { id: { in: [artisanUserId, buyerUserId, unrelatedArtisanUserId, unrelatedBuyerUserId] } }
    });
  });

  let createdOrderId;
  let partialOrderId;
  let rejectOrderId;

  test("11, 12. Buyer can create order, spoofing is ignored", async () => {
    const res = await fetch(`http://localhost:${port}/api/v1/orders`, {
      method: "POST",
      headers: { "Content-Type": "application/json", Authorization: `Bearer ${buyerToken}` },
      body: JSON.stringify({
        buyerId: unrelatedBuyerProfileId, // Spoof attempt
        artisanId: artisanProfileId,
        productId: productId,
        requestedQty: 10,
        unitPrice: 50.0,
        status: "COMPLETED" // Spoof attempt
      })
    });
    const body = await res.json();
    assert.equal(res.status, 201);
    assert.equal(body.buyerId, buyerProfileId);
    assert.equal(body.status, "PENDING");
    assert.equal(body.requestedQty, 10);
    createdOrderId = body.id;
  });

  test("13. Non-buyer cannot create order", async () => {
    const res = await fetch(`http://localhost:${port}/api/v1/orders`, {
      method: "POST",
      headers: { "Content-Type": "application/json", Authorization: `Bearer ${artisanToken}` },
      body: JSON.stringify({ artisanId: artisanProfileId, requestedQty: 10 })
    });
    assert.equal(res.status, 403);
  });

  test("14. Invalid artisan rejected", async () => {
    const res = await fetch(`http://localhost:${port}/api/v1/orders`, {
      method: "POST",
      headers: { "Content-Type": "application/json", Authorization: `Bearer ${buyerToken}` },
      body: JSON.stringify({ artisanId: "00000000-0000-0000-0000-000000000000", requestedQty: 10 })
    });
    assert.equal(res.status, 404);
  });

  test("15. Invalid product rejected", async () => {
    const res = await fetch(`http://localhost:${port}/api/v1/orders`, {
      method: "POST",
      headers: { "Content-Type": "application/json", Authorization: `Bearer ${buyerToken}` },
      body: JSON.stringify({ artisanId: artisanProfileId, productId: "00000000-0000-0000-0000-000000000000", requestedQty: 10 })
    });
    assert.equal(res.status, 404);
  });

  test("16. Product belonging to another artisan rejected", async () => {
    const res = await fetch(`http://localhost:${port}/api/v1/orders`, {
      method: "POST",
      headers: { "Content-Type": "application/json", Authorization: `Bearer ${buyerToken}` },
      body: JSON.stringify({ artisanId: artisanProfileId, productId: unrelatedProductId, requestedQty: 10 })
    });
    assert.equal(res.status, 400);
  });

  test("17. requestedQty <= 0 rejected", async () => {
    const res = await fetch(`http://localhost:${port}/api/v1/orders`, {
      method: "POST",
      headers: { "Content-Type": "application/json", Authorization: `Bearer ${buyerToken}` },
      body: JSON.stringify({ artisanId: artisanProfileId, requestedQty: -5 })
    });
    assert.equal(res.status, 400);
  });

  test("18. New order always PENDING (already tested in 11)", async () => {
    assert.ok(true);
  });

  test("19. Artisan sees only own orders", async () => {
    const res = await fetch(`http://localhost:${port}/api/v1/artisans/orders`, {
      headers: { Authorization: `Bearer ${artisanToken}` }
    });
    const body = await res.json();
    assert.equal(res.status, 200);
    assert.equal(body.data.length, 1);
    assert.equal(body.data[0].id, createdOrderId);
    assert.ok(body.data[0].buyer);
  });

  test("20. Unrelated artisan cannot access order", async () => {
    const res = await fetch(`http://localhost:${port}/api/v1/orders/${createdOrderId}`, {
      headers: { Authorization: `Bearer ${unrelatedArtisanToken}` }
    });
    assert.equal(res.status, 403);
  });

  test("21. Buyer can access own order", async () => {
    const res = await fetch(`http://localhost:${port}/api/v1/orders/${createdOrderId}`, {
      headers: { Authorization: `Bearer ${buyerToken}` }
    });
    const body = await res.json();
    assert.equal(res.status, 200);
    assert.equal(body.id, createdOrderId);
    assert.ok(body.product);
    assert.ok(body.artisan);
  });

  test("22. Unrelated buyer cannot access order", async () => {
    const res = await fetch(`http://localhost:${port}/api/v1/orders/${createdOrderId}`, {
      headers: { Authorization: `Bearer ${unrelatedBuyerToken}` }
    });
    assert.equal(res.status, 403);
  });

  test("23, 24. Artisan can accept pending order, sets acceptedQty", async () => {
    const res = await fetch(`http://localhost:${port}/api/v1/orders/${createdOrderId}/accept`, {
      method: "PATCH",
      headers: { Authorization: `Bearer ${artisanToken}` }
    });
    const body = await res.json();
    assert.equal(res.status, 200);
    assert.equal(body.status, "ACCEPTED");
    assert.equal(body.acceptedQty, 10);
    assert.equal(body.totalAmount, 500); // 10 * 50.0
  });

  test("Setup partial/reject orders", async () => {
    const res1 = await fetch(`http://localhost:${port}/api/v1/orders`, {
      method: "POST",
      headers: { "Content-Type": "application/json", Authorization: `Bearer ${buyerToken}` },
      body: JSON.stringify({ artisanId: artisanProfileId, requestedQty: 100, unitPrice: 20 })
    });
    partialOrderId = (await res1.json()).id;

    const res2 = await fetch(`http://localhost:${port}/api/v1/orders`, {
      method: "POST",
      headers: { "Content-Type": "application/json", Authorization: `Bearer ${buyerToken}` },
      body: JSON.stringify({ artisanId: artisanProfileId, requestedQty: 5 })
    });
    rejectOrderId = (await res2.json()).id;
  });

  test("25. Artisan can partially accept", async () => {
    const res = await fetch(`http://localhost:${port}/api/v1/orders/${partialOrderId}/partial`, {
      method: "PATCH",
      headers: { "Content-Type": "application/json", Authorization: `Bearer ${artisanToken}` },
      body: JSON.stringify({ acceptedQty: 60 })
    });
    const body = await res.json();
    assert.equal(res.status, 200);
    assert.equal(body.status, "PARTIALLY_ACCEPTED");
    assert.equal(body.acceptedQty, 60);
    assert.equal(body.totalAmount, 1200);
  });

  test("26, 27. Partial quantity bounds", async () => {
    const r1 = await fetch(`http://localhost:${port}/api/v1/orders/${partialOrderId}/partial`, { // Already partially accepted anyway
      method: "PATCH",
      headers: { "Content-Type": "application/json", Authorization: `Bearer ${artisanToken}` },
      body: JSON.stringify({ acceptedQty: -1 })
    });
    assert.equal(r1.status, 400);

    // Setup another order to test upper bound
    const rNew = await fetch(`http://localhost:${port}/api/v1/orders`, {
      method: "POST",
      headers: { "Content-Type": "application/json", Authorization: `Bearer ${buyerToken}` },
      body: JSON.stringify({ artisanId: artisanProfileId, requestedQty: 100 })
    });
    const newOrderId = (await rNew.json()).id;

    const r2 = await fetch(`http://localhost:${port}/api/v1/orders/${newOrderId}/partial`, {
      method: "PATCH",
      headers: { "Content-Type": "application/json", Authorization: `Bearer ${artisanToken}` },
      body: JSON.stringify({ acceptedQty: 100 }) // Must be strictly < requestedQty
    });
    assert.equal(r2.status, 400);
  });

  test("28. Artisan can reject pending order", async () => {
    const res = await fetch(`http://localhost:${port}/api/v1/orders/${rejectOrderId}/reject`, {
      method: "PATCH",
      headers: { Authorization: `Bearer ${artisanToken}` }
    });
    const body = await res.json();
    assert.equal(res.status, 200);
    assert.equal(body.status, "REJECTED");
  });

  test("29, 30. Cannot mutate already rejected/accepted orders", async () => {
    const r1 = await fetch(`http://localhost:${port}/api/v1/orders/${rejectOrderId}/accept`, {
      method: "PATCH",
      headers: { Authorization: `Bearer ${artisanToken}` }
    });
    assert.equal(r1.status, 400);

    const r2 = await fetch(`http://localhost:${port}/api/v1/orders/${createdOrderId}/reject`, {
      method: "PATCH",
      headers: { Authorization: `Bearer ${artisanToken}` }
    });
    assert.equal(r2.status, 400);
  });

  test("31. Accepted order can move to FULFILLING", async () => {
    const res = await fetch(`http://localhost:${port}/api/v1/orders/${createdOrderId}/fulfilling`, {
      method: "PATCH",
      headers: { Authorization: `Bearer ${artisanToken}` }
    });
    assert.equal(res.status, 200);
    assert.equal((await res.json()).status, "FULFILLING");
  });

  test("32. Partially accepted order can move to FULFILLING", async () => {
    const res = await fetch(`http://localhost:${port}/api/v1/orders/${partialOrderId}/fulfilling`, {
      method: "PATCH",
      headers: { Authorization: `Bearer ${artisanToken}` }
    });
    assert.equal(res.status, 200);
    assert.equal((await res.json()).status, "FULFILLING");
  });

  test("33. FULFILLING can move to COMPLETED", async () => {
    const res = await fetch(`http://localhost:${port}/api/v1/orders/${createdOrderId}/complete`, {
      method: "PATCH",
      headers: { Authorization: `Bearer ${artisanToken}` }
    });
    assert.equal(res.status, 200);
    assert.equal((await res.json()).status, "COMPLETED");
  });

  test("34. Invalid status transitions rejected", async () => {
    // try to mark COMPLETED as FULFILLING
    const res = await fetch(`http://localhost:${port}/api/v1/orders/${createdOrderId}/fulfilling`, {
      method: "PATCH",
      headers: { Authorization: `Bearer ${artisanToken}` }
    });
    assert.equal(res.status, 400);
  });

  test("35, 36. Buyer receives notifications without secret leakage", async () => {
    const notifs = await prisma.notification.findMany({
      where: { userId: buyerUserId, type: 'ORDER' }
    });
    assert.ok(notifs.length > 0);
    const jsonStr = JSON.stringify(notifs);
    assert.ok(!jsonStr.includes('JWT_SECRET'));
    assert.ok(!jsonStr.includes('MSG91_AUTHKEY'));
  });
});
