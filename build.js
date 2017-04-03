const {
    cp,
    rm,
    mkdir,
    exec
} = require('shelljs')
const request = require('request-promise')
const { writeFileSync } = require('fs')

rm('-rf', 'dist')
mkdir(['dist', 'dist/pointshop2'])
cp('-R', './*', 'dist/')
cp('.gmodignore', 'dist/')

const pdf = await request('http://media.readthedocs.org/pdf/pointshop2/latest/pointshop2.pdf')
console.log(pdf)
writeFileSync('dist/pointshop2/Installation, Guide and Developer.pdf', pdf)