var express = require('express');
var router = express.Router();
var env = process.env.NODE_ENV || "production";
const { Pool } = require('pg')
const pool = new Pool({
  database: 'webhw',
  user:'root',
  password: 'password'
})

/* GET home page. */
router.get('/films', function (req, res, next) {
  pool.query('SELECT * FROM films_all', (err, result) => {
    if (err) console.log(err)
    if (result) {
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
    pool.end()
  })
});


module.exports = router;
