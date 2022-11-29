const fs = {
  readFileSync: (path: string, opts?: {}) => rehax.fs.readFileSync(path),
  readdirSync: (path: string, opts?: {}) => rehax.fs.readdirSync(path),
  writeFileSync: (path: string, content: string, opts?: {}) =>
    rehax.fs.writeFileSync(path, content),
};

export default fs;
