///////////////////////////////////////////////////////////////////
//
// Служебный модуль с набором методов работы с командами приложения
//
// Структура модуля реализована в соответствии с рекомендациями 
// oscript-app-template (C) EvilBeaver
//
///////////////////////////////////////////////////////////////////

#Использовать logos
#Использовать tempfiles

///////////////////////////////////////////////////////////////////

Перем ИсполнителиКоманд; // Соответствие имен команд классам-исполнителям
Перем РегистраторКоманд; // 
Перем ДополнительныеПараметры; // Структура дополнительных параметров команд

///////////////////////////////////////////////////////////////////

Процедура ЗарегистрироватьКоманды(Знач Парсер) Экспорт

	РегистраторКоманд.ПриРегистрацииГлобальныхПараметровКоманд(Парсер);
	
	КомандыИРеализация = Новый Соответствие;
	РегистраторКоманд.ПриРегистрацииКомандПриложения(КомандыИРеализация);

	Для Каждого КлючИЗначение Из КомандыИРеализация Цикл

		ДобавитьКоманду(КлючИЗначение.Ключ, КлючИЗначение.Значение, Парсер);

	КонецЦикла;
	
КонецПроцедуры // ЗарегистрироватьКоманды

Процедура РегистраторКоманд(Знач ОбъектРегистратор) Экспорт
	
	ИсполнителиКоманд = Новый Соответствие;	
	РегистраторКоманд = ОбъектРегистратор;
	ДополнительныеПараметры = Новый Структура;

	ДополнительныеПараметры.Вставить("Лог", Логирование.ПолучитьЛог(ПараметрыСистемы.ИмяЛогаСистемы()));

КонецПроцедуры // РегистраторКоманд

Функция ПолучитьКоманду(Знач ИмяКоманды) Экспорт
	
	КлассРеализации = ИсполнителиКоманд[ИмяКоманды];
	Если КлассРеализации = Неопределено Тогда

		ВызватьИсключение "Неверная операция. Команда '" + ИмяКоманды + "' не предусмотрена.";

	КонецЕсли;
	
	Возврат КлассРеализации;
	
КонецФункции // ПолучитьКоманду

Функция ВыполнитьКоманду(Знач ИмяКоманды, Знач ПараметрыКоманды) Экспорт
	
	Команда = ПолучитьКоманду(ИмяКоманды);
	КодВозврата = Команда.ВыполнитьКоманду(ПараметрыКоманды, ДополнительныеПараметры);
	
	Возврат КодВозврата;

КонецФункции // ВыполнитьКоманду

Процедура ПоказатьСправкуПоКомандам(ИмяКоманды = Неопределено) Экспорт

	ПараметрыКоманды = Новый Соответствие;
	Если ИмяКоманды <> Неопределено Тогда

		ПараметрыКоманды.Вставить("Команда", ИмяКоманды);

	КонецЕсли;

	ВыполнитьКоманду(ПараметрыСистемы.ВозможныеКоманды().Помощь, ПараметрыКоманды);

КонецПроцедуры // ПоказатьСправкуПоКомандам

Процедура ДобавитьКоманду(Знач ИмяКоманды, Знач КлассРеализации, Знач Парсер)
	
	Попытка
		РеализацияКоманды = Новый(КлассРеализации);
		РеализацияКоманды.ЗарегистрироватьКоманду(ИмяКоманды, Парсер);
		ИсполнителиКоманд.Вставить(ИмяКоманды, РеализацияКоманды);
	Исключение
		ДополнительныеПараметры.Лог.Ошибка("Не удалось выполнить команду %1 для класса %2", ИмяКоманды, КлассРеализации);
		ВызватьИсключение;
	КонецПопытки;

КонецПроцедуры

///////////////////////////////////////////////////////////////////

Функция РезультатыКоманд() Экспорт

	РезультатыКоманд = Новый Структура;
	РезультатыКоманд.Вставить("Успех", 0);
	РезультатыКоманд.Вставить("НеверныеПараметры", 5);
	РезультатыКоманд.Вставить("ОшибкаВремениВыполнения", 1);
	
	Возврат РезультатыКоманд;

КонецФункции // РезультатыКоманд

Функция КодВозвратаКоманды(Знач Команда) Экспорт

	Возврат Число(Команда);

КонецФункции // КодВозвратаКоманды
