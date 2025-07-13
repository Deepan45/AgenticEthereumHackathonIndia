 
const { DataTypes } = require('sequelize');
const sequelize = require('../config/db');
const User = require('./user.model');
const Policy = require('./policy.model');

const UserPolicy = sequelize.define('UserPolicy', {
  did: DataTypes.STRING,
});

User.belongsToMany(Policy, { through: UserPolicy });
Policy.belongsToMany(User, { through: UserPolicy });

export default UserPolicy;
