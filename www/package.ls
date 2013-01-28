author:
  name: ['Victor Hsieh']
  email: 'victor@csie.org'
name: 'twlaw-www'
description: 'Endpoint of twlaw'
version: '0.0.1'
repository:
  type: 'git'
  url: 'git://github.com/g0v/twlaw.git'
scripts:
  prepublish: """
    ./node_modules/.bin/lsc -cj package.ls
    ./node_modules/.bin/lsc -cb app.ls
  """
main: 'lib/app.js'
engines:
  node: '0.8.x'
  npm: '1.1.x'
dependencies: {}
devDependencies:
  LiveScript: \1.1.x
  mongodb: \1.2.x
  express: \3.1.x
  'node-markdown': \0.1.x
optionalDependencies: {}
