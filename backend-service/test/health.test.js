import { test } from "node:test";
import assert from "node:assert/strict";
import app from "../src/app.js";

test("GET /health returns 200 with status ok", async () => {
  const server = app.listen(0);
  const { port } = server.address();

  try {
    const res = await fetch(`http://localhost:${port}/health`);
    const body = await res.json();
    assert.equal(res.status, 200);
    assert.equal(body.status, "ok");
  } finally {
    server.close();
  }
});
