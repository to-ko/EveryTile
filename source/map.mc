using Toybox.Application.Storage;
using Toybox.Application.Properties;

class map{
   var bigMap = new[4*124]; // compressed map of tiles. 124 rows x 124 columns.
                            // Each value stores 31 bits, 1=visited, 0=unvisited tile
                            // only positive integers are used
   var ltiles = [ [0,0,0,0,0], [0,0,0,0,0],[0,0,0,0,0],[0,0,0,0,0],[0,0,0,0,0]];

   var hlat;     // home latitude
   var hlon;     // home longitude
   var hlati=0;  // home tile y
   var hloni=0;  // home tile x
   var loni=0;   // current tile x
   var lati=0;   // current tile y
   var clon;     // current position x
   var clat;     // current position y
   var newTiles = 0;  // tiles visited for the first time
   var newTilesR = 0; // tiles visited for the first time this ride


   function lat2lati(lat)
   {
      return ((1.0 - Math.ln(Math.tan(lat*0.0174532925199433d) + (1.0 / Math.cos(lat*0.0174532925199433d))) * 0.318309886183791d) *8192).toNumber();
   }



   function lon2loni(lon)
   {
      return ((lon + 180.0d) * 45.5111111111111d).toNumber();
   }

   function bigmap2lmap(xi,yi)
    {
       var i;
       var j;
       for(i=0; i<5; i++)
       {
          for(j=0; j<5; j++)
          {
             var x = xi-hloni+i-2;
             var y = yi-hlati+j-2;
             if ( (x < -61) || (x>62) || (y<-61) || (y>62) )
             {
                //too far out for permanent storage
                ltiles[i][j] = 0;
             }else
             {
                ltiles[i][j] = (bigMap[(y+61)*4+((x+61)/31)] & (1<<((x+61)%31))) >> ((x+61)%31);
             }
          }
       }
    }



    function setBigMap(xi,yi)
    {
       xi -= hloni;
       yi -= hlati;
       if ( (xi < -61) || (xi>62) || (yi<-61) || (yi>62) )
       {
          //too far out for permanent storage
       }else
       {
          bigMap[(yi+61)*4+((xi+61)/31)] |= (1<<((xi+61)%31));
       }
    }


   function setMap(lon,lat)
   {
      var xi = lon2loni(lon);
      var yi = lat2lati(lat);
      clon = lon;
      clat = lat;

      if((xi!=loni) || (yi!=lati))
      {
         bigmap2lmap(xi,yi);
         setBigMap(xi,yi);
         loni = xi;
         lati = yi;
         return true;
      }else
      {
         return false;
      }
   }

   function setTiles(cpath,clp)
   {
      var i;
      var lxi;
      var lyi;
      for (i=0;i<clp;i++)
      {
         lxi = lon2loni(cpath[2*i])   - loni + 2;
         lyi = lat2lati(cpath[2*i+1]) - lati + 2;
         if( (lxi>=0) && (lxi<5) && (lyi>=0) && (lyi<5) )
         {
            ltiles[lxi][lyi]=2;
         }
      }

      if (ltiles[2][2]==1)
      {
         newTilesR++;
      }
      if (ltiles[2][2]==0)
      {
         newTilesR++;
         newTiles++;
      }
      ltiles[2][2] = 2;
   }


   function initialize()
   {
       hlat = Properties.getValue("homeLatitude");
       hlon = Properties.getValue("homeLongitude");
       if ((hlat==null) || (hlon==null))
       {
          hlat = 52.3763461;
          hlon =  4.8973255;
       }
       clat = hlat;
       clon = hlon;
       hlati = lat2lati(hlat);
       hloni = lon2loni(hlon);
       loni=hloni;
       lati=hlati;
       newTiles=0;
       newTilesR=0;

       var hasDat = Storage.getValue("hasDat");
       if(hasDat != null)
       {
          bigMap = Storage.getValue("bigMap");
       }
       else
       {
          bigMap = WatchUi.loadResource(Rez.JsonData.jsonBmap);
       }
       bigmap2lmap(hloni,hlati);
   }

   function save()
   {
      Storage.setValue("bigMap",bigMap);
      Storage.setValue("newTiles",newTiles);
      Storage.setValue("newTilesR",newTilesR);
      Storage.setValue("hasDat",true);
   }

}