import { test, describe, before, after } from "node:test";
import assert from "node:assert/strict";
import app from "../src/app.js";
import prisma from "../src/config/db.js";
import jwt from "jsonwebtoken";

describe("Enquiry API", () => {
  let server;
  let port;
  let artisanToken;
  let buyerToken;
  let unrelatedBuyerToken;
  let artisanUserId;
  let buyerUserId;
  let unrelatedBuyerUserId;
  let artisanProfileId;
  let buyerProfileId;
  let productId;
  let enquiryId;

  const TEST_PHONE_ARTISAN = "+17778881111";
  const TEST_PHONE_BUYER = "+17778882222";
  const TEST_PHONE_UNRELATED_BUYER = "+17778883333";

  before(async () => {
    server = app.listen(0);
    port = server.address().port;

    // Clean up previous
    await prisma.notification.deleteMany({
      where: { user: { mobileNumber: { in: [TEST_PHONE_ARTISAN, TEST_PHONE_BUYER, TEST_PHONE_UNRELATED_BUYER] } } }
    });
    await prisma.enquiryMessage.deleteMany({
      where: { enquiry: { artisan: { user: { mobileNumber: TEST_PHONE_ARTISAN } } } }
    });
    await prisma.enquiry.deleteMany({
      where: { artisan: { user: { mobileNumber: TEST_PHONE_ARTISAN } } }
    });
    await prisma.product.deleteMany({
      where: { artisan: { user: { mobileNumber: TEST_PHONE_ARTISAN } } }
    });
    await prisma.artisanProfile.deleteMany({
      where: { user: { mobileNumber: TEST_PHONE_ARTISAN } }
    });
    await prisma.buyerProfile.deleteMany({
      where: { user: { mobileNumber: { in: [TEST_PHONE_BUYER, TEST_PHONE_UNRELATED_BUYER] } } }
    });
    await prisma.user.deleteMany({
      where: { mobileNumber: { in: [TEST_PHONE_ARTISAN, TEST_PHONE_BUYER, TEST_PHONE_UNRELATED_BUYER] } }
    });

    // Create Test Artisan
    const artisanUser = await prisma.user.create({
      data: {
        mobileNumber: TEST_PHONE_ARTISAN,
        role: "ARTISAN",
        status: "ACTIVE",
        artisanProfile: {
          create: {
            name: "Enquiry Artisan",
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
            name: "Enquiry Buyer",
            businessName: "Test Business",
            businessType: "Retail",
            state: "Test State",
            district: "Test District"
          }
        }
      },
      include: { buyerProfile: true }
    });
    buyerUserId = buyerUser.id;
    buyerProfileId = buyerUser.buyerProfile.id;
    buyerToken = jwt.sign({ id: buyerUserId }, process.env.JWT_SECRET || 'super_secret_jwt_key_for_dev_only');

    // Create Unrelated Test Buyer
    const unrelatedBuyerUser = await prisma.user.create({
      data: {
        mobileNumber: TEST_PHONE_UNRELATED_BUYER,
        role: "BUYER",
        status: "ACTIVE",
        buyerProfile: {
          create: {
            name: "Unrelated Buyer",
            businessName: "Unrelated Business",
            businessType: "Retail",
            state: "Test State",
            district: "Test District"
          }
        }
      }
    });
    unrelatedBuyerUserId = unrelatedBuyerUser.id;
    unrelatedBuyerToken = jwt.sign({ id: unrelatedBuyerUserId }, process.env.JWT_SECRET || 'super_secret_jwt_key_for_dev_only');

    // Create a product for the artisan
    const product = await prisma.product.create({
      data: {
        artisanId: artisanProfileId,
        productName: { en: "Test Product", hi: "उत्पाद" },
        category: "Test Category",
        description: { en: "Test", hi: "टेस्ट" },
        tags: [],
        status: "PUBLISHED"
      }
    });
    productId = product.id;
  });

  after(async () => {
    server.close();
    await prisma.notification.deleteMany({
      where: { userId: { in: [artisanUserId, buyerUserId, unrelatedBuyerUserId] } }
    });
    await prisma.enquiryMessage.deleteMany({
      where: { enquiry: { artisanId: artisanProfileId } }
    });
    await prisma.enquiry.deleteMany({
      where: { artisanId: artisanProfileId }
    });
    await prisma.product.deleteMany({
      where: { artisanId: artisanProfileId }
    });
    await prisma.artisanProfile.deleteMany({
      where: { id: artisanProfileId }
    });
    await prisma.buyerProfile.deleteMany({
      where: { id: { in: [buyerProfileId] } }
    });
    await prisma.user.deleteMany({
      where: { id: { in: [artisanUserId, buyerUserId, unrelatedBuyerUserId] } }
    });
  });

  test("1. Non-buyer cannot create enquiry", async () => {
    const res = await fetch(`http://localhost:${port}/api/v1/enquiries`, {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${artisanToken}`,
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        artisanId: artisanProfileId,
        message: "Hello"
      })
    });
    await res.text();
    assert.equal(res.status, 403);
  });

  test("2. Buyer can create enquiry and notification is created", async () => {
    const res = await fetch(`http://localhost:${port}/api/v1/enquiries`, {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${buyerToken}`,
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        artisanId: artisanProfileId,
        productId: productId,
        message: "Is this available?",
        buyerId: "fake-id", // should be ignored
        status: "CLOSED" // should be ignored
      })
    });
    const body = await res.json();
    assert.equal(res.status, 201);
    assert.equal(body.success, true);
    assert.equal(body.data.message, "Is this available?");
    assert.equal(body.data.status, "NEW"); // defaults to NEW
    assert.equal(body.data.buyerId, buyerProfileId); // derived from token
    
    enquiryId = body.data.id;

    // Check notification
    const notifs = await prisma.notification.findMany({
      where: { userId: artisanUserId, type: "ENQUIRY" }
    });
    assert.ok(notifs.length > 0);
  });

  test("3. Invalid artisan returns proper error", async () => {
    const res = await fetch(`http://localhost:${port}/api/v1/enquiries`, {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${buyerToken}`,
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        artisanId: "123e4567-e89b-12d3-a456-426614174000",
        message: "Hello"
      })
    });
    await res.text();
    assert.equal(res.status, 404);
  });

  test("4. Invalid product/artisan combination is rejected", async () => {
    // We try to use a valid artisan but a product that doesn't belong to them or doesn't exist
    const res = await fetch(`http://localhost:${port}/api/v1/enquiries`, {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${buyerToken}`,
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        artisanId: artisanProfileId,
        productId: "123e4567-e89b-12d3-a456-426614174000", // Fake product
        message: "Hello"
      })
    });
    await res.text();
    assert.equal(res.status, 404);
  });

  test("5. Buyer can view their own enquiry", async () => {
    const res = await fetch(`http://localhost:${port}/api/v1/enquiries/${enquiryId}`, {
      headers: {
        "Authorization": `Bearer ${buyerToken}`,
      }
    });
    const body = await res.json();
    assert.equal(res.status, 200);
    assert.equal(body.data.id, enquiryId);
  });

  test("6. Artisan can view their enquiry", async () => {
    const res = await fetch(`http://localhost:${port}/api/v1/enquiries/${enquiryId}`, {
      headers: {
        "Authorization": `Bearer ${artisanToken}`,
      }
    });
    const body = await res.json();
    assert.equal(res.status, 200);
    assert.equal(body.data.id, enquiryId);
  });

  test("7. Unrelated buyer gets 403", async () => {
    const res = await fetch(`http://localhost:${port}/api/v1/enquiries/${enquiryId}`, {
      headers: {
        "Authorization": `Bearer ${unrelatedBuyerToken}`,
      }
    });
    await res.text();
    assert.equal(res.status, 403);
  });

  test("8. Buyer cannot update status", async () => {
    const res = await fetch(`http://localhost:${port}/api/v1/enquiries/${enquiryId}`, {
      method: "PATCH",
      headers: {
        "Authorization": `Bearer ${buyerToken}`,
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        status: "READ"
      })
    });
    await res.text();
    assert.equal(res.status, 403);
  });

  test("9. Artisan can update status", async () => {
    const res = await fetch(`http://localhost:${port}/api/v1/enquiries/${enquiryId}`, {
      method: "PATCH",
      headers: {
        "Authorization": `Bearer ${artisanToken}`,
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        status: "RESPONDED"
      })
    });
    const body = await res.json();
    assert.equal(res.status, 200);
    assert.equal(body.data.status, "RESPONDED");
  });

  test("10. Invalid status is rejected", async () => {
    const res = await fetch(`http://localhost:${port}/api/v1/enquiries/${enquiryId}`, {
      method: "PATCH",
      headers: {
        "Authorization": `Bearer ${artisanToken}`,
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        status: "INVALID_STATUS"
      })
    });
    await res.text();
    assert.equal(res.status, 400);
  });

  test("11. Buyer can send a message", async () => {
    const res = await fetch(`http://localhost:${port}/api/v1/enquiries/${enquiryId}/messages`, {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${buyerToken}`,
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        message: "Hello Artisan!"
      })
    });
    const body = await res.json();
    assert.equal(res.status, 201);
    assert.equal(body.data.message, "Hello Artisan!");
    assert.equal(body.data.senderId, buyerUserId); // sender is derived correctly
  });

  test("12. Artisan receives notification for buyer message", async () => {
    const notifs = await prisma.notification.findMany({
      where: { userId: artisanUserId, type: "ENQUIRY" }
    });
    assert.ok(notifs.length >= 2); // 1 for enquiry creation, 1 for message
    assert.equal(notifs[notifs.length - 1].title, "New Enquiry Message");
  });

  test("13. Artisan can send a reply message", async () => {
    const res = await fetch(`http://localhost:${port}/api/v1/enquiries/${enquiryId}/messages`, {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${artisanToken}`,
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        message: "Hello Buyer! Yes we can make 500."
      })
    });
    const body = await res.json();
    assert.equal(res.status, 201);
    assert.equal(body.data.message, "Hello Buyer! Yes we can make 500.");
  });

  test("14. Enquiry status is updated to RESPONDED when artisan replies to NEW enquiry", async () => {
    const enquiry = await prisma.enquiry.findUnique({ where: { id: enquiryId } });
    assert.equal(enquiry.status, "RESPONDED");
  });

  test("15. Buyer receives notification for artisan message", async () => {
    const notifs = await prisma.notification.findMany({
      where: { userId: buyerUserId, type: "ENQUIRY" }
    });
    assert.ok(notifs.length >= 1); 
    assert.equal(notifs[notifs.length - 1].title, "New Enquiry Message");
  });

  test("16. SenderId spoofing is ignored", async () => {
    const res = await fetch(`http://localhost:${port}/api/v1/enquiries/${enquiryId}/messages`, {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${buyerToken}`,
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        message: "Can I get a discount?",
        senderId: artisanUserId // spoof
      })
    });
    const body = await res.json();
    assert.equal(res.status, 201);
    assert.equal(body.data.senderId, buyerUserId); // Should still be buyer
  });

  test("17. Unrelated user cannot read messages", async () => {
    const res = await fetch(`http://localhost:${port}/api/v1/enquiries/${enquiryId}/messages`, {
      headers: {
        "Authorization": `Bearer ${unrelatedBuyerToken}`
      }
    });
    await res.text();
    assert.equal(res.status, 403);
  });

  test("18. Unrelated user cannot send messages", async () => {
    const res = await fetch(`http://localhost:${port}/api/v1/enquiries/${enquiryId}/messages`, {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${unrelatedBuyerToken}`,
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        message: "Hacking!"
      })
    });
    await res.text();
    assert.equal(res.status, 403);
  });

  test("19. Empty message is rejected", async () => {
    const res = await fetch(`http://localhost:${port}/api/v1/enquiries/${enquiryId}/messages`, {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${buyerToken}`,
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        message: ""
      })
    });
    await res.text();
    assert.equal(res.status, 400);
  });

  test("20. Messages returned in chronological order", async () => {
    const res = await fetch(`http://localhost:${port}/api/v1/enquiries/${enquiryId}/messages`, {
      headers: {
        "Authorization": `Bearer ${buyerToken}`
      }
    });
    const body = await res.json();
    assert.equal(res.status, 200);
    assert.equal(body.data.length, 3);
    assert.equal(body.data[0].message, "Hello Artisan!");
    assert.equal(body.data[1].message, "Hello Buyer! Yes we can make 500.");
    assert.equal(body.data[2].message, "Can I get a discount?");
  });
});
