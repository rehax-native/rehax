const fs = {
    readFileSync: (path, opts) => rehax.fs.readFileSync(path, opts),
    readdirSync: (path, opts) => rehax.fs.readdirSync(path, opts),
};
export default fs;
