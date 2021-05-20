#Использовать logos

Перем Лог; // Ссылка на объект Логирование библиотеки logos
Перем ВозможныеКоманды; // Структура с перечнем команд системы

Функция Лог() Экспорт
	
	Если Лог = Неопределено Тогда
		Лог = Логирование.ПолучитьЛог(ИмяЛогаСистемы());
	КонецЕсли;
	
	Возврат Лог;
	
КонецФункции

Функция ИмяСистемы() Экспорт
	
	Возврат "Releaser";
	
КонецФункции

Процедура УстановитьРежимОтладкиПриНеобходимости(Знач РежимОтладки) Экспорт
	
	Если РежимОтладки Тогда
		Лог().УстановитьУровень(УровниЛога.Отладка);
		Лог.Отладка("Установлен уровень логов ОТЛАДКА");
	КонецЕсли;
	
КонецПроцедуры

Функция ИмяЛогаСистемы() Экспорт
	Возврат "oscript.app." + ИмяСистемы();
КонецФункции

Функция Версия() Экспорт
	
	Возврат "0.0.1";
	
КонецФункции

Функция ВозможныеКоманды() Экспорт

	Если ВозможныеКоманды = Неопределено Тогда

		ВозможныеКоманды = Новый Структура;
		ВозможныеКоманды.Вставить("CreateGitLabRelease", "gitlab-release");
		ВозможныеКоманды.Вставить("CreateRelease", "release");
		ВозможныеКоманды.Вставить("Помощь", "help");
		ВозможныеКоманды.Вставить("ПоказатьВерсию", "version");

		ВозможныеКоманды = Новый ФиксированнаяСтруктура(ВозможныеКоманды);

	КонецЕсли;

	Возврат ВозможныеКоманды;

КонецФункции

Процедура ПриРегистрацииКомандПриложения(Знач КлассыРеализацииКоманд) Экспорт

	КлассыРеализацииКоманд[ВозможныеКоманды().Помощь]				= "КомандаСправкаПоПараметрам";
	КлассыРеализацииКоманд[ВозможныеКоманды().ПоказатьВерсию]		= "КомандаVersion";
	КлассыРеализацииКоманд[ВозможныеКоманды().CreateGitLabRelease]	= "КомандаCreateGitLabRelease";
	КлассыРеализацииКоманд[ВозможныеКоманды().CreateRelease]		= "КомандаCreateRelease";

КонецПроцедуры

Процедура ПриРегистрацииГлобальныхПараметровКоманд(Знач Парсер) Экспорт
	Парсер.ДобавитьПараметрФлаг("--debug", "Включение отладки", Истина);
КонецПроцедуры

Функция ИмяКомандыПоУмолчанию() Экспорт
	Возврат ВозможныеКоманды().Помощь;
КонецФункции
