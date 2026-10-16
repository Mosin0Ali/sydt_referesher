// A "type alias": a name for a shape of data.
export type Cents = number;

// An interface describes an object's shape. The "?" means optional.
export interface PriceLine {
  skuCode: string;
  unitPriceCents: Cents;
  qty: number;
  discountPct?: number;
}

// Parameter types and the return type are declared, so callers can't pass nonsense.
export function lineTotal(line: PriceLine): Cents {
  const gross = line.unitPriceCents * line.qty;
  const discount = line.discountPct ? Math.round(gross * line.discountPct / 100) : 0;
  return gross - discount;
}

// A union type: the value can only be one of these exact strings.
export type OrderStatus = "pending" | "paid" | "cancelled" | "fulfilled";

export function formatAud(cents: Cents): string {
  return new Intl.NumberFormat("en-AU", { style: "currency", currency: "AUD" }).format(cents / 100);
}