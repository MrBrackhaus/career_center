// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Finnish (`fi`).
class AppLocalizationsFi extends AppLocalizations {
  AppLocalizationsFi([String locale = 'fi']) : super(locale);

  @override
  String get appName => 'Urakeskus';

  @override
  String get navDashboard => 'Ohjauspaneeli';

  @override
  String get navApplications => 'Hakemukset';

  @override
  String get navCalendar => 'Kalenteri';

  @override
  String get navTemplates => 'Omat asiakirjat';

  @override
  String get navSettings => 'Asetukset';

  @override
  String get applicationsTitle => 'Omat hakemukset';

  @override
  String get btnNewApplication => 'Uusi hakemus';

  @override
  String get statusOpen => 'Avoin';

  @override
  String get statusSent => 'Lähetetty';

  @override
  String get statusInterview => 'Haastattelu';

  @override
  String get statusAccepted => 'Hyväksytty';

  @override
  String get statusRejected => 'Hylätty';

  @override
  String get kanbanPreparation => '📝 Valmisteilla';

  @override
  String get kanbanWaiting => '⏳ Odottaa vastausta';

  @override
  String get kanbanInterview => '🗣️ Haastattelussa';

  @override
  String get kanbanOffers => '🎉 Tarjoukset';

  @override
  String get kanbanArchive => '🗑️ Arkisto (Hylätyt)';

  @override
  String get searchPlaceholder => 'Etsi yritystä, tehtävää...';

  @override
  String get emptyApplicationsTitle => 'Ei vielä hakemuksia';

  @override
  String get emptyApplicationsDesc =>
      'Näyttää siltä, ettet ole vielä lisännyt yhtään hakemusta. Aloita napsauttamalla \'Uusi hakemus\'!';

  @override
  String get dashboardTitle => 'Hakemustilastot';

  @override
  String get dashboardOverview => 'YLEISKATSAUS';

  @override
  String get dashboardApplications => 'HAKEMUKSET';

  @override
  String get dashboardOpen => 'AVOINNA';

  @override
  String get dashboardRejections => 'HYLÄTYT';

  @override
  String get dashboardResponseRate => 'VASTAUSPROSENTTI';

  @override
  String get dashboardRejectionRate => 'HYLKÄYSPROSENTTI';

  @override
  String get dashboardInterviews => 'HAASTATTELUT';

  @override
  String get dashboardCommute => 'KESKIM. TYÖMATKA';

  @override
  String get dashboardAppsPerMonth => 'HAKEMUKSIA KUUKAUDESSA';

  @override
  String get dashboardTopRejectionReasons => 'YLEISIMMÄT HYLKÄYSSYYT';

  @override
  String get dashboardNoRejectionReasons =>
      'Hylkäyssyitä ei ole vielä kirjattu.';

  @override
  String get calendarTitle => 'Hakemuskalenteri';

  @override
  String get calendarNoEvents => 'Ei tapahtumia tänä päivänä.';

  @override
  String get templatesTitle => 'Mallit ja saatekirjeet';

  @override
  String get templatesNew => 'Uusi malli';

  @override
  String get templatesEmpty => 'Malleja ei ole vielä luotu.';

  @override
  String get templatesCreateFirst =>
      'Luo ensimmäinen saatekirjeesi tai tekstikatkelmasi!';

  @override
  String get settingsTitle => 'Asetukset';

  @override
  String get settingsLanguage => 'Kieli / Language';

  @override
  String get settingsTheme => 'Teematila';

  @override
  String get settingsThemeLight => 'Vaalea';

  @override
  String get settingsThemeDark => 'Tumma';

  @override
  String get settingsThemeSystem => 'Järjestelmän oletus';

  @override
  String get settingsPreset => 'Valmis teema';

  @override
  String get settingsAccentColor => 'Aksenttiväri';

  @override
  String get settingsJobcenterMode => 'Jobcenter- / Työvoimatoimistotila';

  @override
  String get reportTitle => 'Todistus työnhakuaktiivisuudesta';

  @override
  String get reportSavePdf => 'Tallenna PDF';

  @override
  String get reportDate => 'HAKUPÄIVÄ';

  @override
  String get reportCompany => 'YRITYS';

  @override
  String get reportPosition => 'TEHTÄVÄ';

  @override
  String get reportStatus => 'TILA';

  @override
  String get reportRejectionReason => 'HYLKÄYSSYY';

  @override
  String get settingsLanguageTitle => 'Kieli';

  @override
  String get settingsAppLanguage => 'Sovelluksen kieli';

  @override
  String get settingsDesignTitle => 'Ulkoasu ja mukauttaminen';

  @override
  String get settingsDesignMode => 'Teematila';

