Sequelize = require 'sequelize'

db_name = 'unset'

# Sequelize
if process.env.DATABASE_URL
  sequelize = new Sequelize process.env.DATABASE_URL
else
  db_name = if process.env.NODE_ENV is 'test' then 'ee_db_test' else 'ee_db_development'
  sequelize = new Sequelize db_name, 'tyler', null, {
    host: 'localhost',
    port: 5432,
    dialect: 'postgres',
    logging: console.log if !process.env.SILENT_OPS
  }
  # sequelize = new Sequelize 'postgres://tyler@localhost:5432/ee_db_test'

sequelize.authenticate()
.then () -> console.log 'Database connection has been established successfully.'
.catch (err) -> console.error 'Unable to connect to the database: ' + err

module.exports = sequelize
