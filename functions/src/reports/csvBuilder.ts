/**
 * CSV export helpers — RFC-style escaping (quotes, commas, newlines).
 */

export function escapeCsvCell(value: unknown): string {
  if (value == null) {
    return "";
  }
  if (value instanceof Date) {
    return escapeCsvCell(value.toISOString());
  }
  const s = String(value);
  if (/[",\r\n]/.test(s)) {
    return `"${s.replace(/"/g, '""')}"`;
  }
  return s;
}

export function toCsvRow(cells: unknown[]): string {
  return cells.map(escapeCsvCell).join(",") + "\n";
}

export function toCsvDocument(header: string[], rows: unknown[][]): string {
  let out = toCsvRow(header);
  for (const r of rows) {
    out += toCsvRow(r);
  }
  return out;
}

export function formatTimestampForCsv(v: unknown): string {
  if (v == null) {
    return "";
  }
  const maybeTs = v as { toDate?: () => Date };
  if (typeof maybeTs.toDate === "function") {
    const d = maybeTs.toDate();
    return d.toISOString();
  }
  if (v instanceof Date) {
    return v.toISOString();
  }
  return String(v);
}
