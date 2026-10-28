; 
;                     AREACODE.ASM Ver 1.0
; 
;                            as of
; 
;                       January 2, 1981
; 
;  AREACODE is used to display the region and state, specified 
; by  the user...very handy,  when someone leaves a area  code 
; number  on a CBBS,  but no city or state  reference.  Simple 
; enough to use,  just type AREACODE nnn<cr> (where 'nnn' is a 
; three   digit  area  code),   and  in  return,   you  get  a 
; geographical  region by city(s),  and state.  Sorry if  your 
; particular city is not represented,  and feel free to add it 
; as required...
; 
;  This  is not the most 'elegant' search routine that I could 
; have   used  in  implementing  this  program,   but  it   is 
; fast...it's  best  described  as  a  "forward  scanning/side 
; checking  mess"...if  you  don't find it matching  on  first 
; character, drop to the next possible match...
; 
;                          Best regards,
; 
;                          Kelly Smith, CP/M-Net SYSOP
;                          805-527-9321 (Modem, 300 Baud)
;                          805-527-0518 (Verbal Abuse)
; 

base	equ	0	; CP/M system base address
bdos	equ	base+5	; BDOS entry address
tbuff	equ	base+80h; temporary (command) buffer

prnstg	equ	9	; print string (ending in '$') function

lf	equ	0ah	; ASCII line feed
cr	equ	0dh	; ASCII carriage return

	org	base+100h

	lxi	h,0	; make local stack, so no warm boot
	dad	sp
	shld	oldstk
	lxi	sp,stack; old stack saved, make new stack
	lxi	d,msg1	; "Area code"
	call	print$message
	lxi	h,tbuff	; point to area code length
	mvi	d,0	; clear D Reg.
	mov	a,m	; get it...
	adi	1	; adjust buffer pointer +1
	mov	e,a
	dad	d	; point 1 past area code number
	mvi	m,'$'	; tag with 'end of string'
	lxi	d,tbuff+1	; check for valid entry
	ldax	d	; must be ASCII space to be correct
	cpi	' '
	jz	inputok
	lxi	d,msg4	; "NOT specified"
	call	print$message
	jmp	exit	; exit to CP/M now
inputok:call	print$message	; o.k., so far...print whatver was input
	lxi	d,msg2	; ", is "
	call	print$message
	mvi	b,0	; clear character position counter
	lxi	d,tbuff+2	; point to area code
	lxi	h,area$code$table	; point to area code table
scan:	ldax	d	; get first character of area code for match
	cmp	m	; does it match any first character in table?
	jnz	scan3	; if no match, advance 58 characters in table
scan1:	inx	d	; bump for next area code character
	inx	h	; bump to second character in area code table
	inr	b	; bump character position counter
	mov	a,b	; has character counter gone three positions?
	cpi	3
	jnz	scan2	; match next character, if not at position 3
	dcx	d	; adjust character position for subsequent match
	dcx	h
	ldax	d	; get last in entered area code
	cmp	m	; match to last character in area code table?
	jz	match	; if last character matches, display region, and state
	inx	d	; no match, bump both pointers
	inx	h
scan2:	ldax	d	; get next character to match
	cmp	m	; any match yet?
	jnz	backup	; back-up, if no match on current position
	mov	a,b	; are we at final character position?
	cpi	3
	jz	match	; if so, we have final match
	jmp	scan	; not final position, try again...
backup:	dcx	d	; back-up to start of entered area code
	dcx	h	; back-up to start of current area code in table
	dcr	b	; de-bump character position counter
	jnz	backup	; loop until we are at start of string
scan3:	push	d	; save pointer to entered area code
	lxi	d,58	; make 58 character bias
	dad	d	; add bias to area code table pointer
	pop	d	; recover pointer to entered area code
	mov	a,m	; have we hit "EOF" in area code table column?
	cpi	'Z'-40h
	jnz	scan	; if not, try next string for a match...
nomatch:lxi	d,msg3	; "NOT a valid area code"
	call	print$message
	jmp	exit	; exit to CP/M now...
match:	inx	h	; bump for region and state table location
	xchg		; swap to D&E Regs.
	call	print$message
exit:	lxi	d,crlf	; keep it neat...
	call	print$message
	lhld	oldstk	; get old CP/M stack
	sphl		; restore stack pointer, so no warm boot
	ret		; return to CP/M...
;
print$message		; print message string
;
	mvi	c,prnstg; print string (until '$') function
	call	bdos
	ret
