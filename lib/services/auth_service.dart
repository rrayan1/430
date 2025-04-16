class AuthService {
  static final _users = <String, String>{};

  static bool login(String email, String password) {
    return _users.containsKey(email) && _users[email] == password;
  }

  static bool signup(String email, String password) {
    if (_users.containsKey(email)) return false;
    _users[email] = password;
    return true;
  }
}
