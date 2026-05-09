/** Minimal typings for `ngeohash` (package has no bundled types). */
declare module "ngeohash" {
  export function encode(latitude: number, longitude: number, precision?: number): string;
}
