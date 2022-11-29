declare const fs: {
    readFileSync: (path: string, opts?: {}) => string;
    readdirSync: (path: string, opts?: {}) => string[] | import("./global").DirEnt[];
    writeFileSync: (path: string, content: string, opts?: {}) => any;
};
export default fs;
