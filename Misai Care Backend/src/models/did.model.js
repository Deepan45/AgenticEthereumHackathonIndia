 
const { DataTypes } = require('sequelize');
const sequelize = require('../config/db');
const User = require('./user.model');

const DID = sequelize.define('DID', {
  did: { type: DataTypes.STRING, allowNull: false, unique: true },
  privateKey: { type: DataTypes.TEXT },
});

User.hasOne(DID, { foreignKey: 'userId' });
DID.belongsTo(User, { foreignKey: 'userId' });

export default DID;
