coda
====

aux library used in our projects

INSTALL
=======

I have written CentOS spec and Debian rules. Compile and install binary packages.

Binary packages are aviable for Ubuntu 12.04:
http://ctpp-bin.usrsrc.ru/files/ubuntu-12.04/

And CentOS 6:
http://ctpp-bin.usrsrc.ru/files/CentOS6/

DOC
===

logger.h
--------

Самый удобный на свете логгер для программ типа демонов. Ключевая фишка — по дефолту пишет всё в stderr. А если установить лог-файл, то stderr становится логом, т. е. можно писать в лог даже fprintf(stder, ...) или "cerr <<" для тех, кто любит в таком стиле писать.

Есть много уровней логирования, по умолчанию в обычный stderr с уровнем info.

Одна из фичей важных — в логах отдельным столбиком пишутся айдишники тредов. Айдишники можно заменить на тестовые названия (например, MAIN_THREAD), потом удобно грепать логи такие.

Все функции выглядят одинаково: log_notice, log_info, log_error, log_warn. Все имеют printf-like формат. Пример программы:

int main(int argc, char** argv)
{
	log_thread_name_set("MAINTHREAD");
	log_warn("Started with %d params", argc - 1);
	return 0;
}

cache.hpp
---------

Весьма няшный map-контейнер, годный для написания кешей — coda_cache. Вы просто по ключу запрашиваете значение методом get или устанавливаете методом set, а кеш автоматически следит, чтобы по памяти ограничения соблюдались и совсем старые элементы удалялись.

Пробуйте, контейнер на шаблонах и крайне прост в использовании.

shm_hash_map.hpp
----------------

Контейнер hash_map<uint64_t, фиксированная структура> в шареной памяти. Очень удобный контейнер, если у вас разные программы через шареную память хотят шарить мапку. Значение строго фиксированного размера, и помните, что std::string или char* туда класть нельзя, сегфолт получите в другой программе.

