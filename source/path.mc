using Toybox.Application.Storage;

class path{
   var l;
   var p;
   var mp;
   hidden var hlon;
   hidden var hlat;

   function reset()
   {
      p = new[2*mp];
      for (l=0; l<2*mp; l++)
      {
         p[l] = 0.0;
      }
      l = 0;
      p[0] = hlon;
      p[1] = hlat;
   }

   function initialize(max_path_length,lon,lat)
   {
      mp= max_path_length;
      hlon = lon;
      hlat = lat;
      reset();
   }

   function add(dgr)
   {
      l++;
      if (l==mp)
      {
         // path to long for memory, throw away oldest half
         for (l=0; l<mp; l++)
         {
            p[l] = p[l+mp];
         }
         l = mp/2;
      }
      p[2*l]   = dgr[1];
      p[2*l+1] = dgr[0];
   }

   function load()
   {
      p = Storage.getValue("cpath");
      l = Storage.getValue("clp");
      if((l!=null) && (p!=null))
      {
         return true;
      }else
      {
         reset();
         return false;
      }
   }

   function save()
   {
      Storage.setValue("cpath",p);
      Storage.setValue("clp",l);
   }

   function set(lp,dgr)
   {
      l = lp;
      p[2*l]   = dgr[1];
      p[2*l+1] = dgr[0];
   }

   function getDeg(i)
   {
      if (i==null)
      {
         return [p[2*l+1],p[2*l]];
      }else
      {
         return [p[2*i+1],p[2*i]];
      }
   }
}