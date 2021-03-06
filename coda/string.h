#ifndef __CODA_STRING_H__
#define __CODA_STRING_H__

#include <ctype.h>
#include <string.h>

#ifdef __cplusplus
extern "C" {
#endif

#define coda_memcpy(d,s,n) ((memcpy(d,s,n)))
#define coda_cpymsz(d,s,n) ((memcpy(d,s,n),(n)))
#define coda_cpymem(d,s,n) (((char *)memcpy(d,s,n))+(n))

/* ... */

char *coda_strnchr(const char *s, char c, size_t len);         /* search for [c] in first [len] bytes of [s] */
char *coda_strxchr(const char *s, char c, size_t len);         /* search for [c] in first [len] bytes of [s] ignoring case */
char *coda_revnchr(const char *s, char c, size_t len);
char *coda_revxchr(const char *s, char c, size_t len);

char *coda_stristr(const char *s, const char *n);              /* search for [n] in [s] ignoring case */
char *coda_strnstr(const char *s, const char *n, size_t len);  /* search for [n] in first [len] bytes of [s] */
char *coda_strxstr(const char *s, const char *n, size_t len);  /* search for [n] in first [len] bytes of [s] ignoring case */

size_t coda_strnchp(const char *s, char c, size_t len);
size_t coda_strxchp(const char *s, char c, size_t len);

/* 
 * Функции возвращают длину максимальной подстроки в [s], состоящей:
 * (для *spn) из букв алфавита [n], а (для *spc) из оставшихся букв.
 * 
 * Алфавит [n] задается упорядоченным массивом своих букв.
 * Указатель [s] - это начало буфера со строкой длины [len] байт.
 * Возвращаемое значение считается от начала этой строки.
 *
 * Это касается и вызовов rev*, которые читают буфер [s] с конца.
 * Я сделал так же, как делает glibc для strrchr(3) и прочая.
 *
 */

size_t coda_strispn(const char *s, const char *n);
size_t coda_strnspn(const char *s, const char *n, size_t len);
size_t coda_strxspn(const char *s, const char *n, size_t len);
size_t coda_revnspn(const char *s, const char *n, size_t len);
size_t coda_revxspn(const char *s, const char *n, size_t len);
size_t coda_strispc(const char *s, const char *n);
size_t coda_strnspc(const char *s, const char *n, size_t len);
size_t coda_strxspc(const char *s, const char *n, size_t len);
size_t coda_revnspc(const char *s, const char *n, size_t len);
size_t coda_revxspc(const char *s, const char *n, size_t len);

#ifdef __cplusplus
}  /* extern "C" */
#endif

#endif /* __CODA_STRING_H__ */
