import 'package:flutter/foundation.dart';

import '../../core/network/api_exception.dart';
import 'quant_analysis_status.dart';
import 'quant_stock_analysis.dart';
import 'quant_stock_analysis_api.dart';
import 'technical_summary_result.dart';

class QuantStockAnalysisController extends ChangeNotifier {
  QuantStockAnalysisController({required this.api});

  final QuantStockAnalysisApi api;

  QuantAnalysisStatus status = QuantAnalysisStatus.idle;
  QuantStockAnalysis? result;

  int _requestId = 0;
  bool _isDisposed = false;

  Future<void> analyze(String symbol) async {
    final requestId = ++_requestId;
    result = null;
    status = QuantAnalysisStatus.loading;
    notifyListeners();

    try {
      final analysis = await api.analyze(symbol);

      if (_isDisposed || requestId != _requestId) {
        return;
      }

      if (analysis.bars.isEmpty) {
        status = QuantAnalysisStatus.empty;
      } else if (analysis.technicalSummary.riskFlags.contains(
        TechnicalRiskFlag.dataInsufficient,
      )) {
        status = QuantAnalysisStatus.insufficientData;
      } else {
        result = analysis;
        status = QuantAnalysisStatus.success;
      }
    } on ApiException catch (error) {
      if (_isDisposed || requestId != _requestId) {
        return;
      }

      status = error.type == ApiErrorType.notFound
          ? QuantAnalysisStatus.empty
          : QuantAnalysisStatus.failure;
    } catch (_) {
      if (_isDisposed || requestId != _requestId) {
        return;
      }

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
