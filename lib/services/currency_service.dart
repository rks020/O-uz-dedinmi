class CurrencyService {
  static const Map<String, double> _ratesToTry = {
    'TRY': 1.0,
    'USD': 36.05,
    'EUR': 38.65,
    'GBP': 46.50,
  };

  static double convert(double amount, String fromCurrency, String toCurrency) {
    if (fromCurrency == toCurrency) return amount;
    
    // Convert to TRY first (Base)
    double amountInTry = amount * (_ratesToTry[fromCurrency] ?? 1.0);
    
    // Convert from TRY to target
    double targetRate = _ratesToTry[toCurrency] ?? 1.0;
    return amountInTry / targetRate;
  }
  
  static double convertToTry(double amount, String fromCurrency) {
    return convert(amount, fromCurrency, 'TRY');
  }
}
