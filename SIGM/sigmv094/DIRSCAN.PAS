

program dir_scan;

const
   def_fcb = 92;   (* default file control block address (5Ch *)
   def_dma = 128;  (* default direct memory address (80h) *)

type
   peek_poke = char;       
   byteptr   = ^peek_poke;

var 
   (* variant record user to circumvent type conflicts *)

   abs_mem_adr : record case Boolean of  
                    true : (i : integer);    
                   false : (p : byteptr);
                 end;

   i,j,return_code : integer;

function dirfrst :integer; external; (* search for first directory entry *)
function dirnext :integer; external; (* search for next entry *)

procedure request_all; 
(* filename and filetype are assigned all ?'s, select currently logged drive *)
begin                  
   abs_mem_adr.i:=def_fcb;
   abs_mem_adr.p^:=chr(0);  (* binary zeros for fcb drive code *)
   for i:=1 to 11 do 
   begin
       abs_mem_adr.i:=abs_mem_adr.i + 1;
       abs_mem_adr.p^:='?'
   end
end;

procedure write_entry(disp: integer);
(* display filename and filetype from dma + (32 X relative displacement *)
begin
   abs_mem_adr.i:=def_dma + (disp * 32); 
   for i:=1 to 8 do                  
   begin
      abs_mem_adr.i:=abs_mem_adr.i + 1; 
      write(abs_mem_adr.p^)          
   end;
   write(' ');
   for i:=1 to 3 do
   begin
      abs_mem_adr.i:=abs_mem_adr.i + 1;
      write(abs_mem_adr.p^)          
   end
end;

(*   M A I N   P R O G R A M   *)

beginŠ   writeln('DIRCTORY LISTING:');
   request_all;
   return_code:=dirfrst;                           
   if return_code=255 then writeln('**Disk is empty**') 
      else                               
      begin
         j:=1;
         while return_code <> 255 do 
         begin         
            write_entry(return_code);              
            write('    ');               
            j:=j+1;
            if j > 4 then                
            begin
               writeln; (* four entries displayed per line *)
               j:=1
            end; (* end if *) 
            return_code:=dirnext                   
         end; (* end while *)
      end; (* end else *)
end.
