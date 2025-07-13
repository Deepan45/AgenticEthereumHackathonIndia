import sequelize from '../config/db.js';
import User from './user.model.js';

export const initModels = async () => {
  await sequelize.sync({ alter: true });
};

export { User, sequelize };