  @override
  String get settingsAccentColorTitle => 'Aksenttiväri';

  @override
  String get settingsPresetTheme => 'Valmis teema';

  @override
  String get settingsPresetDesc => 'Valmiit teemayhdistelmät';

  @override
  String get settingsJobcenterTitle => 'Jobcenter-tila';

  @override
  String get settingsJobcenterDesc =>
      'Näyttää \'Todistus työnhakuaktiivisuudesta\' -välilehden';

  @override
  String get settingsFieldTitle => 'Ammattialasi ja omat sarakkeet';

  @override
  String get settingsFieldSelect => 'Valitse ammattiala';

  @override
  String get settingsCustomCols => 'Omat sarakkeet (pilkulla erotettuna)';

  @override
  String get settingsPersonalData => 'Henkilötiedot (PDF-vientiä varten)';

  @override
  String get settingsYourName => 'Nimesi';

  @override
  String get settingsYourAddress => 'Osoitteesi';

  @override
  String get dashboardTabWeek => 'Kuluva viikko';

  @override
  String get dashboardTabTotal => 'Kokonaiskatsaus';

  @override
  String get dashboardMsgStart => 'Jokainen matka alkaa yhdellä askeleella!';

  @override
  String get dashboardMsgGood => 'Hyvä alku! Jatka samaan malliin!';

  @override
  String get dashboardMsgStrong => 'Vahvaa suoriutumista tällä viikolla!';

  @override
  String get dashboardMsgFantastic => 'MAHTAVAA TYÖTÄ TÄLLÄ VIIKOLLA!';

  @override
  String get dashboardNewApps => 'UUDET HAKEMUKSET';

  @override
  String get dashboardActiveApps => 'AKTIIVISET HAKEMUKSET';

  @override
  String get dashboardGoal => 'Viikkotavoite: ';

  @override
  String get dashboardThisWeek => 'Tällä viikolla ';

  @override
  String get dashboardFooter =>
      'Jatka samaan malliin! Jokainen askel vie lähemmäs unelmatyötäsi. 🚀';

  @override
  String get dashboardVsLastWeek => ' vs. viime viikkoon ';

  @override
  String get dashboardAppsLabel => ' hakemusta';

  @override
  String get appSearch => 'Hae';

  @override
  String get appSearchHint => 'Hae yritystä, tehtävää, sijaintia...';

  @override
  String get appFilterAll => 'Kaikki';

  @override
  String get appCheckInbox => 'Tarkista saapuneet';

  @override
  String get appEmptyTitle => 'Aika ottaa ensimmäinen askel!';

  @override
  String get appEmptyDesc =>
      'Luo ensimmäinen hakemuksesi ja järjestä polkusi unelmatyöhösi.';

  @override
  String get calClickDetails =>
      'Napsauta korostettua päivää nähdäksesi lisätietoja.';

  @override
  String get calOverdue => 'Myöhässä';

  @override
  String get calFollowUp => 'Seuranta';

  @override
  String get reportGeneratedOn => 'Luotu: ';

  @override
  String get reportNoApps => 'Hakemuksia ei löytynyt.';

  @override
  String get navJobcenter => 'Jobcenter-raportti';

  @override
  String get settingsImapTitle => 'Sähköpostin synkronointi (IMAP)';

  @override
  String get settingsImapDesc =>
      'Vastaanottaa hylkäykset/kutsut automaattisesti';

  @override
  String get settingsImapExp => 'EXPERIMENTAL';

  @override
  String get settingsImapWarning =>
      'Tämä ominaisuus on vielä kehitysvaiheessa. Yritysten nimien ja hakemusten automaattinen tunnistus voi olla epätarkkaa. Tarkista tuodut merkinnät manuaalisesti.';

  @override
  String get settingsImapProvider => 'Palveluntarjoaja';

  @override
  String get settingsImapManual => 'Manuaalinen / Oma palvelin';

  @override
  String get settingsImapServer => 'IMAP-palvelin';

  @override
  String get settingsImapPort => 'Portti';

  @override
  String get settingsImapEmail => 'Sähköpostiosoite';

  @override
  String get settingsImapPassword => 'Salasana (sovellussalasana)';

  @override
  String get settingsImapSave => 'Tallenna tiedot';

  @override
  String get settingsExportTitle => 'Tietojen vienti';

  @override
  String get settingsExportPdf => 'Vie Jobcenter-raportti (PDF)';

  @override
  String get settingsExportCsv => 'Vie CSV-muodossa';

  @override
  String get settingsExportBackup => 'Vie tietokannan varmuuskopio (.sqlite)';

  @override
  String get settingsExportRestore => 'Palauta tietokanta varmuuskopiosta';

  @override
  String get settingsExportRestart =>
      'Huom: Sovelluksen uudelleenkäynnistys vaaditaan tuonnin jälkeen.';

