import 'package:previsao_tempo/data/armazenamento_local.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

/// Abre o [ArmazenamentoLocal] sobre um `SharedPreferences` em memória,
/// opcionalmente com valores já gravados.
Future<ArmazenamentoLocal> armazenamentoEmMemoria([Map<String, Object> dados = const {}]) {
  SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.withData(dados);
  return ArmazenamentoLocal.abrir();
}
