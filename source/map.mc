//! Copyright (C) 2018 Tomasz Korzec <tom@shmo.de>
//!
//! This program is free software: you can redistribute it and/or modify it
//! under the terms of the GNU General Public License as published by the Free
//! Software Foundation, either version 3 of the License, or (at your option)
//! any later version.
//!
//! This program is distributed in the hope that it will be useful, but WITHOUT
//! ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
//! FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
//! more details.
//!
//! You should have received a copy of the GNU General Public Lice

using Toybox.Application.Storage;
using Toybox.Application.Properties;

class map{
   var bigMap; // compressed map of tiles. 124 rows x 124 columns.
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
      return (8192.0 - Math.ln(Math.tan(lat*0.0174532925199433d) + (1.0 / Math.cos(lat*0.0174532925199433d))) * 2607.59458761762d).toNumber();
   }



   function lon2loni(lon)
   {
      return ((lon + 180.0d) * 45.5111111111111d).toNumber();
   }

   function bigmap2lmap(xi,yi)
    {
       var x;
       var y;
       for(x=xi-hloni+59; x<xi-hloni+64; x++)
       {
          for(y=yi-hlati+59; y<yi-hlati+64; y++)
          {
             if ( (x < 0) || (x>123) || (y<0) || (y>123) )
             {
                //too far out for permanent storage
                ltiles[x-xi+hloni-59][y-yi+hlati-59] = 0;
             }else
             {
                ltiles[x-xi+hloni-59][y-yi+hlati-59] = (bigMap[y*4+x/31] & (1<<(x%31))) >> (x%31);
             }
          }
       }
    }



    function setBigMap(xi,yi)
    {
       xi += (61-hloni);
       yi += (61-hlati);
       if ( (xi>=0) && (xi<124) && (yi>=0) && (yi<124) )
       {
          bigMap[yi*4+xi/31] |= (1<<(xi%31));
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
       /*if ((hlat==null) || (hlon==null))
       {
          hlat = 52.3763461;
          hlon =  4.8973255;
       }*/
       clat = hlat;
       clon = hlon;
       hlati = lat2lati(hlat);
       hloni = lon2loni(hlon);
       loni=hloni;
       lati=hlati;
       newTiles=0;
       newTilesR=0;

       bigMap = Storage.getValue("bigMap");
       if(bigMap==null )
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
   }

}