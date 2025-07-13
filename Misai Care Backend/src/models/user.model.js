import { DataTypes } from 'sequelize';
import sequelize from '../config/db.js';

const User = sequelize.define('User', {
  mobile: {
    type: DataTypes.STRING,
    allowNull: false,
    unique: true
  },
  otp: DataTypes.STRING,
  did: DataTypes.STRING,
  privateKey: DataTypes.TEXT,
  abha: DataTypes.STRING
});

export default User;
