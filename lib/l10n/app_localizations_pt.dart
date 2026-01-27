// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitleIOS => 'Gloomhaven Utility';

  @override
  String get appTitleAndroid => 'Gloomhaven Companion';

  @override
  String get search => 'Pesquisar...';

  @override
  String get close => 'Fechar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Salvar';

  @override
  String get delete => 'Excluir';

  @override
  String get create => 'Criar';

  @override
  String get continue_ => 'Continuar';

  @override
  String get copy => 'Copiar';

  @override
  String get share => 'Compartilhar';

  @override
  String get gotIt => 'Entendi!';

  @override
  String get pleaseWait => 'Por favor, aguarde...';

  @override
  String get restoring => 'Restaurando...';

  @override
  String get solve => 'Resolver';

  @override
  String get unlock => 'Desbloquear';

  @override
  String get settings => 'Configurações';

  @override
  String get changelog => 'Changelog';

  @override
  String get license => 'Licença';

  @override
  String get supportAndFeedback => 'Suporte e Feedback';

  @override
  String get name => 'Nome';

  @override
  String get xp => 'XP';

  @override
  String get gold => 'Ouro';

  @override
  String get resources => 'Recursos';

  @override
  String get notes => 'Notas';

  @override
  String get retired => '(aposentado)';

  @override
  String get previousRetirements => 'Aposentadorias anteriores';

  @override
  String pocketItemsAllowed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count itens de bolso permitidos',
      one: '1 item de bolso permitido',
    );
    return '$_temp0';
  }

  @override
  String get battleGoalCheckmarks => 'Marcas de Objetivo de Batalha';

  @override
  String get cardLevel => 'Nível da Carta';

  @override
  String get previousEnhancements => 'Melhorias Anteriores';

  @override
  String get enhancementType => 'Tipo de Melhoria';

  @override
  String get discountsAndSettings => 'Descontos e Configurações';

  @override
  String get enhancementCalculator => 'Calculadora de Melhorias';

  @override
  String get enhancementGuidelines => 'Diretrizes de Melhoria';

  @override
  String get type => 'Tipo';

  @override
  String get multipleTargets => 'Múltiplos Alvos';

  @override
  String get generalGuidelines => 'Diretrizes Gerais';

  @override
  String get scenario114Reward => 'Recompensa do Cenário 114';

  @override
  String get forgottenCirclesSpoilers => 'Spoilers de Forgotten Circles';

  @override
  String get temporaryEnhancement => 'Melhoria Temporária †';

  @override
  String get variant => 'Variante';

  @override
  String get building44 => 'Edifício 44';

  @override
  String get frosthavenSpoilers => 'Spoilers de Frosthaven';

  @override
  String get enhancer => 'Aprimorador';

  @override
  String get lvl1 => 'Nível 1';

  @override
  String get lvl2 => 'Nível 2';

  @override
  String get lvl3 => 'Nível 3';

  @override
  String get lvl4 => 'Nível 4';

  @override
  String get buyEnhancements => 'Comprar melhorias';

  @override
  String get reduceEnhancementCosts =>
      'e reduzir todos os custos de melhoria em 10 de ouro';

  @override
  String get reduceLevelPenalties =>
      'e reduzir penalidades de nível em 10 de ouro por nível';

  @override
  String get reduceRepeatPenalties =>
      'e reduzir penalidades de repetição em 25 de ouro por melhoria';

  @override
  String get hailsDiscount => 'Desconto de Hail ‡';

  @override
  String get lossNonPersistent => 'Perda não persistente';

  @override
  String get persistent => 'Persistente';

  @override
  String get eligibleFor => 'Elegível Para';

  @override
  String get gameplay => 'JOGABILIDADE';

  @override
  String get display => 'EXIBIÇÃO';

  @override
  String get backupAndRestore => 'BACKUP E RESTAURAÇÃO';

  @override
  String get testing => 'TESTE';

  @override
  String get customClasses => 'Classes Personalizadas';

  @override
  String get customClassesDescription =>
      'Incluir Crimson Scales, Trail of Ashes e classes personalizadas \'lançadas\' criadas pela comunidade CCUG';

  @override
  String get solveEnvelopeX => 'Resolver \'Envelope X\'';

  @override
  String get gloomhavenSpoilers => 'Spoilers de Gloomhaven';

  @override
  String get enterSolution => 'Digite a solução do quebra-cabeça';

  @override
  String get solution => 'Solução';

  @override
  String get bladeswarmUnlocked => 'Bladeswarm desbloqueado';

  @override
  String get unlockEnvelopeV => 'Desbloquear \'Envelope V\'';

  @override
  String get crimsonScalesSpoilers => 'Spoilers de Crimson Scales';

  @override
  String get enterPassword => 'Qual é a senha para desbloquear este envelope?';

  @override
  String get password => 'Senha';

  @override
  String get vanquisherUnlocked => 'Vanquisher desbloqueado';

  @override
  String get brightness => 'Brilho';

  @override
  String get dark => 'Escuro';

  @override
  String get light => 'Claro';

  @override
  String get useInterFont => 'Usar Fonte Inter';

  @override
  String get useInterFontDescription =>
      'Substituir fontes estilizadas por Inter para melhorar a legibilidade';

  @override
  String get showRetiredCharacters => 'Mostrar Personagens Aposentados';

  @override
  String get showRetiredCharactersDescription =>
      'Alternar visibilidade de personagens aposentados na aba Personagens para reduzir a desordem';

  @override
  String get backup => 'Backup';

  @override
  String get backupDescription => 'Fazer backup dos seus personagens atuais';

  @override
  String get restore => 'Restaurar';

  @override
  String get restoreDescription =>
      'Restaurar seus personagens de um arquivo de backup';

  @override
  String get backupFileWarning =>
      'Se já existir outro arquivo de backup na pasta Downloads com o mesmo nome, ele será substituído';

  @override
  String get filename => 'Nome do arquivo';

  @override
  String savedTo(String path) {
    return 'Salvo em $path';
  }

  @override
  String get backupError =>
      'Falha ao criar backup. Por favor, tente novamente.';

  @override
  String get restoreWarning =>
      'Restaurar um arquivo de backup substituirá todos os personagens atuais. Deseja continuar?';

  @override
  String get errorDuringRestore => 'Erro Durante a Operação de Restauração';

  @override
  String restoreErrorMessage(String error) {
    return 'Houve um erro durante o processo de restauração. Seus dados existentes foram salvos e seu backup não foi modificado. Entre em contato com o desenvolvedor (através do menu Configurações) com seu arquivo de backup existente e estas informações:\n\n$error';
  }

  @override
  String get createAll => 'Criar Todos';

  @override
  String get gloomhaven => 'Gloomhaven';

  @override
  String get frosthaven => 'Frosthaven';

  @override
  String get crimsonScales => 'Crimson Scales';

  @override
  String get custom => 'Personalizado';

  @override
  String get andVariants => 'e variantes';

  @override
  String createCharacterPrompt(String article) {
    return 'Crie $article personagem usando o botão abaixo, ou restaure um backup pelo menu Configurações';
  }

  @override
  String get articleA => 'um';

  @override
  String get articleYourFirst => 'seu primeiro';

  @override
  String get class_ => 'Classe';

  @override
  String classWithVariant(String variant) {
    return 'Classe ($variant)';
  }

  @override
  String get startingLevel => 'Nível inicial';

  @override
  String get prosperityLevel => 'Nível de prosperidade';

  @override
  String get pleaseSelectClass => 'Por favor, selecione uma Classe';
}
