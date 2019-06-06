const { vkController } = require("../code/vk-controller")

module.exports = async(callback) => {
  try {
  await vkController();
  callback()
} catch (error) {
  callback(error);
}
}
