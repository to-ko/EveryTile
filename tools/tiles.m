clear x;
d= load('tiles.txt');

hx = 8517;
hy = 5465;
A = zeros(124);

figure(); hold on;
for l=1:length(d)
   [x(l), y(l)] = deg2int(d(l,1)+0.0001,d(l,2)-0.0001);
   x(l) = x(l) -hx;
   y(l) = y(l) -hy;
   line([x(l) x(l)+1],[y(l), y(l)]);   
   line([x(l)+1 x(l)+1],[y(l), y(l)+1]);
   line([x(l)+1 x(l)],[y(l)+1, y(l)+1]);
   line([x(l) x(l)],[y(l)+1, y(l)]);
end

A(min(x)+62:max(x)+62,min(y)+62:max(y)+62) = 1;
for l=1:length(x)
   A(x(l)+62,y(l)+62) = 0;
end


axis ij

figure();
imagesc(A');

% create compressed array

%A(62,62) = 0;
%fid = fopen('tmp.dat','w')
l=1;
v = int32(zeros(124*4,1));
for ly=1:124
for lx=0:3
   b = A(lx*31+1:(lx+1)*31,ly) > 0;
   for i=1:31
      if(b(i))
         v(l)=bitset(v(l),i);
      end
   end
   l=l+1;
   %fwrite(fid,x,'uint32');
end
end

%fclose(fid);

%fid = fopen('tmp.dat','r');
%y = int32(fread(fid,512,'int32'));
%fclose(fid)

%v=v-v;
%fid = fopen('../resources/jsonData/bmap.json','w');
%fprintf(fid,'[');
%for l=1:length(v)-1
%fprintf(fid,'%i,',v(l));
%end
%fprintf(fid,'%i]',v(end));
%fclose(fid);

% create a string for the settings
clear x
for l=1:124
   x((l-1)*21+1) = bitand(v(4*(l-1)+1),0x3f)+48;
   x((l-1)*21+2) = bitand(bitshift(v(4*(l-1)+1),-6),0x3f)+48;
   x((l-1)*21+3) = bitand(bitshift(v(4*(l-1)+1),-12),0x3f)+48;
   x((l-1)*21+4) = bitand(bitshift(v(4*(l-1)+1),-18),0x3f)+48;
   x((l-1)*21+5) = bitand(bitshift(v(4*(l-1)+1),-24),0x3f)+48;

   x((l-1)*21+6) = bitand(v(4*(l-1)+2),0x3f)+48;
   x((l-1)*21+7) = bitand(bitshift(v(4*(l-1)+2),-6),0x3f)+48;
   x((l-1)*21+8) = bitand(bitshift(v(4*(l-1)+2),-12),0x3f)+48;
   x((l-1)*21+9) = bitand(bitshift(v(4*(l-1)+2),-18),0x3f)+48;
   x((l-1)*21+10)= bitand(bitshift(v(4*(l-1)+2),-24),0x3f)+48;

   x((l-1)*21+11) = bitand(v(4*(l-1)+3),0x3f)+48;
   x((l-1)*21+12) = bitand(bitshift(v(4*(l-1)+3),-6),0x3f)+48;
   x((l-1)*21+13) = bitand(bitshift(v(4*(l-1)+3),-12),0x3f)+48;
   x((l-1)*21+14) = bitand(bitshift(v(4*(l-1)+3),-18),0x3f)+48;
   x((l-1)*21+15) = bitand(bitshift(v(4*(l-1)+3),-24),0x3f)+48;

   x((l-1)*21+16) = bitand(v(4*(l-1)+4),0x3f)+48;
   x((l-1)*21+17) = bitand(bitshift(v(4*(l-1)+4),-6),0x3f)+48;
   x((l-1)*21+18) = bitand(bitshift(v(4*(l-1)+4),-12),0x3f)+48;
   x((l-1)*21+19) = bitand(bitshift(v(4*(l-1)+4),-18),0x3f)+48;
   x((l-1)*21+20) = bitand(bitshift(v(4*(l-1)+4),-24),0x3f)+48;

   x((l-1)*21+21) = bitand(bitshift(v(4*(l-1)+1),-30),0x01) + bitand(bitshift(v(4*(l-1)+2),-29),0x02) + bitand(bitshift(v(4*(l-1)+3),-28),0x04) + bitand(bitshift(v(4*(l-1)+4),-27),0x08)+48;
end
['>',char(x),'<']
