"use strict";

const {
  cp,
  rm,
  mkdir,
  exec
} = require('shelljs')
const request = require('request-promise')
const { writeFileSync, readFileSync } = require('fs')
const glob = require('glob')

module.exports = async function createRelease() {
  rm('-rf', 'dist')
  mkdir(['dist', 'dist/pointshop2'])

  const ignoreGlobs = readFileSync('.gmodignore', 'utf-8')
    .split(/[\r\n]+/)
    .filter(Boolean)

  const folders = glob.sync('**/', {
    ignore: ignoreGlobs
  })
  folders.map(x => mkdir('dist/pointshop2/' + x))

  const files = glob.sync('**', {
    ignore: ignoreGlobs,
    nodir: true
  })
  files.map(file => cp(file, 'dist/pointshop2/' + file))

  const pdf = await request({
    url: 'http://media.readthedocs.org/pdf/pointshop2/latest/pointshop2.pdf',
    method: 'GET',
    encoding: null
  })
  writeFileSync('dist/Installation, Guide and Developer.pdf', pdf)
  writeFileSync('dist/Don\'t forget to download PAC3.txt',
    `Please download PAC3 from https://github.com/CapsAdmin/pac3/ and install it as an addon. 
Check Installation, Guide and Developer.pdf for more information.`)

  const version = JSON.parse(readFileSync('package.json')).version
  writeFileSync('dist/pointshop2/lua/autorun/pointshop2_build.lua', `PS2_BUILD = "${version}"`)

  exec('git clone https://github.com/Kamshak/LibK.git dist/libk')
  rm('-rf', 'dist/libk/.git')

  cp('package.json', 'dist')
  cp('.gmodignore', 'dist')
}

if (require.main === module) {
  module.exports()
}
