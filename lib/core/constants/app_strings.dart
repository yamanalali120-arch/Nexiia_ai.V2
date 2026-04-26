// ════════════════════════════════════════════════════════════════
// NEXIIA — UI Strings (German)
// ════════════════════════════════════════════════════════════════
//
// All user-facing text in one place.
// Benefits:
//   • Consistency — same wording everywhere
//   • Easy to update — change once, applies everywhere
//   • i18n-ready — swap this file for other languages later
//   • No typos — IDE autocomplete instead of typing strings
//
// Rules:
//   • Every string the user sees comes from here
//   • Never hardcode UI text in widgets
//   • Keep text short, clear, and premium
//   • German language — warm but professional
// ════════════════════════════════════════════════════════════════

class AppStrings {
  AppStrings._();

  // ──────────────────────────────────────────
  // APP
  // ──────────────────────────────────────────

  static const String appName = 'Nexiia';
  static const String appTagline = 'Deine persönliche Assistenz';

  // ──────────────────────────────────────────
  // SPLASH
  // ──────────────────────────────────────────

  static const String splashWordmark = 'nexiia';

  // ──────────────────────────────────────────
  // LOGIN
  // ──────────────────────────────────────────

  static const String loginHeadline = 'Willkommen zurück';
  static const String loginSubtext = 'Schön, dass du wieder da bist.';
  static const String loginButton = 'Anmelden';
  static const String loginForgotPassword = 'Passwort vergessen?';
  static const String loginNoAccount = 'Noch kein Konto?';
  static const String loginNoAccountAction = 'Jetzt registrieren';
  static const String loginMagicLink = 'Mit Magic Link anmelden';

  // ──────────────────────────────────────────
  // SIGNUP
  // ──────────────────────────────────────────

  static const String signupHeadline = 'Konto erstellen';
  static const String signupSubtext = 'Starte deine Reise mit Nexiia.';
  static const String signupButton = 'Konto erstellen';
  static const String signupHasAccount = 'Bereits registriert?';
  static const String signupHasAccountAction = 'Anmelden';
  static const String signupTermsPrefix = 'Ich akzeptiere die ';
  static const String signupTermsLink = 'Nutzungsbedingungen';
  static const String signupTermsMiddle = ' und die ';
  static const String signupPrivacyLink = 'Datenschutzerklärung';
  static const String signupTermsSuffix = '.';

  // ──────────────────────────────────────────
  // AUTH — Shared
  // ──────────────────────────────────────────

  static const String emailLabel = 'E-Mail';
  static const String emailHint = 'deine@email.de';
  static const String passwordLabel = 'Passwort';
  static const String passwordHint = 'Dein Passwort';
  static const String passwordConfirmLabel = 'Passwort wiederholen';
  static const String passwordConfirmHint = 'Passwort erneut eingeben';
  static const String orDivider = 'oder';
  static const String continueWithApple = 'Mit Apple fortfahren';
  static const String continueWithGoogle = 'Mit Google fortfahren';

  // ──────────────────────────────────────────
  // VALIDATION
  // ──────────────────────────────────────────

  static const String validationEmailRequired = 'Bitte gib deine E-Mail ein.';
  static const String validationEmailInvalid =
      'Bitte gib eine gültige E-Mail ein.';
  static const String validationPasswordRequired =
      'Bitte gib ein Passwort ein.';
  static const String validationPasswordTooShort =
      'Mindestens 8 Zeichen erforderlich.';
  static const String validationPasswordMismatch =
      'Passwörter stimmen nicht überein.';
  static const String validationTermsRequired =
      'Bitte akzeptiere die Nutzungsbedingungen.';

  // ──────────────────────────────────────────
  // PASSWORD STRENGTH
  // ──────────────────────────────────────────

  static const String strengthWeak = 'Schwach';
  static const String strengthFair = 'Mittel';
  static const String strengthStrong = 'Stark';
  static const String strengthVeryStrong = 'Sehr stark';

  // ──────────────────────────────────────────
  // ERROR MESSAGES — Supabase Mapped
  // ──────────────────────────────────────────

  static const String errorInvalidCredentials =
      'E-Mail oder Passwort ist falsch.';
  static const String errorUserAlreadyExists =
      'Diese E-Mail ist bereits registriert.';
  static const String errorPasswordTooShort =
      'Passwort muss mindestens 8 Zeichen haben.';
  static const String errorEmailNotConfirmed =
      'Bitte bestätige zuerst deine E-Mail.';
  static const String errorTooManyRequests =
      'Zu viele Versuche. Bitte warte kurz.';
  static const String errorNoConnection =
      'Keine Verbindung. Bitte prüfe dein Internet.';
  static const String errorUnknown = 'Ein unerwarteter Fehler ist aufgetreten.';
  static const String errorSignupFailed =
      'Registrierung fehlgeschlagen. Bitte versuche es erneut.';

  // ──────────────────────────────────────────
  // FORGOT PASSWORD
  // ──────────────────────────────────────────

  static const String forgotPasswordHeadline = 'Passwort zurücksetzen';
  static const String forgotPasswordSubtext =
      'Gib deine E-Mail ein und wir senden dir einen Link.';
  static const String forgotPasswordButton = 'Link senden';
  static const String forgotPasswordSuccess =
      'Link gesendet! Bitte prüfe dein Postfach.';
  static const String forgotPasswordBack = 'Zurück zur Anmeldung';

  // ──────────────────────────────────────────
  // SIGNUP SUCCESS
  // ──────────────────────────────────────────