;
area$code$table:	; storage for area code, region, state
;
	db	'205'
	db	' all regions, Alabama                                 $'
	db	'907'
	db	' all regions, Alaska                                  $'
	db	'602'
	db	' all regions, Arizona                                 $'
	db	'213'
	db	' Los Angeles, California                              $'
	db	'805'
	db	' Bakersfield, Ventura and Simi Valley, California     $'
	db	'707'
	db	' Eureka, Napa and Santa Rosa, California              $'
	db	'209'
	db	' Fresno and Stockton, California                      $'
	db	'415'
	db	' Oakland and San Francisco, California                $'
	db	'714'
	db	' Orange and San Diego, California                     $'
	db	'916'
	db	' Sacramento and South Tahoe, California               $'
	db	'408'
	db	' San Jose and Sunnyvale, California                   $'
	db	'519'
	db	' Ontario, Canada                                      $'
	db	'514'
	db	' Montreal, Canada                                     $'
	db	'705'
	db	' North Bay, Ontario, Canada                           $'
	db	'807'
	db	' Ontario, Canada                                      $'
	db	'613'
	db	' Ottawa, Ontario, Canada                              $'
	db	'418'
	db	' Quebec, Quebec, Canada                               $'
	db	'819'
	db	' Quebec, Canada                                       $'
	db	'416'
	db	' Toronto and Ontario, Canada                          $'
	db	'204'
	db	' Manatoba, Canada                                     $'
	db	'306'
	db	' Saskatchewan, Canada                                 $'
	db	'403'
	db	' Alberta, Canada                                      $'
	db	'804'
	db	' British Columbia, Canada                             $'
	db	'303'
	db	' all regions, Colorado                                $'
	db	'203'
	db	' all regions, Connecticut                             $'
	db	'302'
	db	' all regions, Deleware                                $'
	db	'202'
	db	' Washington, District of Columbia                     $'
	db	'813'
	db	' Avon Park, Fort Myers and Winter Haven, Florida      $'
	db	'305'
	db	' Fort Lauderdale, Key West, Miami and Florida         $'
	db	'904'
	db	' Jacksonville, Florida                                $'
	db	'404'
	db	' Atlanta, Rome, Georgia                               $'
	db	'912'
	db	' Waycross, Georgia                                    $'
	db	'808'
	db	' all regions, Hawaii                                  $'
	db	'208'
	db	' all regions, Idaho                                   $'
	db	'618'
	db	' Alton and Mount Vernon, Illinois                     $'
	db	'312'
	db	' Aurora, Chicago, Elgin and Highland Park, Illinois   $'
	db	'217'
	db	' Casey and Springfield, Illinois                      $'
	db	'815'
	db	' La Salle, Joliet and Rockford, Illinois              $'
	db	'812'
	db	' Evansville, Indiana                                  $'
	db	'219'
	db	' Gary, Hammond, Michigan City and South Bend, Indiana $'
	db	'317'
	db	' Indianapolis and Kokomo, Indiana                     $'
	db	'712'
	db	' Council Bluffs, Iowa                                 $'
	db	'515'
	db	' Des Moines and Mason City, Iowa                      $'
	db	'319'
	db	' Dubuque, Iowa                                        $'
	db	'316'
	db	' Dodge City and Wichita, Kansas                       $'
	db	'913'
	db	' Ottawa and Topeka, Kansas                            $'
	db	'606'
	db	' Ashland and Winchester, Kentuckey                    $'
	db	'502'
	db	' Louiseville, Paducah and Shelbyville, Kentuckey      $'
	db	'504'
	db	' Baton Rouge and New Orleans, Louisiana               $'
	db	'318'
	db	' Lake Charles, Louisiana                              $'
	db	'207'
	db	' all regions, Maine                                   $'
	db	'301'
	db	' all regions, Maryland                                $'
	db	'617'
	db	' Boston, Framingham and New Bedford, Massachusetts    $'
	db	'413'
	db	' Springfield, Massachusetts                           $'
	db	'905'
	db	' Mexico City, Mexico                                  $'
	db	'903'
	db	' Northwest Mexico                                     $'
	db	'313'
	db	' Adrian and Ann Arbor, Michigan                       $'
	db	'616'
	db	' Battle Creek, Cadillac and Grand Rapids, Michigan    $'
	db	'517'
	db	' Lancing and Saginaw, Michigan                        $'
	db	'906'
	db	' Sault Ste. Marie, Michigan                           $'
	db	'507'
	db	' Albert Lea and Rochester, Minnesota                  $'
	db	'218'
	db	' Duluth, Minnesota                                    $'
	db	'612'
	db	' Minneapolis and Saint Paul, Minnesota                $'
	db	'601'
	db	' all regions, Mississippi                             $'
	db	'417'
	db	' Joplin and Springfiled, Missouri                     $'
	db	'816'
	db	' Kansas City and Saint Joseph, Missouri               $'
	db	'314'
	db	' Saint Louis, Missouri                                $'
	db	'406'
	db	' all regions, Montana                                 $'
	db	'402'
	db	' Lincoln and Omaha, Nebraska                          $'
	db	'308'
	db	' North Platte, Nebraska                               $'
	db	'702'
	db	' all regions, Nevada                                  $'
	db	'603'
	db	' all regions, New Hampshire                           $'
	db	'609'
	db	' Atlantic City, Camden and Trenton, New Jersey        $'
	db	'201'
	db	' Hackensack, Morristown and Newark, New Jersey        $'
	db	'505'
	db	' all regions, New Mexico                              $'
	db	'518'
	db	' Albany, Greenwich and Schenectady, New York          $'
	db	'716'
	db	' Buffalo, Niagra Falls and Rochester, New York        $'
	db	'607'
	db	' Elmira and Stamford, New York                        $'
	db	'516'
	db	' Hempstead, New York                                  $'
	db	'914'
	db	' Monroe, Mount Vernon and Poughkeepsie, New York      $'
	db	'212'
	db	' New York City, New York                              $'
	db	'315'
	db	' Syracuse and Utica, New York                         $'
	db	'704'
	db	' Charlotte and Salisbury, North Carolina              $'
	db	'919'
	db	' Greenville and Williamston, North Carolina           $'
	db	'701'
	db	' all regions, North Dakota                            $'
	db	'216'
	db	' Akron, Cleveland, Massilon and Youngstown, Ohio      $'
	db	'513'
	db	' Cincinnati and Dayton, Ohio                          $'
	db	'614'
	db	' Columbus, Marietta and Newark, Ohio                  $'
	db	'419'
	db	' Toldeo, Ohio                                         $'
	db	'918'
	db	' Muskogee and Tulsa, Oklahoma                         $'
	db	'405'
	db	' Oklahoma City, Oklahoma                              $'
	db	'503'
	db	' all regions, Oregon                                  $'
	db	'215'
	db	' Allentown, Chester and Philadelphia, Pennsylvania    $'
	db	'814'
	db	' Altoona, Erie and Punxsutawney, Pennsylvania         $'
	db	'717'
	db	' Harrisburg, Scranton and Wilkes-Barre, Pennsylvania  $'
	db	'809'
	db	' all regions, Puerto Rico                             $'
	db	'401'
	db	' all regions, Rhode Island                            $'
	db	'803'
	db	' all regions, South Carolina                          $'
	db	'605'
	db	' all regions, South Dakota                            $'
	db	'615'
	db	' Chattanooga and Nashville, Tennessee                 $'
	db	'901'
	db	' Memphis, Tennesee                                    $'
	db	'806'
	db	' Amarillo, Texas                                      $'
	db	'512'
	db	' Austin, Corpus Christi and San Antonio, Texas        $'
	db	'214'
	db	' Dallas, Texas                                        $'
	db	'713'
	db	' Galveston and Houston, Texas                         $'
	db	'817'
	db	' Temple, Texas                                        $'
	db	'801'
	db	' all regions, Utah                                    $'
	db	'802'
	db	' all regions, Vermont                                 $'
	db	'809'
	db	' all regions, Virgin Islands                          $'
	db	'804'
	db	' Charlottesville, Norfolk and Richmond, Virginia      $'
	db	'703'
	db	' Fredericksburg, Roanoke and Winchester, Virginia     $'
	db	'509'
	db	' Pullman, Walla Walla, Washington                     $'
	db	'206'
	db	' Seattle and Vancouver, Washington                    $'
	db	'304'
	db	' all regions, West Virginia                           $'
	db	'608'
	db	' Beloit and Madison, Wisconsin                        $'
	db	'715'
	db	' Eau Claire and Wausau, Wisconsin                     $'
	db	'414'
	db	' Green Bay, Milwaukee and Racine, Wisconsin           $'
	db	'307'
	db	' all regions, Wyoming                                 $'
	db	'Z'-40h	; "EOF"
	db	'Z'-40h	; "EOF"
	db	'Z'-40h	; "EOF"
;
msg1:	db	cr,lf,' Area code$'
msg2:	db	', is$'
msg3:	db	' NOT a valid area code!$'
msg4:	db	' NOT specified!$'
crlf:	db	cr,lf,'$'
;
oldstk:	ds	2	; storage for "old" CP/M stack pointer
	ds	16	; storage for "local" stack
stack	equ	$	; "local" stack pointer starts here
;
	end
