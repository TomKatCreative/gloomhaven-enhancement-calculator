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
  String get switchAction => 'Trocar';

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
  String get supportAndFeedback => 'Suporte e feedback';

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
  String get retirements => 'Aposentadorias';

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
  String get battleGoals => 'Objetivo de batalha';

  @override
  String get cardLevel => 'Nível da carta';

  @override
  String get previousEnhancements => 'Melhorias anteriores';

  @override
  String get enhancementType => 'Tipo de melhoria';

  @override
  String get actionDetails => 'Melhoria';

  @override
  String get cardDetails => 'Detalhes do cartão';

  @override
  String get discounts => 'Descontos';

  @override
  String get enhancementCalculator => 'Calculadora de melhorias';

  @override
  String get enhancementGuidelines => 'Diretrizes de melhoria';

  @override
  String get type => 'Selecionar tipo...';

  @override
  String get multipleTargets => 'Múltiplos alvos';

  @override
  String get generalGuidelines => 'Diretrizes gerais';

  @override
  String get scenario114Reward => 'Recompensa do cenário 114';

  @override
  String get forgottenCirclesSpoilers => 'Spoilers de Forgotten Circles';

  @override
  String get temporaryEnhancement => 'Melhorias temporárias';

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
  String get hailsDiscount => 'Desconto de Hail';

  @override
  String get lossNonPersistent => 'Perda não persistente';

  @override
  String get persistent => 'Persistente';

  @override
  String get eligibleFor => 'Elegível para';

  @override
  String get gameplay => 'JOGABILIDADE';

  @override
  String get display => 'EXIBIÇÃO';

  @override
  String get backupAndRestore => 'BACKUP E RESTAURAÇÃO LOCAL';

  @override
  String get testing => 'TESTE';

  @override
  String get customClasses => 'Classes personalizadas';

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
  String get useInterFont => 'Usar fonte Inter';

  @override
  String get useInterFontDescription =>
      'Substituir fontes estilizadas por Inter para melhorar a legibilidade';

  @override
  String get showRetiredCharacters => 'Mostrar personagens aposentados';

  @override
  String get showRetiredCharactersDescription =>
      'Alternar visibilidade de personagens aposentados na aba Personagens para reduzir a desordem';

  @override
  String get backup => 'Backup';

  @override
  String get backupDescription =>
      'Fazer backup dos seus personagens atuais para o seu dispositivo';

  @override
  String get restore => 'Restaurar';

  @override
  String get restoreDescription =>
      'Restaurar seus personagens de um arquivo de backup no seu dispositivo';

  @override
  String get filename => 'Nome do arquivo';

  @override
  String saved(String filename) {
    return '$filename salvo';
  }

  @override
  String get filenameRequired => 'Por favor, insira um nome de arquivo';

  @override
  String get backupIncludes =>
      'Seu backup incluirá todos os personagens, vantagens, maestrias e configurações do aplicativo (tema, estado da calculadora, classes desbloqueadas).';

  @override
  String get backupError =>
      'Falha ao criar backup. Por favor, tente novamente.';

  @override
  String get restoreWarning =>
      'Restaurar um arquivo de backup substituirá todos os personagens atuais e configurações do aplicativo (tema, estado da calculadora, classes desbloqueadas). Deseja continuar?';

  @override
  String get errorDuringRestore => 'Erro durante a operação de restauração';

  @override
  String restoreErrorMessage(String error) {
    return 'Houve um erro durante o processo de restauração. Seus dados existentes foram salvos e seu backup não foi modificado. Entre em contato com o desenvolvedor (através do menu Configurações) com seu arquivo de backup existente e estas informações:\n\n$error';
  }

  @override
  String get createAll => 'Criar todos';

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
  String levelExceedsProsperity(int maxLevel) {
    return 'Nível inicial máximo nesta prosperidade é $maxLevel';
  }

  @override
  String get prosperityLevel => 'Prosperidade';

  @override
  String get createCharacter => 'Criar personagem';

  @override
  String get gameEdition => 'Edição do jogo';

  @override
  String get selectClass => 'Selecionar classe...';

  @override
  String get addNotes => 'Adicionar notas...';

  @override
  String get personalQuest => 'Missão Pessoal';

  @override
  String get selectPersonalQuest => 'Selecionar missão pessoal...';

  @override
  String get selectAPersonalQuest => 'Selecionar uma Missão Pessoal';

  @override
  String get changePersonalQuest => 'Alterar Missão Pessoal?';

  @override
  String get changePersonalQuestBody =>
      'Isso substituirá sua missão atual e redefinirá todo o progresso.';

  @override
  String get comingSoon => 'Em breve...';

  @override
  String get noPersonalQuest => 'Nenhuma missão pessoal selecionada';

  @override
  String get change => 'Alterar';

  @override
  String progressOf(int current, int target) {
    return '$current/$target';
  }

  @override
  String get personalQuestComplete => 'Missão pessoal completa!';

  @override
  String personalQuestCompleteBody(String name) {
    return '$name cumpriu sua missão pessoal e deve se aposentar. Antes de se aposentar, considere gastar ouro em melhorias ou doações — todo ouro e itens são perdidos na aposentadoria. A cidade ganha 1 de prosperidade.';
  }

  @override
  String get retire => 'Aposentar';

  @override
  String get unretire => 'Desaposentar';

  @override
  String get notYet => 'Ainda Não';

  @override
  String get general => 'Geral e Grupo';

  @override
  String get stats => 'Geral';

  @override
  String get quest => 'Missão';

  @override
  String get perks => 'Vantagens';

  @override
  String get masteries => 'Maestrias';

  @override
  String get questAndNotes => 'Missão e Notas';

  @override
  String get perksAndMasteries => 'Vantagens e Maestrias';

  @override
  String get town => 'CIDADE';

  @override
  String get characters => 'PERSONAGENS';

  @override
  String get enhancements => 'MELHORIAS';

  @override
  String get subtract => 'Subtrair';

  @override
  String get add => 'Adicionar';

  @override
  String get campaign => 'Campanha';

  @override
  String get campaigns => 'Campanhas';

  @override
  String get party => 'Grupo';

  @override
  String get parties => 'Grupos';

  @override
  String get createCampaign => 'Criar campanha';

  @override
  String get createParty => 'Criar grupo';

  @override
  String get prosperity => 'Prosperidade';

  @override
  String prosperityLevelN(int level) {
    return 'Prosperidade $level';
  }

  @override
  String get reputation => 'Reputação';

  @override
  String get noCampaignsYet => 'Crie uma campanha para rastrear seus grupos';

  @override
  String get noPartiesYet =>
      'Crie um grupo para rastrear reputação e atribuir personagens';

  @override
  String get campaignName => 'Nome da campanha';

  @override
  String get partyName => 'Nome do grupo';

  @override
  String get edition => 'Edição';

  @override
  String get sanctuaryDonations => 'Doações do Santuário do Grande Carvalho';

  @override
  String get startingProsperity => 'Prosperidade inicial';

  @override
  String get startingReputation => 'Reputação inicial';

  @override
  String get deleteCampaign => 'Excluir campanha?';

  @override
  String get deleteCampaignBody =>
      'Isso excluirá permanentemente esta campanha e todos os seus grupos. Os personagens serão desvinculados, mas não excluídos.';

  @override
  String get deleteParty => 'Excluir grupo?';

  @override
  String get deletePartyBody =>
      'Isso excluirá permanentemente este grupo. Os personagens serão desvinculados, mas não excluídos.';

  @override
  String get selectCampaign => 'Selecionar campanha';

  @override
  String get selectParty => 'Selecionar grupo';

  @override
  String get switchParty => 'Trocar grupo';

  @override
  String get renameCampaign => 'Renomear campanha';

  @override
  String get renameParty => 'Renomear';

  @override
  String get checkmarks => 'marcas';

  @override
  String get openEnvelopeB => 'Abra o envelope B';

  @override
  String get noParty => 'Sem grupo';

  @override
  String get notAssignedToParty => 'Não atribuído a um grupo';

  @override
  String get assignToParty => 'Atribuir a um grupo';

  @override
  String get createCampaignFirst =>
      'Crie uma campanha primeiro para atribuir um grupo';

  @override
  String get scenarioLocation => 'Local do cenário';

  @override
  String get partyNotes => 'Notas do grupo';

  @override
  String get achievements => 'Conquistas';

  @override
  String get shopPriceModifier => 'Loja';

  @override
  String get addPartyNotes => 'Adicionar notas do grupo...';
}
