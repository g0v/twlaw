author:
  name: ['Victor Hsieh']
  email: 'victor@csie.org'
name: 'twlaw'
description: 'Programming law'
version: '0.0.1'
repository:
  type: 'git'
  url: 'git://github.com/g0v/twlaw.git'
scripts:
  prepublish: """
    ./node_modules/.bin/lsc -cj package.ls
    ./node_modules/.bin/lsc -cbo lib src
  """
main: 'lib/law2jit.js'
engines:
  node: '0.8.x'
  npm: '1.1.x'
dependencies: {}
devDependencies:
  LiveScript: \1.1.x
  optimist: \0.3.x
  mkdirp: \0.3.x
optionalDependencies: {}
