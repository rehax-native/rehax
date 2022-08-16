const extractComments = require('extract-comments');
const fs = require('fs');
const path = require('path');

function generate() {
  const contents = fs.readFileSync('./rehax-solid-js-renderer.js', 'utf8');
  const parsed = extractComments(contents)

  let docs = {
    view: {
      jsName: '<any>',
      nativeName: 'View',
      methods: [],
    }
  }

  for (const comment of parsed) {
    if (comment.value.startsWith('>')) {
      const content = comment.value.substring(1)
      if (content.split(':')[0].trim() === 'view') {
        const parts = content.split(':')[1].split('->')
        const [from, to] = parts.map(t => t.trim())
        if (!docs[from]) {
          docs[from] = {
            jsName: from,
            nativeName: to,
            methods: []
          }
        }
      } else if (content.split('prop:')[0].trim().toLowerCase()) {
        const viewName = content.split('prop:')[0].trim()
        const parts = content.split('prop:')[1].split('\n')[0].split('->')
        const [from, to] = parts.map(t => t.trim())
        const lines = content.split('prop:')[1].split('\n')
        let description = null
        if (lines.length > 0) {
          description = lines.slice(1).map(line => line.trim()).join('\n\n').trim()
        }
        docs[viewName].methods.push({
          jsName: from,
          nativeName: to,
          description,
        })
      }
    }
  }

  let markdown = ''

  for (const viewName of Object.keys(docs)) {
    const doc = docs[viewName]
    markdown += `# Element \`${doc.jsName}\`\n\nNative view name: ${doc.nativeName}\n\n`
    if (doc.methods.length > 0) {
      markdown += `## Properties\n\n`
    }
    doc.methods.forEach(method => {
      if (method.nativeName) {
        markdown += `### \`${method.jsName}\` -> \`${method.nativeName}\`\n\n`
      } else {
        markdown += `### \`${method.jsName}\`\n\n`
      }
      if (method.description) {
        markdown += `\n\n${method.description}\n\n`
      }
    });
    // ${doc.description}
    // ${doc.methods.map(method => `- ${method.nativeName}`).join('\n')}
  }

  fs.writeFileSync(path.join(__dirname, 'docs.json'), JSON.stringify(docs, null, 2), 'utf8')
  fs.writeFileSync(path.join(__dirname, 'docs.md'), markdown, 'utf8')
}

generate()