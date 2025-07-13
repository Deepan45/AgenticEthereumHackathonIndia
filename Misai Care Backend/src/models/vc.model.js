 
const { DataTypes } = require('sequelize');
const sequelize = require('../config/db');
const User = require('./user.model');

const VC = sequelize.define('VC', {
  type: DataTypes.STRING,
  data: DataTypes.JSONB,
});

User.hasMany(VC, { foreignKey: 'userId' });
VC.belongsTo(User, { foreignKey: 'userId' });

export default VC;
