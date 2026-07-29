import 'package:flutter/foundation.dart';

import 'quant_analysis_status.dart';
import 'stock_daily_bar.dart';
import 'technical_summary_api.dart';
import 'technical_summary_result.dart';

class TechnicalSummaryController extends ChangeNotifier {
  TechnicalSummaryController({required this.api});

  final TechnicalSummaryApi api;

  QuantAnalysisStatus status = QuantAnalysisStatus.idle;
  TechnicalSummaryResult? result;

  int _requestId = 0;
  bool _isDisposed = false;

  Future<void> analyze(List<StockDailyBar> bars) async {
    final requestId = ++_requestId;
    result = null;

    if (bars.isEmpty) {
      status = QuantAnalysisStatus.empty;
      notifyListeners();
      return;
    }

    status = QuantAnalysisStatus.loading;
    notifyListeners();

    try {
      final analysisResult = await api.analyze(bars);

      if (_isDisposed || requestId != _requestId) {
        return;
      }

      result = analysisResult;
      status = QuantAnalysisStatus.success;
    } catch (_) {
      if (_isDisposed || requestId != _requestId) {
        return;
      }

      result = null;
      status = QuantAnalysisStatus.failure;
    }

    notifyListeners();
  }

  void reset() {
    _requestId++;
    result = null;
    status = QuantAnalysisStatus.idle;
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _requestId++;
    super.dispose();
  }
}
