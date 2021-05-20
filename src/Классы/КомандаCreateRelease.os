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

	Ожидаем.Что(КаталогИсходников, "Не указан каталог релизов конфигурации").Заполнено();
	Ожидаем.Что(СтрокаСоединения, "Не указана строка соединения с базой").Заполнено();

	ПоследнийРелиз = ПолучитьКаталогАктуальнойВерсии(КаталогИсходников);
	ПоследнийРелиз = ОбъединитьПути(КаталогИсходников, ПоследнийРелиз);
	Лог.Отладка("Каталог последнего релиза: " + ПоследнийРелиз);
	
	КаталогДляСохранения = ОбщегоНазначения.НовоеИмяРелиза(ПоследнийРелиз);
	КаталогДляСохранения = ОбъединитьПути(КаталогИсходников, КаталогДляСохранения);
	Лог.Отладка("Каталог нового релиза: " + КаталогДляСохранения);
	ФС.ОбеспечитьПустойКаталог(КаталогДляСохранения);

	ПараметрыКоманды = Новый Соответствие;
	ПараметрыКоманды.Вставить("-db-user", ИмяПользователя);
	ПараметрыКоманды.Вставить("-db-pwd", Пароль);
	СтрокаСоединения = ОбщегоНазначения.ПереопределитьПутьКБазе(СтрокаСоединения);
	КомандаУстановитьБазу = СтрШаблон("packman set-database %1", СтрокаСоединения); 
	КомандаУстановитьБазу = УстановитьПараметрыКоманды(КомандаУстановитьБазу, ПараметрыКоманды);
	Лог.Отладка(КомандаУстановитьБазу);
	ОбщегоНазначения.КомандаСистемы(КомандаУстановитьБазу, КаталогДляСохранения);
	Лог.Отладка("Установлена рабочая база");

	ПараметрыКоманды = Новый Соответствие;
	ПараметрыКоманды.Вставить("-cfu-basedir", ПоследнийРелиз);
	ПараметрыКоманды.Вставить("-v8version", ВерсияПлатформы);
	КомандаСоздатьПоставку = СтрШаблон("packman make-cf"); 
	КомандаСоздатьПоставку = УстановитьПараметрыКоманды(КомандаСоздатьПоставку, ПараметрыКоманды);
	Лог.Отладка(КомандаСоздатьПоставку);
	ОбщегоНазначения.КомандаСистемы(КомандаСоздатьПоставку, КаталогДляСохранения);
	
	ПереместитьФайлыСборки(КаталогДляСохранения);
	УдалитьСлужебныеФайлыПакман(КаталогДляСохранения);

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

Функция УстановитьПараметрыКоманды(СтрокаКоманды, Знач ПараметрыКоманды)

	МассивСтрок = Новый Массив;
	МассивСтрок.Добавить(СтрокаКоманды);
	Для каждого КлючИЗначение Из ПараметрыКоманды Цикл
		Если ЗначениеЗаполнено(КлючИЗначение.Значение) Тогда
			МассивСтрок.Добавить(КлючИЗначение.Ключ);
			МассивСтрок.Добавить("""" + КлючИЗначение.Значение + """");
		КонецЕсли;
	КонецЦикла;

	Возврат СтрСоединить(МассивСтрок, " ");
	
КонецФункции

Процедура ПереместитьФайлыСборки(Знач КаталогДляСохранения)

	РабочийКаталогПакман = РабочийКаталогПакман(КаталогДляСохранения);

	Если ФС.ФайлСуществует(РабочийКаталогПакман + "/1cv8.cf") Тогда
		ПереместитьФайл(РабочийКаталогПакман + "/1cv8.cf", КаталогДляСохранения + "/1cv8.cf")
	КонецЕсли;

	Если ФС.ФайлСуществует(РабочийКаталогПакман + "/1cv8.cfu") Тогда
		ПереместитьФайл(РабочийКаталогПакман + "/1cv8.cfu", КаталогДляСохранения + "/1cv8.cfu")
	КонецЕсли;
	
КонецПроцедуры

Процедура УдалитьСлужебныеФайлыПакман(Знач КаталогДляСохранения)

	РабочийКаталогПакман = РабочийКаталогПакман(КаталогДляСохранения);
	Если ФС.КаталогСуществует(РабочийКаталогПакман) Тогда
		УдалитьФайлы(РабочийКаталогПакман);
	КонецЕсли; 
	
КонецПроцедуры

Функция РабочийКаталогПакман(Знач Путь)
	Возврат ОбъединитьПути(Путь, ".packman");	
КонецФункции