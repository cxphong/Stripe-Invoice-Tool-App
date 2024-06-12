class SharedData {
  static final SharedData _singleton = SharedData._internal();

  factory SharedData() {
    return _singleton;
  }

  SharedData._internal();

  // Your shared variable
  String stripe_access_key= 'sk_test_51PQn6fA053no53yjOkGnBCmlEFS9SZiHxw4fJ9YtDk7irRycxyYvSMnMcODpKsuU1DR1JMCDiBhzvbXvuY4Kbned00P73fzDFO';
}
