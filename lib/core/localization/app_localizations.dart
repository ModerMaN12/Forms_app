import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  bool get _isRu => locale.languageCode == 'ru';

  String _t(String en, String ru) => _isRu ? ru : en;

  // ─── App ───
  String get appName => _t('Survey App', 'Опросник');
  String get offline => _t('Offline', 'Офлайн');
  String get loading => _t('Loading...', 'Загрузка...');
  String get error => _t('Error', 'Ошибка');
  String get retry => _t('Retry', 'Повторить');
  String get noData => _t('No data', 'Нет данных');
  String get back => _t('Back', 'Назад');
  String get save => _t('Save', 'Сохранить');
  String get delete => _t('Delete', 'Удалить');
  String get cancel => _t('Cancel', 'Отмена');
  String get close => _t('Close', 'Закрыть');
  String get confirm => _t('Confirm', 'Подтвердить');
  String get warning => _t('Warning!', 'Внимание!');

  // ─── Auth ───
  String get email => _t('Email', 'Эл. почта');
  String get emailHint => _t('Enter email', 'Введите почту');
  String get password => _t('Password', 'Пароль');
  String get passwordHint => _t('Enter password', 'Введите пароль');
  String get name => _t('Name', 'Имя');
  String get nameHint => _t('Enter name', 'Введите имя');
  String get login => _t('Login', 'Войти');
  String get register => _t('Register', 'Регистрация');
  String get loginTitle => _t('Login', 'Вход');
  String get registerTitle => _t('Register', 'Регистрация');
  String get noAccount => _t("Don't have an account? Register", 'Нет аккаунта? Зарегистрироваться');
  String get or => _t('or', 'или');
  String get continueOffline => _t('Continue Offline', 'Продолжить офлайн');
  String get emailAlreadyRegistered => _t('Email already registered', 'Почта уже зарегистрирована');
  String get invalidCredentials => _t('Invalid email or password', 'Неверная почта или пароль');
  String get minPasswordLength => _t('Min 6 characters', 'Минимум 6 символов');
  String get required => _t('Required', 'Обязательно');

  // ─── Home (Online) ───
  String get surveys => _t('Surveys', 'Опросы');
  String get localSurveys => _t('Local Surveys', 'Локальные опросы');
  String get noSurveysYet => _t('No surveys yet', 'Ещё нет опросов');
  String get createFirstSurvey => _t('Tap + to create your first survey', 'Нажмите + чтобы создать опрос');
  String get createLocalSurveyHint => _t('Tap + to create a survey offline', 'Нажмите + чтобы создать опрос офлайн');
  String get noLocalSurveys => _t('No local surveys', 'Нет локальных опросов');
  String get active => _t('Active', 'Активен');
  String get draft => _t('Draft', 'Черновик');
  String get questions => _t('questions', 'вопросов');
  String get responses => _t('responses', 'ответов');
  String get questionsCap => _t('Questions', 'Вопросы');
  String get responsesCap => _t('Responses', 'Ответы');

  // ─── Survey Detail ───
  String get description => _t('Description', 'Описание');
  String get noDescription => _t('No description', 'Нет описания');
  String get accessType => _t('Access', 'Доступ');
  String get anonymous => _t('Anonymous (optional name)', 'Анонимно (имя опционально)');
  String get authenticated => _t('Authenticated only', 'Только авторизованные');
  String get status => _t('Status', 'Статус');
  String get published => _t('Published', 'Опубликован');
  String get publish => _t('Publish', 'Опубликовать');
  String get surveyPublished => _t('Survey published!', 'Опрос опубликован!');
  String get results => _t('Results', 'Результаты');
  String get shareLink => _t('Share Link', 'Поделиться ссылкой');
  String get takeSurvey => _t('Take Survey', 'Пройти опрос');
  String get surveyDeleted => _t('Survey deleted', 'Опрос удалён');
  String get deleteSurveyConfirm => _t('Are you sure? This will delete all responses too.', 'Вы уверены? Это также удалит все ответы.');
  String get deleteSurveyLocalConfirm => _t('Delete this local survey and all its responses?', 'Удалить этот локальный опрос и все ответы?');

  // ─── Create/Edit Survey ───
  String get createSurvey => _t('Create Survey', 'Создать опрос');
  String get createLocalSurvey => _t('Create Local Survey', 'Создать локальный опрос');
  String get editSurvey => _t('Edit Survey', 'Редактировать опрос');
  String get surveyTitle => _t('Survey Title', 'Название опроса');
  String get surveyDescription => _t('Description', 'Описание');
  String get addQuestion => _t('Add question', 'Добавить вопрос');
  String get addAtLeastOne => _t('Add at least one question', 'Добавьте хотя бы один вопрос');
  String get saveChanges => _t('Save Changes', 'Сохранить изменения');
  String get createSurveyBtn => _t('Create Survey', 'Создать опрос');
  String get createSurveyOffline => _t('Create Survey (Offline)', 'Создать опрос (офлайн)');
  String get newQuestion => _t('New Question', 'Новый вопрос');
  String get option => _t('Option', 'Вариант');
  String get addOption => _t('Add option', 'Добавить вариант');
  String get warningResponsesExist => _t(
    'This survey already has responses. Editing questions will DELETE all previous responses. Continue?',
    'У этого опроса уже есть ответы. Редактирование вопросов УДАЛИТ все предыдущие ответы. Продолжить?',
  );
  String get warningResponsesLocal => _t(
    'This survey has @count response(s). Editing questions will delete all previous responses. Continue?',
    'У этого опроса @count ответ(ов). Редактирование вопросов удалит все предыдущие ответы. Продолжить?',
  );
  String get deleteUpdate => _t('Delete & Update', 'Удалить и обновить');

  // ─── Question Types ───
  String get singleChoice => _t('Single Choice', 'Один вариант');
  String get multipleChoice => _t('Multiple Choice', 'Несколько вариантов');
  String get textQuestion => _t('Text', 'Текст');
  String get rating => _t('Rating (1-5)', 'Рейтинг (1-5)');
  String get scale => _t('Scale (1-10)', 'Шкала (1-10)');

  // ─── Take Survey ───
  String get yourNameOptional => _t('Your name (optional)', 'Ваше имя (необязательно)');
  String get typeYourAnswer => _t('Type your answer...', 'Введите ответ...');
  String get submit => _t('Submit', 'Отправить');
  String get thankYou => _t('Thank You!', 'Спасибо!');
  String get responseSubmitted => _t('Your response has been submitted.', 'Ваш ответ отправлен.');
  String get responseSavedLocal => _t('Your response has been saved locally.', 'Ваш ответ сохранён локально.');
  String get isRequired => _t('is required', 'обязателен');

  // ─── Results ───
  String get totalResponses => _t('Total Responses', 'Всего ответов');
  String get answers => _t('answers', 'ответов');
  String get average => _t('Average:', 'Среднее:');
  String get noResponsesYet => _t('No responses yet', 'Пока нет ответов');
  String get recentResponses => _t('Recent Responses', 'Последние ответы');
  String get exportCSV => _t('Export CSV', 'Экспорт CSV');

  // ─── Profile ───
  String get profile => _t('Profile', 'Профиль');
  String get logout => _t('Logout', 'Выйти');
  String get language => _t('Language', 'Язык');
  String get english => _t('English', 'Английский');
  String get russian => _t('Russian', 'Русский');

  // ─── Question Editor ───
  String get requiredToggle => _t('Required', 'Обязательный');
  String get remove => _t('Remove', 'Удалить');

  // ─── Share ───
  String get shareLinkCopied => _t('Share link: @url', 'Ссылка: @url');

  // ─── Connection ───
  String get connectionError => _t('Connection error. Please check server.', 'Ошибка соединения. Проверьте сервер.');
  String get surveyNotFound => _t('Survey not found', 'Опрос не найден');
  String get surveyNotFoundInactive => _t('Survey not found or inactive', 'Опрос не найден или неактивен');
}
