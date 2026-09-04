import { test, describe, before, after } from "node:test";
import assert from "node:assert/strict";
import app from "../src/app.js";
import prisma from "../src/config/db.js";
import jwt from "jsonwebtoken";

describe("Product API", () => {
  let server;
  let port;
  let artisanToken;
  let buyerToken;
  let artisanUserId;
  let buyerUserId;
  let artisanProfileId;

  const TEST_PHONE_ARTISAN = "+19998887777";
  const TEST_PHONE_BUYER = "+19998886666";

  before(async () => {
    server = app.listen(0);
    port = server.address().port;

    // Clean up any previous test runs just in case
    await prisma.product.deleteMany({
      where: { artisan: { user: { mobileNumber: TEST_PHONE_ARTISAN } } }
    });
    await prisma.artisanProfile.deleteMany({
      where: { user: { mobileNumber: TEST_PHONE_ARTISAN } }
    });
    await prisma.buyerProfile.deleteMany({
      where: { user: { mobileNumber: TEST_PHONE_BUYER } }
    });
    await prisma.user.deleteMany({
      where: { mobileNumber: { in: [TEST_PHONE_ARTISAN, TEST_PHONE_BUYER] } }
    });

    // Create Test Artisan
    const artisanUser = await prisma.user.create({
      data: {
        mobileNumber: TEST_PHONE_ARTISAN,
        role: "ARTISAN",
        status: "ACTIVE",
        artisanProfile: {
          create: {
            name: "Test Artisan",
            craftType: "Woodwork",
            state: "Test State",
            district: "Test District",
            preferredLanguage: "en"
          }
        }
      },
      include: { artisanProfile: true }
    });
    artisanUserId = artisanUser.id;
    artisanProfileId = artisanUser.artisanProfile.id;
    artisanToken = jwt.sign({ id: artisanUserId }, process.env.JWT_SECRET || 'super_secret_jwt_key_for_dev_only');

    // Create Test Buyer
    const buyerUser = await prisma.user.create({
      data: {
        mobileNumber: TEST_PHONE_BUYER,
        role: "BUYER",
        status: "ACTIVE",
        buyerProfile: {
          create: {
            name: "Test Buyer",
            businessName: "Test Business",
            businessType: "Retail",
            state: "Test State",
            district: "Test District"
          }
        }
      }
    });
    buyerUserId = buyerUser.id;
    buyerToken = jwt.sign({ id: buyerUserId }, process.env.JWT_SECRET || 'super_secret_jwt_key_for_dev_only');
  });

  after(async () => {
    server.close();
    
    // Cleanup
    await prisma.product.deleteMany({
      where: { artisanId: artisanProfileId }
    });
    await prisma.artisanProfile.deleteMany({
      where: { userId: artisanUserId }
    });
    await prisma.buyerProfile.deleteMany({
      where: { userId: buyerUserId }
    });
    await prisma.user.deleteMany({
      where: { id: { in: [artisanUserId, buyerUserId] } }
    });
  });

  test("1. Authenticated artisan can create product", async () => {
    const res = await fetch(`http://localhost:${port}/api/v1/products`, {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${artisanToken}`,
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        productName: { en: "Carved Box", hi: "बॉक्स" },
        category: "Wood Craft",
        description: { en: "Nice box", hi: "अच्छा बॉक्स" },
        tags: ["wood"],
        imageUrl: "http://example.com/box.jpg",
        status: "PUBLISHED"
      })
    });
    const body = await res.json();
    assert.equal(res.status, 201);
    assert.equal(body.success, true);
    assert.equal(body.data.category, "Wood Craft");
    // 2. Product is associated with correct ArtisanProfile
    assert.equal(body.data.artisanId, artisanProfileId);
  });

  test("3. artisanId cannot be supplied by the client to hijack", async () => {
    const res = await fetch(`http://localhost:${port}/api/v1/products`, {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${artisanToken}`,
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        productName: { en: "Carved Box", hi: "बॉक्स" },
        category: "Wood Craft",
        description: { en: "Nice box", hi: "अच्छा बॉक्स" },
        artisanId: "fake-uuid-1234" // Attempt to inject
      })
    });
    const body = await res.json();
    assert.equal(res.status, 201);
    // Should completely ignore the fake-uuid and use the authenticated profile id
    assert.equal(body.data.artisanId, artisanProfileId);
  });

  test("4. Non-artisan cannot create an artisan product", async () => {
    const res = await fetch(`http://localhost:${port}/api/v1/products`, {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${buyerToken}`,
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        productName: { en: "Buyer Box", hi: "बॉक्स" },
        category: "Metal",
        description: { en: "Buyer Box", hi: "बॉक्स" }
      })
    });
    await res.text(); // Consume body
    assert.equal(res.status, 403);
  });

  test("5. Invalid request body is rejected", async () => {
    const res = await fetch(`http://localhost:${port}/api/v1/products`, {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${artisanToken}`,
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        category: "Missing required fields"
      })
    });
    await res.text(); // Consume body
    assert.equal(res.status, 400);
  });

  test("6. Default status is DRAFT when status is omitted", async () => {
    const res = await fetch(`http://localhost:${port}/api/v1/products`, {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${artisanToken}`,
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        productName: { en: "Draft Box", hi: "बॉक्स" },
        category: "Wood Craft",
        description: { en: "Draft box", hi: "बॉक्स" }
      })
    });
    const body = await res.json();
    assert.equal(res.status, 201);
    assert.equal(body.data.status, "DRAFT");
  });

  test("7. Created product appears in GET /my", async () => {
    const res = await fetch(`http://localhost:${port}/api/v1/products/my`, {
      headers: {
        "Authorization": `Bearer ${artisanToken}`
      }
    });
    const body = await res.json();
    assert.equal(res.status, 200);
    assert.equal(body.success, true);
    // There should be 3 products created from previous tests
    assert.ok(body.data.length >= 3);
    assert.equal(body.data[0].artisanId, artisanProfileId);
  });
});
