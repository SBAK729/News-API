let blacklist = [];

const blacklists = {
  add(token) {
    blacklist.push(token);
  },
  isBlacklisted(token) {
    return blacklist.includes(token);
  }
};

export default blacklists;