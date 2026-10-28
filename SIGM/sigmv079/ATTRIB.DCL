	%replace
		max_att by 32,  /* max number of attributes */
		max_chr by 16,  /* max attribute char length */
		max_siz by 128; /* max record size */
	dcl
		1 attrib(max_att) ext,
		  2 att_chars  char(max_chr) var,
		  2 att_type   fixed(7),
		  2 att_start  fixed,
		  2 att_finish fixed,
		att_cnt fixed ext;
