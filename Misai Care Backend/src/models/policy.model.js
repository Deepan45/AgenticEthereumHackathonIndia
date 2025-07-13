 
const { DataTypes } = require('sequelize');
const sequelize = require('../config/db');

const Policy = sequelize.define('Policy', {
  name: DataTypes.STRING,
  coverageAmount: DataTypes.FLOAT,
  premium: DataTypes.FLOAT,
  description: DataTypes.TEXT,
});

export default Policy;
