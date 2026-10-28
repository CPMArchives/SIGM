	dcl
		key_hdr ptr ext,
		key_adr ptr ext,
		1 key_elt based(key_adr),
		  2 key_val char(max_chr),
		  2 key_loc fixed,
		  2 key_lst ptr;
