import prisma from './src/config/db.js';
try {
  await prisma.$queryRawUnsafe('SELECT 1');
  console.log('DB OK - Neon is reachable');
} catch (e) {
  console.error('DB ERROR:', e.message);
} finally {
  await prisma.$disconnect();
}
