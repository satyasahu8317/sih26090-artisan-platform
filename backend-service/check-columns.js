import { PrismaClient } from '@prisma/client';
const prisma = new PrismaClient();

async function main() {
  const result = await prisma.$queryRaw`SELECT column_name FROM information_schema.columns WHERE table_name = 'Product'`;
  console.log('Product table columns in Neon DB:');
  console.log(result.map(r => r.column_name).join(', '));
}

main().finally(() => prisma.$disconnect());
