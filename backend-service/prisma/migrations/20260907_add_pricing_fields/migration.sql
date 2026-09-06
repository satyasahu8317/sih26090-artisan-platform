-- AlterTable
ALTER TABLE "Product" ADD COLUMN     "currency" TEXT,
ADD COLUMN     "pricingExplanation" TEXT,
ADD COLUMN     "suggestedPriceMax" DOUBLE PRECISION,
ADD COLUMN     "suggestedPriceMin" DOUBLE PRECISION;

