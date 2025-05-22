Soluções para problemas de build e instalação de APK Flutter:

1. **APK não inicia após build**
   - Rode `flutter clean` no terminal do projeto.
   - Rode `flutter pub get`.
   - Certifique-se de que o arquivo `android/app/build.gradle` e `android/app/build.gradle.kts` estão corretos e não possuem erros de sintaxe.
   - Verifique se o package no AndroidManifest.xml está correto e único.
   - Rode novamente: `flutter build apk --release`
   - Instale o APK com: `'adb install -r build/app/outputs/flutter-apk/app-release.apk'`
   - Se ainda não iniciar, veja o log com: `adb logcat | grep flutter` para identificar o erro.

2. **Dois projetos Flutter com a mesma pasta android**
   - O Android identifica apps pelo atributo `package` na tag `<manifest>` do AndroidManifest.xml e pelo `applicationId` no `build.gradle`.
   - Para instalar dois apps diferentes, cada um deve ter um `package` e `applicationId` únicos.
   - Exemplo:
     - Projeto 1:  
       AndroidManifest.xml: `package="com.maparongamusic.app"`
       build.gradle: `applicationId = "com.maparongamusic.app"`
     - Projeto 2:  
       AndroidManifest.xml: `package="com.outroprojeto.app"`
       build.gradle: `applicationId = "com.outroprojeto.app"`
   - Altere ambos os arquivos em cada projeto.
   - Rode `flutter clean` e `flutter pub get` em cada projeto após a alteração.
   - Agora o Android verá os apps como diferentes e permitirá instalar ambos.

3. **Dica extra**
   - Nunca compartilhe a mesma pasta `android` entre dois projetos Flutter diferentes. Cada projeto deve ter sua própria pasta `android` com package/applicationId únicos.

4. **Projeto Flutter sem a pasta android**
   - Rode o comando: `flutter create .` na raiz do seu projeto para recriar a pasta `android`.
   - Isso irá gerar toda a estrutura padrão do Android para seu projeto Flutter.
   - Depois, personalize o `AndroidManifest.xml` e `build.gradle` conforme necessário (package/applicationId, permissões, etc).
   - Rode `flutter pub get` e depois `flutter build apk` normalmente.

5. **APK funciona no debug mas não abre no release**
   - Certifique-se de que o package no `<manifest ... package="...">` é único e igual ao `applicationId` no `android/app/build.gradle`.
   - Verifique se você não está usando código ou plugins que só funcionam em modo debug.
   - Verifique se há erros de Proguard/minify (desative minify temporariamente em `build.gradle` para testar).
   - Rode `flutter clean` e `flutter pub get`.
   - Rode `flutter build apk --release`.
   - Instale o APK com `adb install -r build/app/outputs/flutter-apk/app-release.apk`.
   - Veja o erro real com: `adb logcat | grep flutter` logo após tentar abrir o app.
   - Verifique se há permissões necessárias no AndroidManifest.xml.
   - Se usar Firebase ou plugins nativos, confira se o arquivo `google-services.json` está presente e correto.
   - Se o app depende de assets, confira se estão declarados corretamente no `pubspec.yaml` e estão presentes na pasta.

6. **O que significa `start ms-settings:developers`?**
   - Esse comando é usado no Windows para abrir diretamente as configurações de "Modo de Desenvolvedor" do sistema operacional.
   - Ele é útil para desenvolvedores que precisam ativar o modo desenvolvedor no Windows, por exemplo, para instalar apps fora da Microsoft Store ou usar recursos avançados de depuração.
   - **Não é necessário** para rodar ou compilar projetos Flutter para Android, a menos que você esteja desenvolvendo e testando apps UWP (Windows Universal Platform) ou precise instalar APKs diretamente no Windows Subsystem for Android.
   - Para Flutter/Android, basta ativar o modo desenvolvedor no seu dispositivo Android (Configurações > Sobre o telefone > Número da versão > toque 7x, depois ative "Depuração USB").

7. **Como usar um ícone personalizado no Android**
   - Adicione ao seu `pubspec.yaml`:
     dev_dependencies:
       flutter_launcher_icons: ^0.13.1

     flutter_icons:
       android: true
       ios: false
       image_path: "assets/appicon.jpg"
       adaptive_icon_background: "#ffffff"
       adaptive_icon_foreground: "assets/appicon.jpg"
   - Rode o comando: `flutter pub run flutter_launcher_icons:main`
   - Isso irá gerar automaticamente todos os tamanhos de ícone nas pastas mipmap.
   - No `AndroidManifest.xml`, use: `android:icon="@mipmap/ic_launcher"`
   - Para gerar todos os tamanhos automaticamente, use o pacote [flutter_launcher_icons](https://pub.dev/packages/flutter_launcher_icons).

8. **App crasha antes de iniciar**
   - Rode `flutter clean` e depois `flutter pub get`.
   - Certifique-se de que o `applicationId` em `android/app/build.gradle` e o `namespace` em `build.gradle.kts` são únicos e iguais.
   - Confira se o `AndroidManifest.xml` não tem o atributo `package` (em projetos Flutter modernos, só use o `applicationId` no gradle).
   - Verifique se o atributo `android:name="${applicationName}"` está correto ou remova se não usa uma classe customizada.
   - Confira se o atributo `android:icon` está correto e o arquivo existe em todos os mipmaps.
   - Se usou `flutter_launcher_icons`, confira se o arquivo `assets/appicon.jpg` existe e está acessível.
   - Veja o erro real com: `adb logcat | grep flutter` ou apenas `adb logcat` após tentar abrir o app.
   - Verifique se não há assets declarados no `pubspec.yaml` que não existem.
   - Se usa plugins nativos, confira se todos estão configurados corretamente.
   - Se o erro for "package identifier or launch activity not found", confira se o `MainActivity` existe em `android/app/src/main/java/<package>/MainActivity.java` ou `.kt` e está correto no manifest.
   - Se o erro for de Proguard/minify, desative minify temporariamente em `build.gradle`.
   - Se o erro persistir, envie o trecho do logcat com o erro para análise detalhada.

9. **warning: ignoring broken ref refs/remotes/origin/main**
   - Esse aviso do Git significa que há uma referência remota corrompida (provavelmente um branch remoto antigo ou removido).
   - Para corrigir:
     1. Rode: `git remote prune origin`
     2. Se persistir, rode: `git gc --prune=now`
     3. Se ainda aparecer, remova manualmente o arquivo `.git/refs/remotes/origin/main` (se existir) e rode `git fetch --all`.
   - Esse aviso não afeta o funcionamento do Flutter ou do seu projeto, mas pode ser resolvido para evitar poluição nos logs.

Se ainda tiver problemas, verifique o log do dispositivo com `adb logcat` para mensagens de erro detalhadas.
