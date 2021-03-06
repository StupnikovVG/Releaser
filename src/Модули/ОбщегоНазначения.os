#Использовать logos
#Использовать 1commands

Перем Лог;

Функция ПолучитьЛог()
	Если Лог = Неопределено Тогда
		Лог = Логирование.ПолучитьЛог(ПараметрыСистемы.ИмяЛогаСистемы());
	КонецЕсли;
	Возврат Лог;
КонецФункции

Функция ПереопределитьПутьКБазе(Знач СтрокаСоединения) Экспорт
	
	Если Лев(СтрокаСоединения, 2) = "/F" Тогда
		ПутьКБазе = УбратьКавычкиВокругПути(Сред(СтрокаСоединения, 3));
		СтрокаСоединения = "/F""" + ПутьКБазе + """";
	КонецЕсли;

	Возврат СтрокаСоединения;

КонецФункции // ПереопределитьПолныйПутьВСтрокеПодключения()

Функция УбратьКавычкиВокругПути(Знач Путь) Экспорт

	ОбработанныйПуть = Путь;

	Если Лев(ОбработанныйПуть, 1) = """" Тогда
		ОбработанныйПуть = Прав(ОбработанныйПуть, СтрДлина(ОбработанныйПуть) - 1);
	КонецЕсли;
	Если Прав(ОбработанныйПуть, 1) = """" Тогда
		ОбработанныйПуть = Лев(ОбработанныйПуть, СтрДлина(ОбработанныйПуть) - 1);
	КонецЕсли;

	Возврат ОбработанныйПуть;

КонецФункции

Функция КомандаСистемы(СтрокаЗапуска, РабочийКаталог = "") Экспорт 

	Команда = Новый Команда;
	Команда.УстановитьПравильныйКодВозврата(0);
	Команда.ПоказыватьВыводНемедленно(Ложь);
	Команда.УстановитьСтрокуЗапуска(СтрокаЗапуска);
	Если ЗначениеЗаполнено(РабочийКаталог) Тогда
		Команда.УстановитьРабочийКаталог(РабочийКаталог);
	КонецЕсли;
	КодВозврата = Команда.Исполнить();
	Результат = Команда.ПолучитьВывод();
	Ожидаем.Что(КодВозврата, СтрШаблон("Код возврата не равен 0, а равен %1", КодВозврата)).Равно(0);
	
	Возврат Результат;

КонецФункции

Функция НовоеИмяРелиза(Знач ПоследнийРелиз) Экспорт
	
	ПолучитьЛог();

	Лог.Отладка("Последний релиз: " + ПоследнийРелиз);
	Массив = СтрРазделить(ПоследнийРелиз, ".");
	ПоследняяСтрока = Массив[Массив.ВГраница()];
	НовыйНомер = Число(ПоследняяСтрока) + 1;
	Массив.Удалить(Массив.ВГраница());
	Массив.Добавить(НовыйНомер);
	НовыйРелиз = СтрСоединить(Массив, ".");
	Лог.Отладка("Новый релиз: " + НовыйРелиз);
	
	Возврат НовыйРелиз;
	
КонецФункции

Функция КорректныйОтветHTTPЗапроса(Знач HTTPМетод) Экспорт

	Если HTTPМетод = "POST" Тогда
		Результат = 201;	
	Иначе
		Результат = 200;	
	КонецЕсли;

	Возврат Результат;
	
КонецФункции
