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
   var ltiles = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];

   var hlat;     // home latitude
   var hlon;     // home longitude
   var hlati=0;  // home tile y
   var hloni=0;  // home tile x
   var loni;     // current tile x
   var lati;     // current tile y
   var clon;     // current position x
   var clat;     // current position y
   var newTiles = 0;  // tiles visited for the first time
   var newTilesR = 0; // tiles visited for the first time this ride


   function lat2lati(lat)
   {
      return (8192.0 - Math.ln(Math.tan(lat*0.0174532925199433) + (1.0 / Math.cos(lat*0.0174532925199433))) * 2607.59458761762).toNumber();
   }



   function lon2loni(lon)
   {
      return ((lon + 180.0) * 45.5111111111111).toNumber();
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
                ltiles[5*(y-yi+hlati-59) + x-xi+hloni-59] = 0;
             }else
             {
                ltiles[5*(y-yi+hlati-59) + x-xi+hloni-59] = (bigMap[y*4+x/31] & (1<<(x%31))) >> (x%31);
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
      var lx;
      var ly;
      for (i=0;i<clp;i++)
      {
         lx = lon2loni(cpath[2*i])   - loni + 2;
         ly = lat2lati(cpath[2*i+1]) - lati + 2;
         if( (lx>=0) && (lx<5) && (ly>=0) && (ly<5))
         {
            ltiles[lx+ly*5]=2;
         }
      }

      if (ltiles[12]==1)
      {
         newTilesR++;
      }
      if (ltiles[12]==0)
      {
         newTilesR++;
         newTiles++;
      }
      ltiles[12]=2;
   }


   function initialize()
   {
       var i=0;
       var str;
       var vec;
       hlat = Properties.getValue("homeLatitude");
       hlon = Properties.getValue("homeLongitude");
       bigMap = Storage.getValue("bigMap");

       if((bigMap==null) || (hlat!=Storage.getValue("hlat")) || (hlon!=Storage.getValue("hlon")) )
       {
          bigMap = new[496];
          str = Properties.getValue("bmapstr");
          if (str.length() != 2604)
          {
             for (i=0; i<496; i++)
             {
                bigMap[i]=0;
             }
          }else
          {
             // decode string into bigMap
             for (i=0; i<124; i++)
             {
                vec = str.substring(i*21,i*21+21).toUtf8Array();
                /*
                bigMap[i*4]   = ((vec[0]-48) & 0x3f)
                               +((vec[1]-48) & 0x3f)<<6
                               +((vec[2]-48) & 0x3f)<<12
                               +((vec[3]-48) & 0x3f)<<18
                               +((vec[4]-48) & 0x3f)<<24
                               +((vec[20]-48) & 0x01)<<30;
                bigMap[i*4+1] = ((vec[5]-48) & 0x3f)
                               +((vec[6]-48) & 0x3f)<<6
                               +((vec[7]-48) & 0x3f)<<12
                               +((vec[8]-48) & 0x3f)<<18
                               +((vec[9]-48) & 0x3f)<<24
                               +((vec[20]-48) & 0x02)<<29;
                bigMap[i*4+2] = ((vec[10]-48) & 0x3f)
                               +((vec[11]-48) & 0x3f)<<6
                               +((vec[12]-48) & 0x3f)<<12
                               +((vec[13]-48) & 0x3f)<<18
                               +((vec[14]-48) & 0x3f)<<24
                               +((vec[20]-48) & 0x04)<<28;
                bigMap[i*4+3] = ((vec[15]-48) & 0x3f)
                               +((vec[16]-48) & 0x3f)<<6
                               +((vec[17]-48) & 0x3f)<<12
                               +((vec[18]-48) & 0x3f)<<18
                               +((vec[19]-48) & 0x3f)<<24
                               +((vec[20]-48) & 0x08)<<27;
               */
               // less secure, but slimmer version:
               for( hlati=0; hlati<21; hlati++)
               {
                 vec[hlati] -= 48;
               }
               bigMap[i*4]   =  vec[0]
                               +vec[1]<<6
                               +vec[2]<<12
                               +vec[3]<<18
                               +vec[4]<<24
                               +(vec[20] & 0x01)<<30;
               bigMap[i*4+1] =  vec[5]
                               +vec[6]<<6
                               +vec[7]<<12
                               +vec[8]<<18
                               +vec[9]<<24
                               +(vec[20] & 0x02)<<29;
               bigMap[i*4+2] =  vec[10]
                               +vec[11]<<6
                               +vec[12]<<12
                               +vec[13]<<18
                               +vec[14]<<24
                               +(vec[20] & 0x04)<<28;
               bigMap[i*4+3] =  vec[15]
                               +vec[16]<<6
                               +vec[17]<<12
                               +vec[18]<<18
                               +vec[19]<<24
                               +(vec[20] & 0x08)<<27;
             }
          }

          Storage.setValue("hlat",hlat);
          Storage.setValue("hlon",hlon);
          Properties.setValue("bmapstr",""); // not used anymore, might as well delete it
          Storage.setValue("bigMap",bigMap);
       }

       hlati = lat2lati(hlat);
       hloni = lon2loni(hlon);
       clat = hlat;
       clon = hlon;
       loni=hloni;
       lati=hlati;
       newTiles=0;
       newTilesR=0;
       bigmap2lmap(hloni,hlati);
   }

   function save()
   {
      Storage.setValue("bigMap",bigMap);
      Storage.setValue("newTiles",newTiles);
      Storage.setValue("newTilesR",newTilesR);
   }

}