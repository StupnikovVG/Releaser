#Использовать cmdline
#Использовать fs
#Использовать logos
#Использовать json

Перем Лог;
Перем Сервер;
Перем Токен;
Перем Соединение;

Процедура ПриСозданииОбъекта(АдресСервера, ТокенАутентификации = "")
	
	Лог = ПолучитьЛог();
	Сервер = АдресСервера;
	Токен = ТокенАутентификации;
	
КонецПроцедуры

Функция ПолучитьЛог()
	
	Если Лог = Неопределено Тогда
		Лог = Логирование.ПолучитьЛог(ПараметрыСистемы.ИмяЛогаСистемы());
	КонецЕсли;
	Возврат Лог;
	
КонецФункции

Функция НовыйСоединение()
	
	Если Соединение = Неопределено Тогда
		Таймаут = 60;
		Соединение = Новый HTTPСоединение(Сервер, , , , , Таймаут);
	КонецЕсли;
	
	Возврат Соединение;
	
КонецФункции

Функция ПолучитьНомерПоследнегоРелиза(Знач ИДПроекта) Экспорт
	
	ПоследнийРелиз = ПолучитьПоследнийРелиз(ИДПроекта);
	Возврат ПоследнийРелиз["tag_name"];
	
КонецФункции

Процедура ПолучитьФайлПоследнегоРелиза(Знач КаталогСохранения, Знач ИДПроекта) Экспорт
	
	ПоследнийРелиз = ПолучитьПоследнийРелиз(ИДПроекта);
	Если ПоследнийРелиз["assets"] <> Неопределено
		И ПоследнийРелиз["assets"]["links"] <> Неопределено Тогда
		Для каждого ВложенныйФайл Из ПоследнийРелиз["assets"]["links"] Цикл
			Соединение = НовыйСоединение();
			Заголовки = ЗаголовкиЗапроса();
			Запрос = Новый HTTPЗапрос(ВложенныйФайл["url"], Заголовки);
			Ответ = Соединение.Получить(Запрос);
			Ожидаем.Что(Ответ.КодСостояния, "Не удалось получить артефакт релиза проекта").Равно(200);
			
			ИмяФайла = ОбъединитьПути(КаталогСохранения, ВложенныйФайл["name"]) + ".cf";
			Лог.Отладка(ИмяФайла);
			ФайлРелиза = Ответ.ПолучитьТелоКакДвоичныеДанные();
			ФайлРелиза.Записать(ИмяФайла);
		КонецЦикла;
	КонецЕсли;
	
КонецПроцедуры

Функция ПолучитьПоследнийРелиз(Знач ИДПроекта) Экспорт
	
	ТекстЗапроса = СтрШаблон("/api/v4/projects/%1/releases", ИДПроекта);
	
	Ответ = ВыполнитьHTTPЗапрос(ТекстЗапроса, "GET");

	Ожидаем.Что(Ответ.КодСостояния, "Не удалось получить данные релизов проекта").Равно(200);
	
	СтруктураОтвета = ПреобразоватьОтветВJSON(Ответ);

	Если СтруктураОтвета.Количество() = 0 Тогда
		Лог.Информация("Не найдено релизов проекта.");
		Возврат "";
	КонецЕсли;
	
	Возврат СтруктураОтвета[0];
	
КонецФункции

Процедура СоздатьРелиз(Знач ИДПроекта, Знач ИмяРелиза, Знач ИмяВетки, Знач ИмяМэйлстоуна = Неопределено) Экспорт
	
	ТекстЗапроса = СтрШаблон("/api/v4/projects/%1/releases?tag_name=%2&ref=%3", ИДПроекта, ИмяРелиза, ИмяВетки);
	Если НЕ ПустаяСтрока(ИмяМэйлстоуна) Тогда
		ТекстЗапроса = ТекстЗапроса + СтрШаблон("&milestones=%1", ИмяМэйлстоуна);
	КонецЕсли;
	
	Ответ = ВыполнитьHTTPЗапрос(ТекстЗапроса, "POST");

	Лог.Отладка(Ответ.ПолучитьТелоКакСтроку());
	Ожидаем.Что(Ответ.КодСостояния, "Не удалось создать релиз проекта").Равно(201);
	
КонецПроцедуры

Функция СоздатьМэйлстоун(Знач ИДПроекта, Знач ИмяМэйлстоуна) Экспорт
	
	ТекстЗапроса = СтрШаблон("/api/v4/projects/%1/milestones?title=%2", ИДПроекта, ИмяМэйлстоуна);
	
	Ответ = ВыполнитьHTTPЗапрос(ТекстЗапроса, "POST");

	Ожидаем.Что(Ответ.КодСостояния, "Не удалось создать мэйлстоун проекта").Равно(201);
	
	СтруктураОтвета = ПреобразоватьОтветВJSON(Ответ);
	
	Возврат СтруктураОтвета.id;
	
КонецФункции

