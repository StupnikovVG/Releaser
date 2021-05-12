#Использовать cmdline
#Использовать fs
#Использовать logos

Перем Лог;
Перем Сервер;
Перем Токен;


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

	Возврат Новый HTTPСоединение(Сервер)

КонецФункции

Функция ПолучитьПоследнийРелиз(Знач КаталогСохранения) Экспорт
КонецФункции

Функция СоздатьРелиз(Знач ФайлКонфигурации) Экспорт
	
КонецФункции