  static const String signupSuccessHeadline = 'Fast geschafft!';
  static const String signupSuccessSubtext =
      'Wir haben dir eine Bestätigungs-E-Mail gesendet. '
      'Bitte öffne den Link in der E-Mail, um dein Konto zu aktivieren.';
  static const String signupSuccessButton = 'Zurück zur Anmeldung';

  // ──────────────────────────────────────────
  // GREETING (Post-Auth)
  // ──────────────────────────────────────────

  static const String greetingLine1 = 'Hallo, ich bin Nexiia.';
  static const String greetingLine2 = 'Deine persönliche Assistenz.';
  static const String greetingLine3 =
      'Ich helfe dir, Klarheit, Fokus und Struktur '
      'in deinen Alltag zu bringen.';
  static const String greetingContinue = 'Weiter';

  // ──────────────────────────────────────────
  // NAME INPUT
  // ──────────────────────────────────────────

  static const String nameHeadline = 'Wie soll ich dich nennen?';
  static const String nameHint = 'Dein Name';
  static const String nameContinue = 'Weiter';

  // ──────────────────────────────────────────
  // ATMOSPHERE SELECTION
  // ──────────────────────────────────────────

  static const String atmosphereHeadline = 'Wähle deine Atmosphäre';
  static const String atmosphereSubtext = 'Du kannst sie jederzeit ändern.';
  static const String atmosphereContinue = 'Weiter';

  static const String atmosphereTechFuture = 'TECH FUTURE';
  static const String atmosphereTechFutureDesc = 'Präzise. Klar. Smart.';

  static const String atmosphereLuxusPremium = 'LUXUS PREMIUM';
  static const String atmosphereLuxusPremiumDesc = 'Exklusiv. Edel. Stark.';

  static const String atmosphereCalm = 'CALM';
  static const String atmosphereCalmDesc = 'Ruhig. Sanft. Klar.';

  static const String atmosphereSpiritual = 'SPIRITUAL';
  static const String atmosphereSpiritualDesc =
      'Tiefgründig. Bewusst. Achtsam.';

  static const String atmosphereLifestyle = 'LIFESTYLE';
  static const String atmosphereLifestyleDesc =
      'Lebendig. Kreativ. Inspiriert.';

  // ──────────────────────────────────────────
  // ONBOARDING INTRO (3 Screens)
  // ──────────────────────────────────────────

  static const String introSkip = 'Überspringen';

  static const String intro1Headline = 'Dein intelligenter Begleiter';
  static const String intro1Text =
      'Nexiia denkt mit dir. Strukturiert Probleme. '
      'Findet Lösungen. Erinnert dich an das Wichtige.';

  static const String intro2Headline = 'Dein Tag. Klar strukturiert.';
  static const String intro2Text =
      'Termine, Erinnerungen und Fokus — '
      'alles an einem Ort. Ruhig und übersichtlich.';

  static const String intro3Headline = 'Bereit für Klarheit?';
  static const String intro3Text =
      'Nexiia passt sich dir an. Je mehr du sie nutzt, '
      'desto besser versteht sie dich.';
  static const String intro3Button = 'Los geht\'s';

  // ──────────────────────────────────────────
  // HOME — Greeting
  // ──────────────────────────────────────────

  static const String homeMorning = 'Guten Morgen';
  static const String homeAfternoon = 'Guten Tag';
  static const String homeEvening = 'Guten Abend';
  static const String homeNight = 'Hallo';
  static const String homeNexiiaReady = 'Nexiia ist bereit.';

  // ──────────────────────────────────────────
  // HOME — Hero Card
  // ──────────────────────────────────────────

  static const String heroTitle = 'Neues Problem lösen';
  static const String heroSubtext =
      'Beschreibe, was dich beschäftigt — '
      'ich helfe dir, es zu ordnen.';
  static const String heroButton = 'Starten';

  // ──────────────────────────────────────────
  // HOME — Quick Actions
  // ──────────────────────────────────────────

  static const String quickActionCalendar = 'Termin\nplanen';
  static const String quickActionReminder = 'Erinnerung\nerstellen';
  static const String quickActionFocus = 'Fokus\nsetzen';

  // ──────────────────────────────────────────
  // HOME — Smart Snapshot
  // ──────────────────────────────────────────

  static const String snapshotTitle = 'Dein Tag auf einen Blick';
  static const String snapshotEmpty = 'Noch keine Termine heute.';
  static const String snapshotEmptyAction =
      'Tippe auf 📅 um deinen ersten Termin zu planen.';
  static const String snapshotOpenDay = 'Tagesübersicht öffnen';

  // ──────────────────────────────────────────
  // BOTTOM NAVIGATION
  // ──────────────────────────────────────────

  static const String navHome = 'Home';
  static const String navChat = 'Chat';
  static const String navSolve = 'Lösen';
  static const String navCalendar = 'Kalender';
  static const String navFocus = 'Fokus';

  // ──────────────────────────────────────────
  // GENERAL
  // ──────────────────────────────────────────

  static const String generalContinue = 'Weiter';
  static const String generalCancel = 'Abbrechen';
  static const String generalSave = 'Speichern';
  static const String generalDelete = 'Löschen';
  static const String generalEdit = 'Bearbeiten';
  static const String generalDone = 'Fertig';
  static const String generalClose = 'Schließen';
  static const String generalRetry = 'Erneut versuchen';
  static const String generalLoading = 'Laden...';
}
