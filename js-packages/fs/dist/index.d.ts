declare const fs: {
    readFileSync: (path: string, opts?: {}) => any;
    readdirSync: (path: string, opts?: {}) => any;
};
export default fs;
