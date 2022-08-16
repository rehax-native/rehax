interface DirEnt {}

export interface RehaxFs {
  readFileSync(path: string): string;
  readdirSync(path: string): string[] | DirEnt[];
}

declare global {
  export const rehax = {
    fs: RehaxFs,
  };
}

export {};
