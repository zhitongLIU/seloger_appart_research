const Nightmare = require('nightmare')

var lineReader = require('readline').createInterface({
  input: require('fs').createReadStream('../in.txt')
});

var i = 1
lineReader.on('line', function (line) {
  if(line.includes('seloger')) {
    if(line.includes('achat') && !line.includes('neuf')) {
      var nightmare = Nightmare({ show: true, height: 1200, width: 1800 })
      console.log(line);
      nightmare
        .wait(i * 5000)
        .goto('https://www.seloger.com')
        .goto(line)
        .wait('#formButton_haut')
        .type('form.form-contact div.fi.fi-person input', "name")
        .type('form.form-contact div.fi.fi-envelope input', 'email')
        .type('form.form-contact div.fi.fi-phone input', 'tel')
        .screenshot("./" + i + ".png")
        .click('#ali-haut')
        .click('#formButton_haut')
        .wait('div.popin-post-contact')
        .end()
        .then(console.log)
        .catch(error => {
          console.error('failed:', error)
        });
      i = i + 1;
    }
  }
});