Процедура ПривязатьЗадачиКМэйлстоуну(Знач ПроектИД, Знач МэйлстоунИД, Знач ПараметрыОтбора) Экспорт
	
	МассивПараметров = Новый Массив;
	Для каждого КлючИЗначение Из ПараметрыОтбора Цикл
		МассивПараметров.Добавить(СтрШаблон("%1=%2", КлючИЗначение.Ключ, КлючИЗначение.Значение));
	КонецЦикла;
	
	СтрокаПараметры = СтрСоединить(МассивПараметров, "&");
	
	ТекстЗапроса = СтрШаблон("/api/v4/issues?%1", СтрокаПараметры);
	
	Ответ = ВыполнитьHTTPЗапрос(ТекстЗапроса, "GET");
	Ожидаем.Что(Ответ.КодСостояния, "Не удалось получить данные задачи по параметрам отбора").Равно(200);

	СтруктураОтвета = ПреобразоватьОтветВJSON(Ответ);
	
	Для каждого ДанныеЗадачи Из СтруктураОтвета Цикл
		ТекстЗапроса = СтрШаблон("/api/v4/projects/%1/issues/%2?milestone_id=%3", 
						ПроектИД, ДанныеЗадачи.id, МэйлстоунИД);	
		Ответ = ВыполнитьHTTPЗапрос(ТекстЗапроса, "PUT");
		Ожидаем.Что(Ответ.КодСостояния, "Не удалось установить мэйлстоун задаче").Равно(200);
	
	КонецЦикла;
	
КонецПроцедуры

Функция ЗагрузитьФайл(Знач ПутьКФайлу, Знач ИДПроекта) Экспорт
	
	// получилось загрузить файл только через curl
	
	СтрокаЗапуска = "curl --request POST --header ""PRIVATE-TOKEN: %1"" --form ""file=@%2"" ""http://%3/api/v4/projects/%4/uploads""";
	СтрокаЗапуска = СтрШаблон(СтрокаЗапуска, Токен, ПутьКФайлу, Сервер, ИДПроекта);
	
	Лог.Отладка(СтрокаЗапуска);
	
	Результат = ОбщегоНазначения.ВыполнитьКоманду(СтрокаЗапуска);
	Лог.Отладка(Результат);
	
	ОтветСервера = Лев(Результат, СтрНайти(Результат, "}"));
	
	ПарсерJSON = Новый ПарсерJSON;
	СтруктураОтвета = ПарсерJSON.ПрочитатьJSON(ОтветСервера);
	
	ПутьКФайлу = СтруктураОтвета["full_path"];
	Лог.Отладка(ПутьКФайлу);
	
	Возврат ПутьКФайлу;
	
КонецФункции

Процедура ПолучитьФайл(Знач ПутьСохранения, Знач СсылкаНаФайл) Экспорт
	
	СтрокаЗапуска = "curl -o %1 ""http://%2/%3""";
	СтрокаЗапуска = СтрШаблон(СтрокаЗапуска, ПутьСохранения, Сервер, СсылкаНаФайл);
	
	Лог.Отладка(СтрокаЗапуска);
	
	Результат = ОбщегоНазначения.ВыполнитьКоманду(СтрокаЗапуска);
	
КонецПроцедуры

Функция ЗаголовкиЗапроса()
	
	Заголовки = Новый Соответствие;
	Заголовки.Вставить("PRIVATE-TOKEN", Токен);
	Возврат Заголовки;
	
КонецФункции

Функция ВыполнитьHTTPЗапрос(Знач ТекстЗапроса, Знач HTTPМетод)
	
	Соединение = НовыйСоединение();
	Заголовки = ЗаголовкиЗапроса();
	Запрос = Новый HTTPЗапрос(ТекстЗапроса, Заголовки);

	Возврат Соединение.ВызватьHTTPМетод(HTTPМетод, Запрос);
	
КонецФункции

Функция ПреобразоватьОтветВJSON(Знач Ответ)
	
	ОтветСтрокой = Ответ.ПолучитьТелоКакСтроку();
	Лог.Отладка(ОтветСтрокой);
	ПарсерJSON = Новый ПарсерJSON;
	Возврат ПарсерJSON.ПрочитатьJSON(ОтветСтрокой);	

КонецФункции

Функция _ЗагрузитьФайл(Знач ПутьКФайлу, Знач ИДПроекта)
	Соединение = НовыйСоединение();
	ТекстЗапроса = СтрШаблон("/api/v4/projects/%1/uploads", ИДПроекта);
	
	Разделитель = СтрЗаменить(Новый УникальныйИдентификатор, "-", "");
	РазделительСтрок = Символы.ВК + Символы.ПС;
	ТипКонтента = СтрШаблон("multipart/form-data; boundary=%1", Разделитель);
	
	Заголовки = Новый Соответствие;
	Заголовки.Вставить("PRIVATE-TOKEN", Токен);
	Заголовки.Вставить("Content-Type", ТипКонтента);
	HTTPЗапрос = Новый HTTPЗапрос(ТекстЗапроса, Заголовки);
	
	ДвоичныеДанные = Новый ДвоичныеДанные(ПутьКФайлу);
	ТелоЗапроса = HTTPЗапрос.ПолучитьТелоКакПоток();
	ЗаписьДанных = Новый ЗаписьДанных(ТелоЗапроса, КодировкаТекста.UTF8, ПорядокБайтов.LittleEndian, "", "", Ложь);
	ЗаписьДанных.ЗаписатьСтроку("--" + Разделитель + РазделительСтрок);
	ЗаписьДанных.ЗаписатьСтроку("Content-Disposition: form-data; file=""@filename""" + РазделительСтрок);
	ЗаписьДанных.ЗаписатьСтроку("Content-Type: multipart/form-data" + РазделительСтрок);
	ЗаписьДанных.ЗаписатьСтроку(РазделительСтрок);
	ЗаписьДанных.Записать(ДвоичныеДанные);
	ЗаписьДанных.ЗаписатьСтроку(РазделительСтрок);
	
	ЗаписьДанных.ЗаписатьСтроку("--" + Разделитель + "--");
	ЗаписьДанных.Закрыть();
	
	Ответ = Соединение.ОтправитьДляОбработки(HTTPЗапрос);
	Лог.Отладка("Ответ: " + Ответ.ПолучитьТелоКакСтроку());
	
	Возврат Истина;
	
КонецФункции