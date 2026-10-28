#include "B:PORTAB.H"

#define BUFSIZ	512
#define MAXFILES	16
struct _iobuf {
	WORD _fd;
	WORD _flag;
	BYTE *_base;
	BYTE *_ptr;
	WORD _cnt;
};
#ifndef FILE
extern struct _iobuf _iob[MAXFILES];
#define FILE struct _iobuf
#endif

#define _IOREAD	0x01
#define _IOWRT	0x02
#define _IOABUF	0x04
#define _IONBUF	0x08
#define _IOERR	0x10
#define _IOEOF	0x20
#define _IOLBUF 0x40
#define _IOSTRI	0x80
#define _IOASCI	0x100

#define stdin  (&_iob[0])
#define stdout (&_iob[1])
#define stderr (&_iob[2])

#define clearerr(p) ((p)->_flag & ~_IOERR)
#define feof(p) ((p)->_flag & _IOEOF)
#define ferror(p) ((p)->_flag & _IOERR)
#define fileno(p) ((p)->_fd)
#define getchar() getc(stdin)
#define putchar(c) putc(c,stdout)
#define putc fputc
#define getc fgetc


#define	abs(x)	((x) < 0 ? -(x) : (x))

#define	MAX(x,y)   (((x) > (y)) ? (x) :  (y))
#define	MIN(x,y)   (((x) < (y)) ? (x) :  (y))
