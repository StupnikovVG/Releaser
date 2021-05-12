///////////////////////////////////////////////////////////////////
//
// Служебный модуль с реализацией работы команды gitlab
//
// Структура модуля реализована в соответствии с рекомендациями 
// oscript-app-template (C) EvilBeaver
//
///////////////////////////////////////////////////////////////////

#Использовать fs
#Использовать logos

Перем Лог;

Функция ПолучитьЛог()
	Если Лог = Неопределено Тогда
		Лог = Логирование.ПолучитьЛог(ПараметрыСистемы.ИмяЛогаСистемы());
	КонецЕсли;
	Возврат Лог;
КонецФункции

Процедура ЗарегистрироватьКоманду(Знач ИмяКоманды, Знач Парсер) Экспорт

	ОписаниеКоманды = Парсер.ОписаниеКоманды(ИмяКоманды, "     Интеграция с gitlab");
	Парсер.ДобавитьКоманду(ОписаниеКоманды);

КонецПроцедуры // ЗарегистрироватьКоманду

// Выполняет логику команды
// 
// Параметры:
//   ПараметрыКоманды - Соответствие - Соответствие ключей командной строки и их значений
//   ДополнительныеПараметры - Соответствие - дополнительные параметры (необязательно)
//
// Возвращаемое значение:
//   Число - результат выполнения команды
//
Функция ВыполнитьКоманду(Знач ПараметрыКоманды, Знач ДополнительныеПараметры) Экспорт

	Лог = ПолучитьЛог();
	Лог.Отладка("Команда gitlab");
	Для каждого Параметр Из ПараметрыКоманды Цикл
		Лог.Отладка(Параметр.Ключ + " " + Параметр.значение);
	КонецЦикла;

	АдресСервера = ПараметрыКоманды["--server"];
	Токен = ПараметрыКоманды["--token"];
	Проект = ПараметрыКоманды["--project-id"];

	ГитЛаб = Новый gitlab(АдресСервера, Токен);

	КаталогДляСохранения = ОбъединитьПути(КаталогВременныхФайлов(), "release");
	ОбеспечитьПустойКаталог(КаталогДляСохранения);

	ГитЛаб.ПолучитьПоследнийРелиз(КаталогДляСохранения, Проект);

	Возврат МенеджерКомандПриложения.РезультатыКоманд().Успех;

КонецФункции // ВыполнитьКоманду
