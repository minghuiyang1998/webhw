var express = require('express');
var router = express.Router();
var env = process.env.NODE_ENV || "production";
const { Pool } = require('pg')
const pool = new Pool()

// pool使用默认的localhost配置
pool.on('error', (err, client) => {
  console.error('Unexpected error on idle client', err)
  process.exit(-1)
})

/* GET home page. */
router.get('/films', function (req, res, next) {
  pool.connect((err, client, done) => {
    if (err) throw err
    client.query('SELECT * FROM films_all', (err, result) => {
      done()

      if (err) {
        console.log(err.stack)
      } else {
        let films = result.rows.map((item) => {
          Object.keys(item).forEach((key) => {
            if (item[key] && item[key].match(/^\[.*\]$/g)) {
              item[key] = JSON.parse(item[key])
            }
          })
          return item
        })
        res.send({ films });
      }
    })
  })

});

module.exports = router;
