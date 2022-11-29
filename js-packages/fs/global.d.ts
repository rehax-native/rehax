export interface DirEnt {}

export interface RehaxFs {
  readFileSync(path: string): string;
  readdirSync(path: string): string[] | DirEnt[];
  writeFileSync(path: string, content: string);
}

declare global {
  interface Rehax {
    fs: RehaxFs;
  }
  export const rehax: Rehax;
}

export {};
