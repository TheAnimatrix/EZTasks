import 'package:get_it/get_it.dart';
import 'package:tasks/services/taskManager.dart';

final getIt = GetIt.instance;

void setup()
{
  getIt.registerSingleton<TaskManager>(TaskManager());
}
