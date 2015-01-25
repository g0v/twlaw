#!/usr/bin/env lsc -cj
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
dependencies:
  mkdirp: '^0.5.0'
devDependencies:
  LiveScript: \1.1.x
  optimist: \0.3.x
  walk: \2.2.x
  zhutil: \0.5.x
optionalDependencies: {}
