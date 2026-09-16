// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'Centre de candidatures';

  @override
  String get navDashboard => 'Tableau de bord';

  @override
  String get navApplications => 'Candidatures';

  @override
  String get navCalendar => 'Calendrier';

  @override
  String get navTemplates => 'Mes documents';

  @override
  String get navSettings => 'Paramètres';

  @override
  String get applicationsTitle => 'Mes candidatures';

  @override
  String get btnNewApplication => 'Nouvelle candidature';

  @override
  String get statusOpen => 'En cours';

  @override
  String get statusSent => 'Envoyée';

  @override
  String get statusInterview => 'Entretien';

  @override
  String get statusAccepted => 'Acceptée';

  @override
  String get statusRejected => 'Refusée';

  @override
  String get kanbanPreparation => '📝 En préparation';

  @override
  String get kanbanWaiting => '⏳ En attente de réponse';

  @override
  String get kanbanInterview => '🗣️ En entretien';

  @override
  String get kanbanOffers => '🎉 Offres';

  @override
  String get kanbanArchive => '🗑️ Archives (refus)';

  @override
  String get searchPlaceholder => 'Rechercher par entreprise, poste, lieu...';

  @override
  String get emptyApplicationsTitle => 'Aucune candidature pour le moment';

  @override
  String get emptyApplicationsDesc =>
      'Il semble que vous n\'ayez pas encore ajouté de candidature. Cliquez sur \'Nouvelle candidature\' pour commencer !';

  @override
  String get dashboardTitle => 'Statistiques des candidatures';

  @override
  String get dashboardOverview => 'APERÇU';

  @override
  String get dashboardApplications => 'CANDIDATURES';

  @override
  String get dashboardOpen => 'EN COURS';

  @override
  String get dashboardRejections => 'REFUS';

  @override
  String get dashboardResponseRate => 'TAUX DE RÉPONSE';

  @override
  String get dashboardRejectionRate => 'TAUX DE REFUS';

  @override
  String get dashboardInterviews => 'ENTRETIENS';

  @override
  String get dashboardCommute => 'Ø TEMPS DE TRAJET';

  @override
  String get dashboardAppsPerMonth => 'CANDIDATURES PAR MOIS';

  @override
  String get dashboardTopRejectionReasons => 'PRINCIPAUX MOTIFS DE REFUS';

  @override
  String get dashboardNoRejectionReasons =>
      'Aucun motif de refus enregistré pour le moment.';

  @override
  String get calendarTitle => 'Calendrier des candidatures';

  @override
  String get calendarNoEvents => 'Aucun événement ce jour-là.';

  @override
  String get templatesTitle => 'Modèles & Lettres de motivation';

  @override
  String get templatesNew => 'Nouveau modèle';

  @override
  String get templatesEmpty => 'Aucun modèle créé pour le moment.';

  @override
  String get templatesCreateFirst =>
      'Créez votre première lettre de motivation ou un bloc de texte !';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get settingsLanguage => 'Langue / Language';

  @override
  String get settingsTheme => 'Mode du thème';

  @override
  String get settingsThemeLight => 'Clair';

  @override
  String get settingsThemeDark => 'Sombre';

  @override
  String get settingsThemeSystem => 'Par défaut du système';

  @override
  String get settingsPreset => 'Thème prédéfini';

  @override
  String get settingsAccentColor => 'Couleur d\'accentuation';

  @override
  String get settingsJobcenterMode => 'Mode Jobcenter / Agence pour l\'emploi';

  @override
  String get reportTitle => 'Justificatif de recherche d\'emploi';

  @override
  String get reportSavePdf => 'Enregistrer en PDF';

  @override
  String get reportDate => 'DATE DE CANDIDATURE';

  @override
  String get reportCompany => 'ENTREPRISE';

  @override
  String get reportPosition => 'POSTE';

  @override
  String get reportStatus => 'STATUT';

  @override
  String get reportRejectionReason => 'MOTIF DE REFUS';

  @override
  String get settingsLanguageTitle => 'Langue';

  @override
  String get settingsAppLanguage => 'Langue de l\'application';

  @override
  String get settingsDesignTitle => 'Design & Personnalisation';

  @override
  String get settingsDesignMode => 'Mode d\'affichage';

  @override
  String get settingsAccentColorTitle => 'Couleur d\'accentuation';

  @override
  String get settingsPresetTheme => 'Thème prédéfini';

  @override
  String get settingsPresetDesc => 'Combinaisons de design prédéfinies';

  @override
  String get settingsJobcenterTitle => 'Mode Jobcenter';

  @override
  String get settingsJobcenterDesc => 'Affiche l\'onglet \'Justificatif\'';

  @override
  String get settingsFieldTitle =>
      'Votre secteur d\'activité & colonnes personnalisées';

  @override
  String get settingsFieldSelect => 'Sélectionner un secteur d\'activité';

  @override
  String get settingsCustomCols =>
      'Colonnes supplémentaires (séparées par des virgules)';

  @override
  String get settingsPersonalData =>
      'Données personnelles (pour l\'export PDF)';

  @override
  String get settingsYourName => 'Votre nom';

  @override
  String get settingsYourAddress => 'Votre adresse';

  @override
  String get dashboardTabWeek => 'Semaine en cours';

  @override
  String get dashboardTabTotal => 'Vue d\'ensemble';

  @override
  String get dashboardMsgStart => 'Chaque voyage commence par un premier pas !';

  @override
  String get dashboardMsgGood => 'Bon début ! Continuez ainsi !';

  @override
  String get dashboardMsgStrong => 'Très belle performance cette semaine !';

  @override
  String get dashboardMsgFantastic => 'TRAVAIL FANTASTIQUE CETTE SEMAINE !';

  @override
  String get dashboardNewApps => 'NOUVELLES CANDIDATURES';

  @override
  String get dashboardActiveApps => 'CANDIDATURES ACTIVES';

  @override
  String get dashboardGoal => 'Objectif hebdomadaire : ';

  @override
  String get dashboardThisWeek => 'Cette semaine ';

  @override
  String get dashboardFooter =>
      'Accrochez-vous ! Chaque étape vous rapproche du poste idéal. 🚀';

  @override
  String get dashboardVsLastWeek => ' vs la semaine dernière ';

  @override
  String get dashboardAppsLabel => ' candidatures';

  @override
  String get appSearch => 'Rechercher';

  @override
  String get appSearchHint => 'Rechercher par entreprise, poste, lieu...';

  @override
  String get appFilterAll => 'Toutes';

  @override
  String get appCheckInbox => 'Vérifier la boîte de réception';

  @override
  String get appEmptyTitle => 'Il est temps de faire le premier pas !';

  @override
  String get appEmptyDesc =>
      'Créez votre première candidature et organisez votre chemin vers le poste idéal.';

  @override
  String get calClickDetails =>
      'Cliquez sur un jour mis en évidence pour voir les détails.';

  @override
  String get calOverdue => 'En retard';

  @override
  String get calFollowUp => 'Relancer';

  @override
  String get reportGeneratedOn => 'Généré le : ';

  @override
  String get reportNoApps => 'Aucune candidature trouvée.';

  @override
  String get navJobcenter => 'Justificatif Jobcenter';

  @override
  String get settingsImapTitle => 'Synchronisation des e-mails (IMAP)';

  @override
  String get settingsImapDesc =>
      'Reçoit automatiquement les refus et invitations';

  @override
  String get settingsImapExp => 'EXPERIMENTAL';

  @override
  String get settingsImapWarning =>
      'Cette fonctionnalité est encore en cours de développement. La reconnaissance automatique des noms d\'entreprises et des candidatures peut être imprécise. Veuillez vérifier manuellement les entrées importées.';

  @override
  String get settingsImapProvider => 'Fournisseur';

  @override
  String get settingsImapManual => 'Manuel / Serveur personnalisé';

  @override
  String get settingsImapServer => 'Serveur IMAP';

  @override
  String get settingsImapPort => 'Port';

  @override
  String get settingsImapEmail => 'Adresse e-mail';

  @override
  String get settingsImapPassword =>
      'Mot de passe (mot de passe d\'application)';

  @override
  String get settingsImapSave => 'Enregistrer les données';

  @override
  String get settingsExportTitle => 'Export des données';

  @override
  String get settingsExportPdf => 'Exporter le justificatif Jobcenter (PDF)';

  @override
  String get settingsExportCsv => 'Exporter au format CSV';

  @override
  String get settingsExportBackup =>
      'Exporter la sauvegarde de la base de données (.sqlite)';

  @override
  String get settingsExportRestore =>
      'Restaurer la base de données depuis une sauvegarde';

  @override
  String get settingsExportRestart =>
      'Info : Le redémarrage de l\'application est requis après l\'import.';

  @override
  String get settingsAppQuit => 'Quitter l\'application';

  @override
  String get appNotFoundTitle => 'Aucun résultat trouvé.';

  @override
  String get appNotFoundDesc =>
      'Il n\'y a aucun résultat correspondant à ces critères de filtrage.';

  @override
  String get formTabBasic => 'Données principales';

  @override
  String get formTabEmails => 'E-mails & Contacts';

  @override
  String get formTabDocs => 'Documents';

  @override
  String get formTabNotes => 'Notes';

  @override
  String get formBasicContact => 'Contact & Adresse';

  @override
  String get formBasicSave => 'Enregistrer';

  @override
  String get formBasicInterview => 'Entretien';

  @override
  String get formBasicSalary => 'Prétention salariale (€/an)';

  @override
  String get formBasicOpen => 'En cours';

  @override
  String get formBasicAccepted => 'Acceptée';

  @override
  String get formBasicRejected => 'Refusée';

  @override
  String get formBasicJobLink => 'Lien vers l\'offre d\'emploi';

  @override
  String get formBasicJobLinkHint =>
      'Collez un lien d\'offre d\'emploi ou importez un PDF (ex. Jobcenter) pour extraire les données.';

  @override
  String get formBasicAutofill => 'Remplir';

  @override
  String get formBasicCommute => 'Temps de trajet en voiture (min)';

  @override
  String get formBasicRejectionReason => 'Motif de refus';

  @override
  String get formBasicUploadPdf => 'Ou importer un PDF';

  @override
  String get formBasicStatus => 'Statut';

  @override
  String get formBasicCompanyWeb => 'Site web de l\'entreprise (ex. https://)';

  @override
  String get formBasicMagic => 'Magic Auto-Fill';

  @override
  String get formBasicDelete => 'Supprimer';

  @override
  String get formBasicSent => 'Envoyée';

  @override
  String get reportGeneratedAt => 'Généré le :';

  @override
  String get reportTimeSuffix => '';

  @override
  String get weeklyGoal => 'Objectif hebdomadaire :';

  @override
  String get weeklyGoalSuffix => ' sur 5 candidatures';

  @override
  String get weeklyThisWeek => 'Cette semaine ';

  @override
  String get weeklyVs => ' candidatures vs la semaine dernière ';

  @override
  String get weeklyApplications => ' candidatures';

  @override
  String get weeklyMotivationalFooter =>
      'Accrochez-vous ! Chaque étape vous rapproche du poste idéal. 🚀';

  @override
  String get weeklyMotivationalFooterNoIcon =>
      'Accrochez-vous ! Chaque étape vous rapproche du poste idéal.';

  @override
  String get templatesTabMy => 'Mes modèles';

  @override
  String get templatesTabExamples => 'Modèles & Exemples';

  @override
  String get promptTitle => 'Générateur de prompt IA';

  @override
  String get promptDesc =>
      'Remplissez les champs pour générer un prompt professionnel que vous pourrez utiliser dans ChatGPT, Claude ou toute autre IA de votre choix.';

  @override
  String get promptPosition => 'Poste / Intitulé du poste';

  @override
  String get promptCompany => 'Entreprise';

  @override
  String get promptSkills => 'Vos compétences clés & expérience';

  @override
  String get promptTone => 'Tonalité';

  @override
  String get promptToneDefault => 'professionnel et courtois';

  @override
  String get promptGenerate => 'Générer le prompt';

  @override
  String get tplInitiative => 'Candidature spontanée';

  @override
  String get tplReply => 'Réponse à une offre d\'emploi';

  @override
  String get tplFollowUp => 'Relance / Suivi';

  @override
  String get tplRejection => 'Répondre poliment à un refus';

  @override
  String get tplTypeCover => 'LETTRE DE MOTIVATION';

  @override
  String get tplTypeSnippet => 'BLOC DE TEXTE';

  @override
  String get noAppsFound => 'Aucune candidature trouvée.';

  @override
  String get templatesEmptyState => 'Aucun modèle créé pour le moment.';

  @override
  String get templatesEmptyStateSub =>
      'Créez votre première lettre de motivation ou un bloc de texte !';

  @override
  String get promptSubtitle =>
      'Remplissez les champs pour générer un prompt professionnel que vous pourrez utiliser dans ChatGPT, Claude ou toute autre IA de votre choix.';
}
