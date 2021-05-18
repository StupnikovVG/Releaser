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

	ОписаниеКоманды = Парсер.ОписаниеКоманды(ИмяКоманды, "     Создание файлов поставки cf, cfu");
	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, "--releases-dir", "Каталог с файлами релизов");
	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, "--ibconnection", "Строка подключения к базе");
	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, "--db-user", "Имя пользователя БД");
	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, "--db-pwd", "Пароль пользователя БД");
	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, "--v8version", "Используемая версия 1С");

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
	Лог.Отладка("Команда создания релиза");

	Для каждого Параметр Из ПараметрыКоманды Цикл
		Лог.Отладка(Параметр.Ключ + " " + Параметр.значение);
	КонецЦикла;

	КаталогИсходников = ПараметрыКоманды["--releases-dir"];
	СтрокаСоединения = ПараметрыКоманды["--ibconnection"];
	ИмяПользователя = ПараметрыКоманды["--db-user"];
	Пароль = ПараметрыКоманды["--db-pwd"];
	ВерсияПлатформы = ПараметрыКоманды["--v8version"];

	ПоследнийРелиз = ПолучитьКаталогАктуальнойВерсии(КаталогИсходников);
	Лог.Отладка("Каталог последнего релиза: " + ПоследнийРелиз);
	КаталогДляСохранения = ПараметрыСистемы.НовоеИмяРелиза(ПоследнийРелиз);
	Лог.Отладка("Каталог нового релиза: " + КаталогДляСохранения);
	ФС.ОбеспечитьПустойКаталог(КаталогДляСохранения);

	КомандаУстановитьРабочийКаталог = СтрШаблон("SET VPACKMAN_WORKDIR = %1", КаталогДляСохранения); 
	КомандаСистемы(КомандаУстановитьРабочийКаталог);
	Лог.Отладка("Установлен рабочий каталог: " + КаталогДляСохранения);

	ПараметрыКоманды = Новый Структура;
	ПараметрыКоманды.Вставить("-db-user", ИмяПользователя);
	ПараметрыКоманды.Вставить("-db-pwd", Пароль);
	КомандаУстановитьБазу = СтрШаблон("packman set-database %1", СтрокаСоединения);
	КомандаУстановитьБазу = УстановитьПараметрыКоманды(КомандаУстановитьБазу, ПараметрыКоманды);
	КомандаСистемы(КомандаУстановитьБазу);
	Лог.Отладка("Установлена рабочая база");

	ПараметрыКоманды = Новый Структура;
	ПараметрыКоманды.Вставить("-cfu-basedir", ПоследнийРелиз);
	ПараметрыКоманды.Вставить("-v8version", ВерсияПлатформы);
	КомандаСоздатьПоставку = СтрШаблон("packman make-cf"); 
	КомандаСоздатьПоставку = УстановитьПараметрыКоманды(КомандаСоздатьПоставку, ПараметрыКоманды);
	КомандаСистемы(КомандаСоздатьПоставку);
	Лог.Информация("Созданы файлы поставки в каталоге " + КаталогДляСохранения);

	Возврат МенеджерКомандПриложения.РезультатыКоманд().Успех;

КонецФункции // ВыполнитьКоманду

Функция ПолучитьКаталогАктуальнойВерсии(Знач Путь)
	
	Каталоги = НайтиФайлы(Путь, "*.*");
	АктуальнаяВерсия = Путь;
	Для каждого Каталог Из Каталоги Цикл
		АктуальнаяВерсия = Каталог.Имя;	
	КонецЦикла;

	Возврат АктуальнаяВерсия;
	
КонецФункции


Функция КомандаСистемы(СтрокаЗапуска) // todo Общий метод или класс.

	Команда = Новый Команда;
	Команда.УстановитьПравильныйКодВозврата(0);
	Команда.ПоказыватьВыводНемедленно(Ложь);
	Команда.УстановитьСтрокуЗапуска(СтрокаЗапуска);
	КодВозврата = Команда.Исполнить();
	Результат = Команда.ПолучитьВывод();
	Если КодВозврата <> 0 Тогда
		ВызватьИсключение СтрШаблон("Код возврата не равен 0, а равен %1", КодВозврата);
	КонецЕсли;
	
	Возврат Результат;

КонецФункции

Функция УстановитьПараметрыКоманды(СтрокаКоманды, Знач ПараметрыКоманды)

	МассивСтрок = Новый Массив;
	МассивСтрок.Добавить(СтрокаКоманды);
	Для каждого КлючИЗначение Из ПараметрыКоманды Цикл
		Если ЗначениеЗаполнено(КлючИЗначение.Значение) Тогда
			МассивСтрок.Добавить(КлючИЗначение.Ключ);
			МассивСтрок.Добавить(КлючИЗначение.Значение);
		КонецЕсли;
	КонецЦикла;

	Возврат СтрСоединить(МассивСтрок, " ");
	
КонецФункции