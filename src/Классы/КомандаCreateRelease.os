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
	КаталогДляСохранения = ПараметрыСистемы.НовоеИмяРелиза(ПоследнийРелиз);
	ФС.ОбеспечитьПустойКаталог(КаталогДляСохранения);

	КомандаУстановитьРабочийКаталог = СтрШаблон("SET VPACKMAN_WORKDIR = %1", КаталогДляСохранения); 
	ВыполнитьКоманду(КомандаУстановитьБазу);
	КомандаУстановитьБазу = СтрШаблон("packman set-database %1 -db-user %2 -db-pwd %3", 
									СтрокаСоединения, ИмяПользователя, Пароль); // todo пользователь и пароль могут быть пустыми
	ВыполнитьКоманду(КомандаУстановитьБазу);
	КомандаСоздатьПоставку = СтрШаблон("packman make-cf -cfu-basedir %1 -v8version %2", 
									ПоследнийРелиз, ВерсияПлатформы); // todo версия платформы может быть не задана
	ВыполнитьКоманду(КомандаСоздатьПоставку);

	Возврат МенеджерКомандПриложения.РезультатыКоманд().Успех;

КонецФункции // ВыполнитьКоманду

Функция ПолучитьКаталогАктуальнойВерсии(Знач Путь)
	
	Каталоги = НайтиФайлы(Путь);
	АктуальнаяВерсия = Путь;
	Для каждого Каталог Из Каталоги Цикл
		АктуальнаяВерсия = Каталог.Имя;	
	КонецЦикла;

	Возврат АктуальнаяВерсия;
	
КонецФункции


Функция ВыполнитьКоманду(СтрокаЗапуска) // todo Общий метод или класс.

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