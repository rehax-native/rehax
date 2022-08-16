const fs = {
  readFileSync: (path: string, opts?: {}) => rehax.fs.readFileSync(path, opts),
  readdirSync: (path: string, opts?: {}) => rehax.fs.readdirSync(path, opts),
};

export default fs;
