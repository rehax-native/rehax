const fs = {
    readFileSync: (path, opts) => rehax.fs.readFileSync(path),
    readdirSync: (path, opts) => rehax.fs.readdirSync(path),
    writeFileSync: (path, content, opts) => rehax.fs.writeFileSync(path, content),
};
export default fs;
