#include <sys/file.h>
#include "logger.h"
#include "system.h"

#define coda_realpath(path) realpath((const char*) path, alloca(PATH_MAX))

int coda_fdmove(int fd, int nd) /* if nd is ebadf or eq-to-fd => fd is returned */
{
	if (0 > nd || fd == nd)
	{
		return fd;
	}

	nd = dup2(fd, nd);
	if (0 > nd) return -1;

	if (0 > close(fd))
	{
		return -1;
	}

	return nd;
}

int coda_fdopen(int fd, const char* path, int flags)
{
	int td;

	td = open(path, flags, 0644);
	if (0 > td) return -1;

	return coda_fdmove(td, fd);
}

int coda_mkpath(char* path)
{
	int rc;
	char* p = path + 1;

	for (; *p; ++p)
	{
		if (*p != '/') continue;

		*p = 0;
		rc = mkdir(path, 0755);
		*p = '/';

		if (0 > rc && EEXIST != errno)
		{
			return -1;
		}
	}

	return 0;
}

int coda_mkpidf(const char* path)
{
	int fd, nb;
	char buf [32];

	fd = open(path, O_CREAT|O_RDWR, 0644);
	if (0 > fd) return -1;

	if (0 > flock(fd, LOCK_EX|LOCK_NB))
	{
		log_emerg("can't lock pid-file %s", path);
		close(fd);
		return -1;
	}

	struct stat st;

	if (0 > fstat(fd, &st))
	{
		log_emerg("can't stat locked pid-file %s", path);
		flock(fd, LOCK_UN);
		close(fd);
		return -1;
	}

	if (st.st_size > 0)
	{
		log_emerg("pid-file %s exists", path);
		flock(fd, LOCK_UN);
		close(fd);
		return -1;
	}

	if (0 > (nb = snprintf(buf, 32, "%d\n", (int) getpid())))
	{
		flock(fd, LOCK_UN);
		close(fd);
		return -1;
	}

	if (0 > write(fd, buf, nb))
	{
		flock(fd, LOCK_UN);
		close(fd);
		return -1;
	}

	if (0 > flock(fd, LOCK_UN))
	{
		close(fd);
		return -1;
	}

	if (0 > close(fd))
	{
		return -1;
	}

	return 0;
}

/* 
 * In fact, open_flags should be defined by both prot_flags and mmap_flags values,
 * and the definition of this interdependence doesn't look trivial sometimes.
 *
 * However, my guess is that almost in all cases file descriptor must be readable,
 * e.g. MAP_SHARED + PROT_WRITE require open with O_RDWR (not O_WRONLY).
 *
 * See, mmap(2).
 */

int coda_mmap(coda_strp area, int prot_flags, int mmap_flags, const char* filename)
{
	int fd;
	int open_flags;

	if (NULL == filename) /* MAP_ANONYMOUS */
	{
		area->data = mmap(NULL, area->size, prot_flags, mmap_flags|MAP_ANON, -1, 0);
		if (MAP_FAILED == area->data) return -1;

		return 0;
	}

	open_flags = (prot_flags & PROT_WRITE) ? O_RDWR : O_RDONLY;

	fd = open(filename, open_flags);
	if (0 > fd) return -1;

	if (0 != area->size)
	{
		if (0 > ftruncate(fd, area->size))
		{
			close(fd);
			return -1;
		}
	}
	else
	{
		struct stat st;

		if (0 > fstat(fd, &st))
		{
			close(fd);
			return -1;
		}

		area->size = st.st_size;
	}

	area->data = mmap(NULL, area->size, prot_flags,
		mmap_flags, fd, 0);

	if (MAP_FAILED == area->data)
	{
		close(fd);
		return -1;
	}

	if (0 > close(fd))
	{
		return -1;
	}

	return 0;
}

