import 'dart:io';

void main() async {
  print('\n🚀 Agente de Automatización GitHub\n');

  // 1. Preguntar por el link del repositorio
  stdout.write('https://github.com/paola-ortega-0301/Ejemplo-crud-eventos-6J-abril-2026.git');
  String? repoUrl = stdin.readLineSync();
  if (repoUrl == null || repoUrl.isEmpty) {
    print('❌ Error: El link del repositorio es obligatorio.');
    return;
  }

  // 2. Preguntar por el commit
  stdout.write('📝 Ingresa el mensaje del commit: ');
  String? commitMessage = stdin.readLineSync();
  if (commitMessage == null || commitMessage.isEmpty) {
    print('❌ Error: El mensaje del commit es obligatorio.');
    return;
  }

  // 3. Preguntar por la rama (default main)
  stdout.write('🌿 Nombre de la rama (presiona Enter para "main"): ');
  String? branch = stdin.readLineSync();
  if (branch == null || branch.isEmpty) {
    branch = 'main';
  }

  print('\n⏳ Iniciando proceso...\n');

  try {
    // Verificar si es un repositorio git
    if (!Directory('.git').existsSync()) {
      await _runCommand('git', ['init'], 'Iniciando repositorio local');
    }

    // Agregar archivos
    await _runCommand('git', ['add', '.'], 'Agregando archivos');

    // Commit
    await _runCommand('git', ['commit', '-m', commitMessage], 'Creando commit');

    // Renombrar rama
    await _runCommand('git', ['branch', '-M', branch], 'Configurando rama $branch');

    // Verificar si el remote ya existe
    var remoteCheck = await Process.run('git', ['remote', 'get-url', 'origin']);
    if (remoteCheck.exitCode == 0) {
      await _runCommand('git', ['remote', 'set-url', 'origin', repoUrl], 'Actualizando remote origin');
    } else {
      await _runCommand('git', ['remote', 'add', 'origin', repoUrl], 'Agregando remote origin');
    }

    // Push
    print('📤 Subiendo repositorio a GitHub ($branch)...');
    var pushResult = await Process.start('git', ['push', '-u', 'origin', branch], mode: ProcessStartMode.inheritStdio);
    int exitCode = await pushResult.exitCode;

    if (exitCode == 0) {
      print('\n✅ ¡Éxito! Tu repositorio ha sido enviado a GitHub.');
    } else {
      print('\n❌ Error al subir el repositorio. Asegúrate de que el repositorio remoto existe y tienes permisos.');
    }
  } catch (e) {
    print('❌ Ocurrió un error inesperado: $e');
  }
}

Future<void> _runCommand(String command, List<String> args, String description) async {
  stdout.write('🔹 $description... ');
  var result = await Process.run(command, args);
  if (result.exitCode == 0) {
    print('Hecho.');
  } else {
    print('Error.\n${result.stderr}');
    throw Exception('Falló: $description');
  }
}