  @override
  String get settingsAppQuit => 'Sulje sovellus';

  @override
  String get appNotFoundTitle => 'Mitään ei löytynyt.';

  @override
  String get appNotFoundDesc =>
      'Näillä suodatinasetuksilla ei löytynyt tuloksia.';

  @override
  String get formTabBasic => 'Perustiedot';

  @override
  String get formTabEmails => 'Sähköpostit ja yhteystiedot';

  @override
  String get formTabDocs => 'Asiakirjat';

  @override
  String get formTabNotes => 'Muistiinpanot';

  @override
  String get formBasicContact => 'Yhteystiedot ja osoite';

  @override
  String get formBasicSave => 'Tallenna';

  @override
  String get formBasicInterview => 'Haastattelu';

  @override
  String get formBasicSalary => 'Palkkatoive (€/vuosi)';

  @override
  String get formBasicOpen => 'Avoin';

  @override
  String get formBasicAccepted => 'Tarjous';

  @override
  String get formBasicRejected => 'Hylätty';

  @override
  String get formBasicJobLink => 'Linkki työpaikkailmoitukseen';

  @override
  String get formBasicJobLinkHint =>
      'Liitä työpaikkalinkki tai lataa PDF (esim. Jobcenter) tietojen poimimiseksi.';

  @override
  String get formBasicAutofill => 'Täytä automaattisesti';

  @override
  String get formBasicCommute => 'Työmatka-aika (min)';

  @override
  String get formBasicRejectionReason => 'Hylkäyssyy';

  @override
  String get formBasicUploadPdf => 'Tai lataa PDF';

  @override
  String get formBasicStatus => 'Tila';

  @override
  String get formBasicCompanyWeb => 'Yrityksen verkkosivusto (esim. https://)';

  @override
  String get formBasicMagic => 'Magic Auto-Fill';

  @override
  String get formBasicDelete => 'Poista';

  @override
  String get formBasicSent => 'Lähetetty';

  @override
  String get reportGeneratedAt => 'Luotu:';

  @override
  String get reportTimeSuffix => '';

  @override
  String get weeklyGoal => 'Viikkotavoite:';

  @override
  String get weeklyGoalSuffix => ' / 5 hakemusta';

  @override
  String get weeklyThisWeek => 'Tällä viikolla ';

  @override
  String get weeklyVs => ' hakemusta vs. viime viikolla ';

  @override
  String get weeklyApplications => ' hakemusta';

  @override
  String get weeklyMotivationalFooter =>
      'Jatka samaan malliin! Jokainen askel vie lähemmäs unelmatyötäsi. 🚀';

  @override
  String get weeklyMotivationalFooterNoIcon =>
      'Jatka samaan malliin! Jokainen askel vie lähemmäs unelmatyötäsi.';

  @override
  String get templatesTabMy => 'Omat mallit';

  @override
  String get templatesTabExamples => 'Mallipohjat ja esimerkit';

  @override
  String get promptTitle => 'AI-kehotegeneraattori';

  @override
  String get promptDesc =>
      'Täytä kentät luodaksesi ammattimaisen kehotteen, jota voit käyttää ChatGPT:ssä, Claudessa tai missä tahansa muussa valitsemassasi tekoälyssä.';

  @override
  String get promptPosition => 'Tehtävä / Työnimike';

  @override
  String get promptCompany => 'Yritys';

  @override
  String get promptSkills => 'Tärkeimmät taitosi ja kokemuksesi';

  @override
  String get promptTone => 'Sävy';

  @override
  String get promptToneDefault => 'ammattimainen ja ystävällinen';

  @override
  String get promptGenerate => 'Luo kehote';

  @override
  String get tplInitiative => 'Avoin hakemus';

  @override
  String get tplReply => 'Vastaus työpaikkailmoitukseen';

  @override
  String get tplFollowUp => 'Muistutus / Seuranta';

  @override
  String get tplRejection => 'Kohtelias vastaus hylkäykseen';

  @override
  String get tplTypeCover => 'SAATEKIRJE';

  @override
  String get tplTypeSnippet => 'TEKSTIKATKELMA';

  @override
  String get noAppsFound => 'Hakemuksia ei löytynyt.';

  @override
  String get templatesEmptyState => 'Malleja ei ole vielä luotu.';

  @override
  String get templatesEmptyStateSub =>
      'Luo ensimmäinen saatekirjeesi tai tekstikatkelmasi!';

  @override
  String get promptSubtitle =>
      'Täytä kentät ja luo ammattimainen kehote, jota voit käyttää ChatGPT:ssä, Claudessa tai missä tahansa muussa valitsemassasi tekoälyssä.';
}
